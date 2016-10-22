module rabbitmq.message.BodyFrame;

import rabbitmq.message.Field;
import rabbitmq.message.Frame;

struct BodyFrame
{
    Frame frame;
    alias frame this;

    string content;

    @disable this();

    this(ushort channel, string content)
    {
        this.content = content;

        this.frame = Frame(3, channel, cast(uint)(content.length));
    }

    public void serialize(ref ubyte[] buffer)
    {
        frame.serialize(buffer);
        buffer.serialize(this.content)
            .serialize(ubyte(0xce));
    }
}