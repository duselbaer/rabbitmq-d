module rabbitmq.message.BasicHeaderFrame;

import rabbitmq.asynchronous.Connection;
import rabbitmq.message.HeaderFrame;
import rabbitmq.message.Field;

struct BasicHeaderFrame
{
    HeaderFrame headerFrame;
    alias headerFrame this;

    ubyte bools1;
    ubyte bools2;

    ushort weight;
    ulong bodySize;
    string contentType;
    string contentEncoding;
    Field[string] headers;
    ubyte deliveryMode;
    ubyte priority;
    string correlationId;
    string replyTo;
    string expiration;
    string messageId;
    SysTime timestamp;
    string typeName;
    string userId;
    string appId;
    string clusterId;

    @disable this();

    public this(ushort channel, ushort weight, ulong bodySize)
    {
        this.weight = weight;
        this.bodySize = bodySize;

        uint size = this.weight.wireSize +
                this.bodySize.wireSize +
                this.bools1.wireSize +
                this.bools2.wireSize;

        this.headerFrame = HeaderFrame(channel, 60, size);
    }

    public this(ref FrameReceiver frameReceiver)
    {
        this.headerFrame = HeaderFrame(frameReceiver, 60);

        this.weight = frameReceiver.nextWord;
        this.bodySize = frameReceiver.nextQword;
        this.bools1 = frameReceiver.nextByte;
        this.bools2 = frameReceiver.nextByte;

        /+
\x02
    \x00\x01 - channel
    \x00\x00\x00\x13 - payloadSize
    \x00\x3c - classId
    \x00 - weight
    \x00\x00\x00\x00\x00\x00\x00\x00 - bodySize
    \x08 - bools1 : priority
    \x30 - bools2 : userId, typeName
    \x00 - prio
    \x00 - userId
    \x00 - typeName
    \x00\x00\x01 - ???
\xce
\x03\x00\x01\x00\x00\x00\x08\x42\x4c\x41\x46\x41\x53\x45\x4c\xce
        +/

        if (this.hasContentType) this.contentType = frameReceiver.nextShortString;
        if (this.hasContentEncoding) this.contentEncoding = frameReceiver.nextShortString;
        if (this.hasHeaders) this.headers = frameReceiver.nextTable;
        if (this.hasDeliveryMode) this.deliveryMode = frameReceiver.nextByte;
        if (this.hasPriority) this.priority = frameReceiver.nextByte;
        if (this.hasCorrelationId) this.correlationId = frameReceiver.nextShortString;
        if (this.hasReplyTo) this.replyTo = frameReceiver.nextShortString;
        if (this.hasExpiration) this.expiration = frameReceiver.nextShortString;
        if (this.hasMessageId) this.messageId = frameReceiver.nextShortString;
        if (this.hasTimestamp) frameReceiver.nextQword;
        if (this.hasTypeName) this.typeName = frameReceiver.nextShortString;
        if (this.hasUserId) this.userId = frameReceiver.nextShortString;
        if (this.hasAppId) this.appId = frameReceiver.nextShortString;
        if (this.hasClusterId) this.clusterId = frameReceiver.nextShortString;
    }

    public void serialize(ref ubyte[] buffer)
    {
        headerFrame.serialize(buffer);
        buffer.serialize(this.weight)
                .serialize(this.bodySize)
                .serialize(this.bools1)
                .serialize(this.bools2)
                .serialize(ubyte(0xce));
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }

    bool hasExpiration() const { return (this.bools1 & 0x01) != 0;}
    bool hasReplyTo() const { return (this.bools1 & 0x02) != 0;}
    bool hasCorrelationId() const { return (this.bools1 & 0x04) != 0;}
    bool hasPriority() const { return (this.bools1 & 0x08) != 0;}
    bool hasDeliveryMode() const { return (this.bools1 & 0x10) != 0;}
    bool hasHeaders() const { return (this.bools1 & 0x20) != 0;}
    bool hasContentEncoding() const { return (this.bools1 & 0x40) != 0;}
    bool hasContentType() const { return (this.bools1 & 0x80) != 0;}
    bool hasClusterId() const { return (this.bools2 & 0x04) != 0;}
    bool hasAppId() const { return (this.bools2 & 0x08) != 0;}
    bool hasUserId() const { return (this.bools2 & 0x10) != 0;}
    bool hasTypeName() const { return (this.bools2 & 0x20) != 0;}
    bool hasTimestamp() const { return (this.bools2 & 0x40) != 0;}
    bool hasMessageId() const { return (this.bools2 & 0x80) != 0;}

    public string toString() const
    {
        import std.conv : to;
        import std.format : format;

        string[string] flags = null;

        if (this.hasContentType) flags["contentType"] = this.contentType;
        if (this.hasContentEncoding) flags["contentEncoding"] = this.contentEncoding;
        if (this.hasHeaders) flags["headers"] = this.headers.to!string;
        if (this.hasDeliveryMode) flags["deliveryMode"] = this.deliveryMode.to!string;
        if (this.hasPriority) flags["priority"] = this.priority.to!string;
        if (this.hasCorrelationId) flags["correlationId"] = this.correlationId;
        if (this.hasReplyTo) flags["replyTo"] = this.replyTo;
        if (this.hasExpiration) flags["expiration"] = this.expiration;
        if (this.hasMessageId) flags["messageId"] = this.messageId;
        if (this.hasTimestamp) flags["timeStamp"] = this.timestamp.to!string;
        if (this.hasTypeName) flags["typeName"] = this.typeName;
        if (this.hasUserId) flags["userId"] = this.userId;
        if (this.hasAppId) flags["appId"] = this.appId;
        if (this.hasClusterId) flags["clusterId"] = this.clusterId;

        return "%s(%s, weight=%s, bodySize=%s, flags=%s (%x, %x))".format(BasicHeaderFrame.stringof, this.headerFrame,
            this.weight, this.bodySize, flags, this.bools1, this.bools2);
    }
}