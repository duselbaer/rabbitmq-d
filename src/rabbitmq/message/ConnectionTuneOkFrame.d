module rabbitmq.message.ConnectionTuneOkFrame;

import rabbitmq.message.ConnectionFrame;
import rabbitmq.message.Field;

struct ConnectionTuneOkFrame
{
    ConnectionFrame connectionFrame;
    alias connectionFrame this;

    ushort channelMax;
    uint frameMax;
    ushort heartbeat;

    @disable this();

    public this(ushort channelMax, uint frameMax, ushort heartbeat)
    {
        uint size = channelMax.wireSize + frameMax.wireSize + heartbeat.wireSize;

        this.connectionFrame = ConnectionFrame(size, 31);
        this.channelMax = channelMax;
        this.frameMax = frameMax;
        this.heartbeat = heartbeat;
    }

    public void serialize(ref ubyte[] buffer)
    {
        connectionFrame.serialize(buffer);
        buffer.serialize(channelMax)
            .serialize(frameMax)
            .serialize(heartbeat)
            .serialize(ubyte(0xce));
    }
}