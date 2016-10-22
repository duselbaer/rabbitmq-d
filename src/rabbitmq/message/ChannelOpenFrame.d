module rabbitmq.message.ChannelOpenFrame;

import rabbitmq.message.ChannelFrame;
import rabbitmq.message.Field;

struct ChannelOpenFrame
{
    ChannelFrame channelFrame;
    alias channelFrame this;

    ShortString unused;

    @disable this();

    public this(ushort channel)
    {
        uint size = 1;

        this.channelFrame = ChannelFrame(channel, size, 10);
    }

    public void serialize(ref ubyte[] buffer)
    {
        channelFrame.serialize(buffer);
        buffer.serialize(unused)
            .serialize(ubyte(0xce));
    }
}