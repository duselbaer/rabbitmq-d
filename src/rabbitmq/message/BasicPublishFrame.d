module rabbitmq.message.BasicPublishFrame;

import rabbitmq.message.BasicFrame;
import rabbitmq.message.Field;

struct BasicPublishFrame
{
    BasicFrame basicFrame;
    alias basicFrame this;

    ushort deprecatedValue;
    ShortString exchange;
    ShortString routingKey;
    ubyte bools;

    @disable this();

    public this(ushort channel, string exchange, string routingKey, ubyte bools)
    {
        this.exchange = ShortString(exchange);
        this.routingKey = ShortString(routingKey);
        this.bools = bools;

        uint size = this.deprecatedValue.wireSize +
                this.exchange.wireSize +
                this.routingKey.wireSize +
                this.bools.wireSize;

        this.basicFrame = BasicFrame(channel, size, 40);
    }

    public void serialize(ref ubyte[] buffer)
    {
        basicFrame.serialize(buffer);
        buffer.serialize(deprecatedValue)
            .serialize(this.exchange)
            .serialize(this.routingKey)
            .serialize(this.bools)
            .serialize(ubyte(0xce));
    }
}