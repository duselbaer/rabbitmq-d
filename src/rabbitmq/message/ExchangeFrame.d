module rabbitmq.message.ExchangeFrame;

import rabbitmq.message.MethodFrame;

struct ExchangeFrame
{
    public MethodFrame methodFrame;
    alias methodFrame this;

    @disable this();

    this(ushort channel, uint size, ushort methodId)
    {
        this.methodFrame = MethodFrame(channel, size, 40, methodId);
    }

    public void serialize(ref ubyte[] buffer)
    {
        methodFrame.serialize(buffer);
    }
}