module rabbitmq.control.Connection;

import rabbitmq.control.Channel;
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

    public bool process(ConnectionStartFrame frame);
    public bool process(ConnectionTuneFrame frame);
    public bool process(ConnectionOpenOkFrame frame);
    public bool process(ChannelOpenOkFrame frame);
    public bool process(ExchangeDeclareOkFrame frame);
}