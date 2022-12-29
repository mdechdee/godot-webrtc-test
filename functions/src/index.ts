import * as functions from "firebase-functions";
import {hostRoom} from "./hostRoom";
import {storeMessage} from "./storeMessage";

export const helloWorld = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest((req, res) => {
      console.log(req.path);
      if (req.path === "/hostRoom") {
        hostRoom(req, res);
      } else if (req.method === "POST" && req.path === "/storeMessage") {
        storeMessage(req, res);
      } else res.send("Invalid path");
    });
