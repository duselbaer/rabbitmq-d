module rabbitmq.message.ConnectionOpenOkFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.Field;

struct ConnectionOpenOkFrame
{
    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
        frameReceiver.nextShortString;
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}