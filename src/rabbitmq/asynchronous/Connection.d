module rabbitmq.asynchronous.Connection;

import asynchronous;
import rabbitmq.control.Channel;
import rabbitmq.control.Connection : ConnectionInterface = Connection;
import rabbitmq.message.ChannelOpenFrame;
import rabbitmq.message.ChannelOpenOkFrame;
import rabbitmq.message.ConnectionOpenFrame;
import rabbitmq.message.ConnectionOpenOkFrame;
import rabbitmq.message.ConnectionStartFrame;
import rabbitmq.message.ConnectionStartOkFrame;
import rabbitmq.message.ConnectionTuneFrame;
import rabbitmq.message.ConnectionTuneOkFrame;
import rabbitmq.message.ExchangeDeclareOkFrame;
import rabbitmq.message.Field;
import std.stdio;

class Connection : ConnectionInterface
{
    private Session session = null;

    @Coroutine
    public static ConnectionInterface createConnection(EventLoop loop, string hostname = "localhost", string port = "5672",
            string peer = "RABBIT")
    {
        auto self = new Connection;

        loop.createConnection(() => new Session(peer, self), hostname, port);

        return self;
    }

    public override bool process(ConnectionStartFrame frame)
    {
        writefln("Processing %s", frame);

        // Field[string] properties, string mechanism, string response, string locale)
        this.session.send(ConnectionStartOkFrame(
                null, "PLAIN", "\x00guest\x00guest", "en_US"
        ));

        return false;
    }

    public override bool process(ConnectionTuneFrame frame)
    {
        writefln("Processing %s", frame);

        this.session.send(ConnectionTuneOkFrame(
            128, frame.frameMax, 0
        ));
        this.session.send(ConnectionOpenFrame("/"));

        return false;
    }

    public override bool process(ConnectionOpenOkFrame frame)
    {
        writefln("Connection Open");

        return false;
    }

    public override bool process(ChannelOpenOkFrame frame)
    {
        // writefln("Channel %s open", frame.channel);

        return false;
    }

    public override bool process(ExchangeDeclareOkFrame frame)
    {
        writefln("ExchangeDeclareOk");

        return false;
    }

    public Channel channel()
    {
        this.session.send(ChannelOpenFrame(1));

        return new Channel(1, this.session);
    }
}

class Session : Protocol
{
    enum State {
        NOT_CONNECTED,
        HANDSHAKE_INITIATED,
        CONNECTION_READY
    }

    private Connection connection_ = null;
    private State state_ = State.NOT_CONNECTED;
    private Transport transport_ = null;
    private const(void)[] buffer_ = null;

    public this(string peer, Connection connection)
    {
        this.connection_ = connection;
    }

    public override void connectionMade(BaseTransport transport)
    {
        this.transport_ = cast(Transport)(transport);
        this.connection_.session = this;

        this.transport_.write("AMQP\x00\x00\x09\x01");
        this.state_ = State.HANDSHAKE_INITIATED;
    }

    public override void connectionLost(Exception exception)
    {
        this.connection_.session = null;
        this.state_ = State.NOT_CONNECTED;
        this.transport_ = null;
    }

    public override void pauseWriting()
    {
        import std.stdio;

        writeln("pauseWriting");
    }

    public override void resumeWriting()
    {
        import std.stdio;

        writeln("resumeWriting");
    }

    public override bool eofReceived()
    {
        return true;
    }

    public override void dataReceived(const(void)[] data)
    {
        import std.stdio;

        FrameReceiver frameReceiver = FrameReceiver(cast(const(ubyte)[])(data));

        if (frameReceiver.complete)
        {
            writefln("Frame received: type = %s, channel = %s, %s bytes payload", frameReceiver.type,
                    frameReceiver.channel, frameReceiver.payloadSize);

            frameReceiver.process(this.connection_);
        }
    }

/+
    type    \x01
    channel \x00\x00
    size    \x00\x00\x00\x0e
    payload \x00\x0a\x00\x0b\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00
    EOP     \xce
+/
    public void send(PACKET_TYPE)(PACKET_TYPE packet)
    {
        writefln("Send %s", packet);

        ubyte[] buffer = null;
        packet.serialize(buffer);

        writefln("Serialized %s bytes", buffer.length);

        this.transport_.write(cast(const(void)[])(buffer));
    }
}

import std.stdio;

struct FrameReceiver
{
    public ubyte type;
    public ushort channel;
    public uint payloadSize;

    private const(ubyte)[] buffer_;

    @disable this();

    public this(const(ubyte)[] buffer)
    {
        this.buffer_ = buffer;

        writefln("Analyze %s bytes", buffer.length);

        if (this.buffer_.length < 7)
        {
            writeln("Buffer too short");
            return;
        }

        this.type = this.nextByte;
        this.channel = this.nextWord;
        this.payloadSize = this.nextDword;

        // TODO: Check for EOF marker
    }

    public bool complete()
    {
        return this.buffer_.length > this.payloadSize;
    }

    public bool nextBool()
    {
        return this.nextByte != 0;
    }

    public ubyte nextByte()
    {
        import std.range;

        enforce(this.buffer_.length >= 1);

        ubyte ret = this.buffer_.front;
        this.buffer_.popFront;

        return ret;
    }

    public const(ubyte)[] nextBytes(size_t bytesToRead)
    {
        import std.range : dropExactly, takeExactly;

        auto ret = this.buffer_.takeExactly(bytesToRead);
        this.buffer_ = this.buffer_.dropExactly(bytesToRead);

        return ret;
    }

    public ushort nextWord()
    {
        return cast(ushort)(this.nextByte * 256 + this.nextByte);
    }

    public uint nextDword()
    {
        return cast(uint)(this.nextWord * 65536 + this.nextWord);
    }

    public string nextShortString()
    {
        return cast(string)(this.nextBytes(this.nextByte));
    }

    public string nextLongString()
    {
        return cast(string)(this.nextBytes(this.nextDword));
    }

    public Field[string] nextTable()
    {
        import std.array : empty;

        Field[string] table = null;
        auto buffer = this.nextBytes(this.nextDword);
        auto oldBuffer = this.buffer_;
        this.buffer_ = buffer;

        while (!this.buffer_.empty)
        {
            auto name = this.nextShortString;
            table[name] = this.nextField;
        }

        this.buffer_ = oldBuffer;

        return table;
    }

    public Field nextField()
    {
        import std.format : format;

        char fieldType = this.nextByte;

        switch (fieldType)
        {            
            case 't':
                return new SimpleField!bool(this.nextBool);
            case 'B':
            case 'b':
            case 'U':
            case 'u':
            case 'I':
            case 'i':
            case 'L':
            case 'l':
            case 'f':
            case 'd':
            case 'D':
                break;
            case 'S':
                return new SimpleField!string(this.nextLongString);
            case 's':
                return new SimpleField!string(this.nextShortString);
            case 'A':
            case 'T':
                break;
            case 'F':
                return new SimpleField!(Field[string])(this.nextTable);
            case 'V':
                return null;

            default:
                writefln("Unknown field type: %s".format(fieldType));    
        }

        return null;
    }

    public bool process(Connection connection)
    {
        import std.format : format;

        switch (this.type)
        {
            case 1:
                return this.processMethodFrame(connection);
            case 2:
                return this.processHeaderFrame(connection);
            case 3:
            case 4:
            case 8:
            default:
                enforce(0, "Received frame with unknown type: %s".format(this.type));
        }

        return false;
    }

    private bool processMethodFrame(Connection connection)
    {
        import std.format : format;

        ushort classId = this.nextWord;

        switch (classId)
        {
            case 10:
                return this.processConnectionFrame(connection);
            case 20:
                return this.processChannelFrame(connection);
            case 40:
                return this.processExchangeFrame(connection);
            default:
                enforce(0, "Received method frame with unknown class: %s".format(classId));
        }

        return false;
    }

    private bool processHeaderFrame(Connection connection)
    {
        assert(0);
    }

    private bool processConnectionFrame(Connection connection)
    {
        import rabbitmq.message.ConnectionStartFrame : ConnectionStartFrame;
        import std.format : format;

        ushort methodId = this.nextWord;

        switch (methodId)
        {
            case 10:
                return ConnectionStartFrame(this).process(connection);
            case 30:
                return ConnectionTuneFrame(this).process(connection);
            case 41:
                return ConnectionOpenOkFrame(this).process(connection);
            default:
                enforce(0, "Received unknown connection frame method: %s".format(methodId));
        }

        return false;
    }

    private bool processChannelFrame(Connection connection)
    {
        import rabbitmq.message.ConnectionStartFrame : ConnectionStartFrame;
        import std.format : format;

        ushort methodId = this.nextWord;

        switch (methodId)
        {
            case 11:
                return ChannelOpenOkFrame(this).process(connection);
            default:
                enforce(0, "Received unknown channel frame method: %s".format(methodId));
        }

        return false;
    }

    private bool processExchangeFrame(Connection connection)
    {
        import std.format : format;

        ushort methodId = this.nextWord;

        switch (methodId)
        {
            case 11:
                return ExchangeDeclareOkFrame(this).process(connection);
            default:
                enforce(0, "Received unknown exchange frame method: %s".format(methodId));
        }

        return false;
    }
}

unittest
{
    const(ubyte)[]
        data = [ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08 ];

    FrameReceiver receiver = FrameReceiver(data);

    assert(0x01 == receiver.type);
    assert(0x0203 == receiver.channel);
    assert(0x04050607 == receiver.payloadSize);
}
