module rabbitmq.message.MethodFrame;

import rabbitmq.message.Field;
import rabbitmq.message.Frame;

struct MethodFrame
{
    Frame frame;
    alias frame this;

    ushort classId;
    ushort methodId;

    @disable this();

    this(ushort channel, uint size, ushort classId, ushort methodId)
    {
        this.frame = Frame(1, channel, size + 4);
        this.classId = classId;
        this.methodId = methodId;
    }

    public void serialize(ref ubyte[] buffer)
    {
        frame.serialize(buffer);
        buffer.serialize(this.classId).serialize(this.methodId);
    }
}