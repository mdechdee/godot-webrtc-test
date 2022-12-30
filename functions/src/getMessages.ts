import * as functions from "firebase-functions";
import {firestore} from "./firestore";
import * as assert from "node:assert";

export const getMessages = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.query);
      const roomId= String(req.query.roomId);
      const peerId =String(req.query.peerId);
      assert(typeof roomId === "string");
      assert(typeof peerId === "string");
      const peerDoc = await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(peerId);
      const messages = (await peerDoc.get()).data();
      console.log(messages);
      res.status(200).send(messages);
    });
