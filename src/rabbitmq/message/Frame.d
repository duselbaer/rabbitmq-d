module rabbitmq.message.Frame;

import rabbitmq.message.Field;

struct Frame
{
    public byte type;
    public short channel;
    public uint size;
    
    public string toString() const
    {
        import std.format : format;

        return "%s(type=%s, channel=%s, size=%s)".format(Frame.stringof, this.type, this.channel, this.size);
    }

    public void serialize(ref ubyte[] buffer)
    {
        buffer.serialize(this.type).serialize(this.channel).serialize(this.size);
    }
}