module rabbitmq.message.ExchangeDeclareFrame;

import rabbitmq.message.ExchangeFrame;
import rabbitmq.message.Field;

struct ExchangeDeclareFrame
{
    ExchangeFrame exchangeFrame;
    alias exchangeFrame this;

    ushort deprecatedField;
    ShortString name;
    ShortString type;
    ubyte bools;
    Field[string] arguments;

    @disable this();

    public this(ushort channel, string name, string type, ubyte bools, Field[string] arguments)
    {
        this.name = ShortString(name);
        this.type = ShortString(type);
        this.bools = bools;
        this.arguments = arguments;

        uint size = this.deprecatedField.wireSize +
                this.name.wireSize +
                this.type.wireSize + 
                this.bools.wireSize +
                this.arguments.wireSize;

        this.exchangeFrame = ExchangeFrame(channel, size, 10);
    }

    public void serialize(ref ubyte[] buffer)
    {
        exchangeFrame.serialize(buffer);
        buffer.serialize(this.deprecatedField)
            .serialize(this.name)
            .serialize(this.type)
            .serialize(this.bools)
            .serialize(this.arguments)
            .serialize(ubyte(0xce));
    }
}