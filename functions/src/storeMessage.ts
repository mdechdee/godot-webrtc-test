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
      const {type, src, dst} = message;
      console.log(type, src, dst);

      const peerDocRef = await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(dst.toString());
      const snap = await peerDocRef.get();

      if (type === "candidate") {
        const candidates = snap.get("candidates") ?? [];
        await peerDocRef.update({candidates: [...candidates, message]});
      } else if (type === "offer") {
        const offers = snap.get("offers") ?? [];
        await peerDocRef.update({offers: [...offers, message]});
      } else if (type === "answer") {
        const answers = snap.get("answers") ?? [];
        await peerDocRef.update({answers: [...answers, message]});
      }
      res.status(200).send("store message done");
    });
