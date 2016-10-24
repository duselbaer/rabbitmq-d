module rabbitmq.message.BasicDeliverFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.BasicFrame;
import rabbitmq.message.Field;

struct BasicDeliverFrame
{
    BasicFrame basicFrame;
    alias basicFrame this;

    ShortString consumerTag;
    ulong deliveryTag;
    bool redelivered;
    ShortString exchange;
    ShortString routingKey;

    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
        this.basicFrame = BasicFrame(frameReceiver, 60);

        consumerTag = ShortString(frameReceiver.nextShortString);
        deliveryTag = frameReceiver.nextQword;
        redelivered = frameReceiver.nextBool;
        exchange = ShortString(frameReceiver.nextShortString);
        routingKey = ShortString(frameReceiver.nextShortString);    
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }

    public string toString() const
    {
        import std.format : format;

        return "%s(%s, consumerTag=%s, deliveryTag=%s, redelivered=%s, exchange=%s, routingKey=%s)"
                .format(BasicDeliverFrame.stringof, this.basicFrame, this.consumerTag,
                        this.deliveryTag, this.redelivered, this.exchange, this.routingKey);
    }
}