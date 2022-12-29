import * as functions from "firebase-functions";
import {firestore} from "./firestore";
import * as assert from "node:assert";

export const getPeers = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.query);
      const roomId= String(req.query.roomId);
      assert(typeof roomId === "string");
      const peerDocs = await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").listDocuments();
      const peerIds = peerDocs.map((peerDoc) => {
        return peerDoc.id;
      });
      console.log(peerIds);
      res.status(200).send(peerIds);
    });
