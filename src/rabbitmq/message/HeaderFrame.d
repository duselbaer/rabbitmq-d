module rabbitmq.message.HeaderFrame;

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

    public void serialize(ref ubyte[] buffer)
    {
        frame.serialize(buffer);
        buffer.serialize(classId);
    }
}