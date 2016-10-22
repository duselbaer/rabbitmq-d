module rabbitmq.message.ConnectionStartFrame;

import rabbitmq.control.Connection : Connection;
import rabbitmq.asynchronous.Connection : FrameReceiver;
import rabbitmq.message.Field;

struct ConnectionStartFrame
{
    ubyte majorVersion;
    ubyte minorVersion;
    Field[string] serverProperties;
    string mechanisms;
    string locales;

    @disable this();

    this(ref FrameReceiver frameReceiver)
    {
        this.majorVersion = frameReceiver.nextByte;
        this.minorVersion = frameReceiver.nextByte;
        this.serverProperties = frameReceiver.nextTable;
        this.mechanisms = frameReceiver.nextLongString;
        this.locales = frameReceiver.nextLongString;
    }

    bool process(Connection connection)
    {
        return connection.process(this);
    }
}