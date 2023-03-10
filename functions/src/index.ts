import * as functions from "firebase-functions";
import {getMessages} from "./getMessages";
import {getPeers} from "./getPeers";
import {hostRoom} from "./hostRoom";
import {joinRoom} from "./joinRoom";
import {storeMessage} from "./storeMessage";

export const helloWorld = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest((req, res) => {
      console.log(req.path);
      if (req.method === "POST" && req.path === "/hostRoom") {
        hostRoom(req, res);
      } else if (req.method === "POST" && req.path === "/joinRoom") {
        joinRoom(req, res);
      } else if (req.method === "POST" && req.path === "/storeMessage") {
        storeMessage(req, res);
      } else if (req.method === "GET" && req.path === "/getPeers") {
        getPeers(req, res);
      } else if (req.method === "GET" && req.path === "/getMessages") {
        getMessages(req, res);
      } else res.send("Invalid path");
    });
