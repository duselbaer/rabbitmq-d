module rabbitmq.message.ChannelOpenOkFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.Field;

struct ChannelOpenOkFrame
{
    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
        frameReceiver.nextLongString;
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}