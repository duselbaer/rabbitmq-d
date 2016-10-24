module rabbitmq.message.HeaderFrame;

import rabbitmq.asynchronous.Connection;
import rabbitmq.message.Field;
import rabbitmq.message.Frame;

struct HeaderFrame
{
    Frame frame;
    alias frame this;

    ushort classId;

    @disable this();

    this(ushort channel, ushort classId, uint size)
    {
        this.classId = classId;

        this.frame = Frame(2, channel, size + 2);
    }

    this(ref FrameReceiver frameReceiver, ushort classId)
    {
        this.frame = Frame(2, frameReceiver.channel, frameReceiver.payloadSize);

        this.classId = classId;
    }

    public void serialize(ref ubyte[] buffer)
    {
        frame.serialize(buffer);
        buffer.serialize(classId);
    }
}