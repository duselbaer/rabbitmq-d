module rabbitmq.message.BasicHeaderFrame;

import rabbitmq.message.HeaderFrame;
import rabbitmq.message.Field;

struct BasicHeaderFrame
{
    HeaderFrame headerFrame;
    alias headerFrame this;

    ushort weight;
    ulong bodySize;
    ubyte bools1;
    ubyte bools2;

    @disable this();

    public this(ushort channel, ushort weight, ulong bodySize)
    {
        this.weight = weight;
        this.bodySize = bodySize;

        uint size = this.weight.wireSize +
                this.bodySize.wireSize +
                this.bools1.wireSize +
                this.bools2.wireSize;

        this.headerFrame = HeaderFrame(channel, 60, size);
    }

    public void serialize(ref ubyte[] buffer)
    {
        headerFrame.serialize(buffer);
        buffer.serialize(this.weight)
            .serialize(this.bodySize)
            .serialize(this.bools1)
            .serialize(this.bools2)
            .serialize(ubyte(0xce));
    }
}