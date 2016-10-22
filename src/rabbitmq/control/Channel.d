module rabbitmq.control.Channel;

import std.typecons : Flag, No;
import rabbitmq.asynchronous.Connection;
import rabbitmq.message.BasicHeaderFrame;
import rabbitmq.message.BasicPublishFrame;
import rabbitmq.message.BodyFrame;
import rabbitmq.message.ExchangeDeclareFrame;

/**
 * A Channel is the primary communication method for interacting with RabbitMQ.
 */
class Channel
{
    private Session session;
    private ushort channelId;

    public this(ushort channelId, Session session)
    {
        this.channelId = channelId;
        this.session = session;
    }

    /**
     * Creates an exchange if it does not exist yet. If it already exists it verifies that the
     * exchange is of the expected type.
     */
    public void exchangeDeclare(string name, string type,
            Flag!"passive" passive = No.passive,
            Flag!"durable" durable = No.durable,
            Flag!"autoDelete" autoDelete = No.autoDelete)
    {
        this.session.send(ExchangeDeclareFrame(channelId, name, type, 0, null));
    }

    /**
     * Declares & creates a queue if needed.
     */
    public void queueDeclare(string name)
    {
    }

    /**
     * Low-Level publishing of message.
     */
    public void basicPublish(string exchange, string routingKey, string messageBody)
    {
        this.session.send(BasicPublishFrame(channelId, exchange, routingKey, 0));
        this.session.send(BasicHeaderFrame(channelId, 0, messageBody.length));
        this.session.send(BodyFrame(channelId, messageBody));
    }
}