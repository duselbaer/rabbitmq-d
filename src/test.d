import asynchronous;
import rabbitmq.asynchronous.Connection : Connection;
import std.datetime : seconds;

struct TestHelper
{

}

@Coroutine
void subscribe(T)(T channel)
{
    void handleMessage(string messageBody)
    {
        import std.stdio : writefln;

        writefln("GOT MESSAGE: %s", messageBody);
    }

    channel.basicConsume(a => handleMessage(a), "PASSENGER_INFORMATION");
}

@Coroutine
void publishMessage(T)(T channel)
{
    channel.basicPublish("MY_EXCHANGE", "1", "Hello World");

    getEventLoop.callLater(1.seconds, () => subscribe(channel));
}

@Coroutine
void declareExchange(T)(T channel)
{
    channel.exchangeDeclare("MY_EXCHANGE", "fanout");

    getEventLoop.callLater(1.seconds, () => publishMessage(channel));
}

@Coroutine
void connectChannel(T)(T connection)
{
    auto channel = connection.channel;

    getEventLoop.callLater(1.seconds, () => declareExchange(channel));
}

@Coroutine
void createConnection(EventLoop loop)
{
    auto connection = Connection.createConnection(loop, "localhost");

    loop.callLater(1.seconds, () => connectChannel(connection));
}

void main(string[] args)
{
    import rabbitmq.asynchronous.Connection : Connection;

    auto loop = getEventLoop;
    auto testHelper = TestHelper();

    loop.runUntilComplete(loop.createTask(() => createConnection(loop)));
    import std.stdio; writeln("X");
    loop.runForever;
}