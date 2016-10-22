module rabbitmq.message.Field;

import std.datetime : SysTime;
import std.variant;

interface Field
{
}

struct ShortString
{
    public string s;

    alias s this;
}

struct LongString
{
    public string s;

    alias s this;
}

class SimpleField(T) : Field
{
    private T value_;

    public this(T value)
    {
        this.value_ = value;
    }

    public override string toString() const
    {
        import std.format : format;

        return "%s".format(this.value_);
    }

    public T value()
    {
        return this.value_;
    }
}

class WireSizeCalculator
{
    uint size = 0;

    public void visit(SimpleField!ubyte field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!byte field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!ushort field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!short field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!uint field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!int field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!ulong field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!long field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!ShortString field) { this.size += 1 + field.value.wireSize; }
    public void visit(SimpleField!LongString field) { this.size += 1 + field.value.wireSize; }
}

uint wireSize(Field field)
{
    import util.VisitorPattern : accept;

    WireSizeCalculator calculator = new WireSizeCalculator;

    field.accept(calculator);

    return calculator.size;
}

uint wireSize(Field[string] table)
{
    uint size = 4; // uint indicating the number of bytes
    
    foreach(entry; table.byKeyValue)
    {
        size += 1; // ubyte indicating the length of the key
        size += entry.key.length;
        size += entry.value.wireSize;
    }

    return size;
}

uint wireSize(T)(T value) if (is(T == ubyte) || is(T == byte))
{
    return 1;
}

uint wireSize(T)(T value) if (is(T == ushort) || is(T == short))
{
    return 2;
}

uint wireSize(T)(T value) if (is(T == uint) || is(T == int))
{
    return 4;
}

uint wireSize(T)(T value) if (is(T == ulong) || is(T == long))
{
    return 8;
}

uint wireSize(T)(T value) if (is(T == ShortString))
{
    return cast(uint)(1 + value.length);
}

uint wireSize(T)(T value) if (is(T == LongString))
{
    return cast(uint)(4 + value.length);
}

unittest
{
    assert(5 == LongString("X").wireSize);
    assert(2 == ShortString("X").wireSize);
}

unittest
{
    Field field = null;

    field = new SimpleField!ubyte(42);
    assert(2 == field.wireSize);

    field = new SimpleField!byte(42);
    assert(2 == field.wireSize);

    field = new SimpleField!ushort(42);
    assert(3 == field.wireSize);

    field = new SimpleField!short(42);
    assert(3 == field.wireSize);

    field = new SimpleField!uint(42);
    assert(5 == field.wireSize);

    field = new SimpleField!int(42);
    assert(5 == field.wireSize);

    field = new SimpleField!ulong(42);
    assert(9 == field.wireSize);

    field = new SimpleField!long(42);
    assert(9 == field.wireSize);

    field = new SimpleField!ShortString(ShortString("X"));
    assert(3 == field.wireSize);

    field = new SimpleField!LongString(LongString("X"));
    assert(6 == field.wireSize);
}

class FieldSerializer
{
    ubyte[] buffer = null;

    public void visit(SimpleField!ubyte field) { buffer.serialize(cast(ubyte)('B')).serialize(field.value); }
    public void visit(SimpleField!byte field) { buffer.serialize(cast(ubyte)('b')).serialize(field.value); }
    public void visit(SimpleField!ushort field) { buffer.serialize(cast(ubyte)('u')).serialize(field.value); }
    public void visit(SimpleField!short field) { buffer.serialize(cast(ubyte)('U')).serialize(field.value); }
    public void visit(SimpleField!uint field) { buffer.serialize(cast(ubyte)('i')).serialize(field.value); }
    public void visit(SimpleField!int field) { buffer.serialize(cast(ubyte)('I')).serialize(field.value); }
    public void visit(SimpleField!ulong field) { buffer.serialize(cast(ubyte)('l')).serialize(field.value); }
    public void visit(SimpleField!long field) { buffer.serialize(cast(ubyte)('L')).serialize(field.value); }
    public void visit(SimpleField!ShortString field) { buffer.serialize(cast(ubyte)('s')).serialize(field.value); }
    public void visit(SimpleField!LongString field) { buffer.serialize(cast(ubyte)('S')).serialize(field.value); }
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == Field[string]))
{
    buffer.serialize(value.wireSize - 4);
    
    foreach (entry; value.byKeyValue)
    {
        buffer.serialize(ShortString(entry.key));

    }

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == ShortString))
{
    assert(value.length <= 255);

    buffer.serialize(cast(ubyte)(value.length));
    buffer.serialize(value.s);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == LongString))
{
    buffer.serialize(cast(uint)(value.length));
    buffer.serialize(value.s);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == string))
{
    buffer ~= cast(ubyte[])(value);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == ubyte) || is(T == byte))
{
    buffer ~= cast(ubyte)(value);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == ushort) || is(T == short))
{
    auto casted = cast(ushort)(value);

    buffer ~= cast(ubyte)((casted & 0xFF00) >> 8);
    buffer ~= cast(ubyte)(casted & 0x00FF);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == uint) || is(T == int))
{
    auto casted = cast(uint)(value);

    buffer ~= cast(ubyte)((casted & 0xFF000000) >> 24);
    buffer ~= cast(ubyte)((casted & 0x00FF0000) >> 16);
    buffer ~= cast(ubyte)((casted & 0x0000FF00) >> 8);
    buffer ~= cast(ubyte)(casted & 0x000000FF);

    return buffer;
}

public ref ubyte[] serialize(T)(ref ubyte[] buffer, T value) if (is(T == ulong) || is(T == long))
{
    auto casted = cast(ulong)(value);

    buffer ~= cast(ubyte)((casted & 0xFF00000000000000) >> 56);
    buffer ~= cast(ubyte)((casted & 0x00FF000000000000) >> 48);
    buffer ~= cast(ubyte)((casted & 0x0000FF0000000000) >> 40);
    buffer ~= cast(ubyte)((casted & 0x000000FF00000000) >> 32);
    buffer ~= cast(ubyte)((casted & 0x00000000FF000000) >> 24);
    buffer ~= cast(ubyte)((casted & 0x0000000000FF0000) >> 16);
    buffer ~= cast(ubyte)((casted & 0x000000000000FF00) >> 8);
    buffer ~= cast(ubyte)(casted & 0x00000000000000FF);

    return buffer;
}