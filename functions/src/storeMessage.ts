import * as functions from "firebase-functions";
import {firestore} from "./firestore";
import {Messages} from "./types";

interface RequestBody {
  roomId: string,
  message: string
}

export const storeMessage = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.body);
      const {roomId, message}: RequestBody = req.body;
      const [type, fromId, toId, rtcMessage] = message.split("\n", 4);

      const peerDocRef = await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(toId);
      const snap = await peerDocRef.get();
      const newMsg = `${fromId}\n${rtcMessage}`;

      if (type === "C") {
        const candidates = snap.get("candidates") ?? [];
        await peerDocRef.update({candidates: [...candidates, newMsg]});
      } else if (type === "O") {
        const offers = snap.get("offers") ?? [];
        await peerDocRef.update({offers: [...offers, newMsg]});
      } else if (type === "A") {
        const answers = snap.get("answers") ?? [];
        await peerDocRef.update({answers: [...answers, newMsg]});
      }
      res.status(200).send("store message done");
    });
