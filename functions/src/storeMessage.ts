import * as functions from "firebase-functions";
import {firestore} from "./firestore";

interface RequestBody {
  roomId: string,
  message: {[key: string]: string | number}
}

export const storeMessage = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      const {roomId, message}: RequestBody = req.body;

      const peerDocRef = await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(message.dst.toString());
      const snap = await peerDocRef.get();

      const messages = snap.get("messages") ?? [];
      await peerDocRef.update({messages: [...messages, message]});

      res.status(200).send("store message done");
    });
