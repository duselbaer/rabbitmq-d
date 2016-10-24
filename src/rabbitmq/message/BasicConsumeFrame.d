module rabbitmq.message.BasicConsumeFrame;

import rabbitmq.message.BasicFrame;
import rabbitmq.message.Field;

struct BasicConsumeFrame
{
    BasicFrame basicFrame;
    alias basicFrame this;

    ushort deprecatedValue = 0;
    ShortString queueName;
    ShortString consumerTag;
    ubyte bools;
    Field[string] filter;

    @disable this();

    public this(ushort channel, string queueName, string consumerTag, ubyte bools, Field[string] filter)
    {
        this.queueName = ShortString(queueName);
        this.consumerTag = ShortString(consumerTag);
        this.bools = bools;
        this.filter = filter;

        uint size = this.deprecatedValue.wireSize +
                this.queueName.wireSize +
                this.consumerTag.wireSize +
                this.bools.wireSize +
                this.filter.wireSize;

        this.basicFrame = BasicFrame(channel, size, 20);
    }

    public void serialize(ref ubyte[] buffer)
    {
        basicFrame.serialize(buffer);
        buffer.serialize(deprecatedValue)
            .serialize(this.queueName)
            .serialize(this.consumerTag)
            .serialize(this.bools)
            .serialize(this.filter)
            .serialize(ubyte(0xce));
    }
}