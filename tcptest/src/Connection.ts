import * as net from "net";

export default class Connection {
    client: net.Socket
    constructor (host: string, port: number, onConnect:() => void , onData:() => void){
        console.log(port, host);
        this.client = new net.Socket();
        this.client.connect(port, host, () => {
            console.log('Connected');
            let client = this.client 
            let addrInfo = client.address() as net.AddressInfo
            setInterval(() => {
                var success = this.client.write("Hello From Client " + addrInfo.address);
                console.log("Hello sended", success)
            }, 10000)
        });
        
        this.client.on('data', function(data) {
            console.log('Server Says : ' + data);
        });
    }
}

