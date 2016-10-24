module rabbitmq.message.BasicFrame;

import rabbitmq.asynchronous.Connection;
import rabbitmq.message.MethodFrame;

struct BasicFrame
{
    public MethodFrame methodFrame;
    alias methodFrame this;

    @disable this();

    this(ref FrameReceiver frameReceiver, ushort methodId)
    {
        this.methodFrame = MethodFrame(frameReceiver.channel, frameReceiver.payloadSize, 60, methodId);
    }

    this(ushort channel, uint size, ushort methodId)
    {
        this.methodFrame = MethodFrame(channel, size, 60, methodId);
    }

    public void serialize(ref ubyte[] buffer)
    {
        methodFrame.serialize(buffer);
    }
}