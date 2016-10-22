module rabbitmq.message.ConnectionTuneFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.Field;

struct ConnectionTuneFrame
{
    ushort channelMax;
    uint frameMax;
    ushort heartbeat;

    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
        this.channelMax = frameReceiver.nextWord;
        this.frameMax = frameReceiver.nextDword;
        this.heartbeat = frameReceiver.nextWord;
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}