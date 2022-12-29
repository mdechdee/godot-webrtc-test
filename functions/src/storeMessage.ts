import * as functions from "firebase-functions";
import {firestore} from "./firestore";

export const storeMessage = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.body);
      const {roomId, message} = req.body;
      const snap = await firestore.collection("rooms").doc(roomId).get();
      console.log(snap.get("messages"));
      const messages = snap.get("messages") ?? [];
      await firestore.collection("rooms").doc(roomId).set({
        messages: [...messages, message],
      });
      res.status(200).send("store message done");
    });
