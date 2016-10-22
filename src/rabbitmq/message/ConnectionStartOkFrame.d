module rabbitmq.message.ConnectionStartOkFrame;

import rabbitmq.message.ConnectionFrame;
import rabbitmq.message.Field;

struct ConnectionStartOkFrame
{
    ConnectionFrame connectionFrame;
    alias connectionFrame this;

    Field[string] properties;
    ShortString mechanism;
    LongString response;
    ShortString locale;

    @disable this();

    public this(Field[string] properties, string mechanism, string response, string locale)
    {
        uint size = cast(uint)(mechanism.length + response.length + locale.length + 6 + properties.wireSize);

        this.connectionFrame = ConnectionFrame(size, 11);
        this.properties = properties;
        this.mechanism = ShortString(mechanism);
        this.response = LongString(response);
        this.locale = ShortString(locale);
    }

    public void serialize(ref ubyte[] buffer)
    {
        connectionFrame.serialize(buffer);
        buffer.serialize(properties)
            .serialize(mechanism)
            .serialize(response)
            .serialize(locale)
            .serialize(ubyte(0xce));
    }
}