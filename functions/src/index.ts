import * as functions from "firebase-functions";
import {hostRoom} from "./hostRoom";

export const helloWorld = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest((req, res) => {
      if (req.path === "/hostRoom") hostRoom(req, res);
      else res.send("Invalid path");
    });
