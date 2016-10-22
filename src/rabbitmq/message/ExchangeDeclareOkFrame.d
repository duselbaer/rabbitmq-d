module rabbitmq.message.ExchangeDeclareOkFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.Field;

struct ExchangeDeclareOkFrame
{
    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}