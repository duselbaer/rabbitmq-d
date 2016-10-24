module rabbitmq.control.Connection;

import rabbitmq.control.Channel;
import rabbitmq.message.BasicConsumeOkFrame;
import rabbitmq.message.BasicDeliverFrame;
import rabbitmq.message.BasicHeaderFrame;
import rabbitmq.message.BodyFrame;
import rabbitmq.message.ConnectionStartFrame;
import rabbitmq.message.ConnectionTuneFrame;
import rabbitmq.message.ConnectionOpenOkFrame;
import rabbitmq.message.ChannelOpenOkFrame;
import rabbitmq.message.ExchangeDeclareOkFrame;

interface Connection
{
    /**
     * Creates a communication channel.
     */
    public Channel channel();

    public bool process(BasicConsumeOkFrame frame);
    public bool process(BasicDeliverFrame frame);
    public bool process(BasicHeaderFrame frame);
    public bool process(BodyFrame frame);
    public bool process(ConnectionStartFrame frame);
    public bool process(ConnectionTuneFrame frame);
    public bool process(ConnectionOpenOkFrame frame);
    public bool process(ChannelOpenOkFrame frame);
    public bool process(ExchangeDeclareOkFrame frame);
}