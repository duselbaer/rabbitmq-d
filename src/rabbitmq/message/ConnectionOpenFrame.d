module rabbitmq.message.ConnectionOpenFrame;

import rabbitmq.message.ConnectionFrame;
import rabbitmq.message.Field;

struct ConnectionOpenFrame
{
    ConnectionFrame connectionFrame;
    alias connectionFrame this;

    ShortString vhost;

    @disable this();

    public this(string vhost)
    {
        uint size = cast(uint)(vhost.length + 3);

        this.connectionFrame = ConnectionFrame(size, 40);
        this.vhost = ShortString(vhost);
    }

    public void serialize(ref ubyte[] buffer)
    {
        connectionFrame.serialize(buffer);
        buffer.serialize(this.vhost)
            .serialize(ubyte(0))
            .serialize(ubyte(0))
            .serialize(ubyte(0xce));
    }
}