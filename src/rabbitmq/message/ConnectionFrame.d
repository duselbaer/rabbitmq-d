module rabbitmq.message.ConnectionFrame;

import rabbitmq.message.MethodFrame;

struct ConnectionFrame
{
    public MethodFrame methodFrame;
    alias methodFrame this;

    @disable this();

    this(uint size, ushort methodId)
    {
        this.methodFrame = MethodFrame(0, size, 10, methodId);
    }

    public void serialize(ref ubyte[] buffer)
    {
        methodFrame.serialize(buffer);
    }
}