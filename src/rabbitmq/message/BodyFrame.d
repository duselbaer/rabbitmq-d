module rabbitmq.message.BodyFrame;

import rabbitmq.asynchronous.Connection;
import rabbitmq.message.Field;
import rabbitmq.message.Frame;

struct BodyFrame
{
    Frame frame;
    alias frame this;

    string content;

    @disable this();

    this(ushort channel, string content)
    {
        this.content = content;

        this.frame = Frame(3, channel, cast(uint)(content.length));
    }

    this(ref FrameReceiver frameReceiver)
    {
        this.frame = Frame(3, frameReceiver.channel, frameReceiver.payloadSize);

        /// XXX Handle non-UTF-8
        this.content = cast(string)(frameReceiver.nextBytes(this.frame.size));
        import std.stdio;
        writefln("Content: %s", content);
    }

    public void serialize(ref ubyte[] buffer)
    {
        frame.serialize(buffer);
        buffer.serialize(this.content)
            .serialize(ubyte(0xce));
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}