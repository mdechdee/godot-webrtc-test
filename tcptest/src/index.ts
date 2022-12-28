import Connection from "./Connection";

var connections:Array<Connection> = []

for(let i=0; i<2; i++){
    var cnn = new Connection("127.0.0.1", 7070+i, ()=>{}, ()=>{})
    connections.push(cnn)
}