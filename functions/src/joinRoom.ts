import * as functions from "firebase-functions";
import {firestore} from "./firestore";

interface RequestBody {
  peerId: number
  roomId: string
}

export const joinRoom = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.body);
      const {peerId, roomId}: RequestBody = req.body;
      await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(peerId.toString())
          .set({messages: []});
      res.status(200).send("Join room done");
    });
