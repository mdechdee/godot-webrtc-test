const net = require('net');
const client = new net.Socket();
const port = 7070;
const host = '127.0.0.1';

client.connect(port, host, function() {
    console.log('Connected');
    client.write("Hello From Client " + client.address().address);
    setInterval(() => {
        var success = client.write("Hello From Client " + client.address().address);
        console.log("Hello sended", success)
    }, 1000)
});