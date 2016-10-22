module rabbitmq.message.ChannelFrame;

import rabbitmq.message.MethodFrame;

struct ChannelFrame
{
    public MethodFrame methodFrame;
    alias methodFrame this;

    @disable this();

    this(ushort channel, uint size, ushort methodId)
    {
        this.methodFrame = MethodFrame(channel, size, 20, methodId);
    }

    public void serialize(ref ubyte[] buffer)
    {
        methodFrame.serialize(buffer);
    }
}