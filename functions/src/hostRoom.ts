import * as functions from "firebase-functions";
import {firestore} from "./firestore";
import {faker} from "@faker-js/faker";
interface RequestBody {
  peerId: number
}

export const hostRoom = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      console.log(req.body);
      const {peerId}: RequestBody = req.body;
      const roomId = faker.random.alphaNumeric(5, {casing: "upper"});
      await firestore
          .collection("rooms").doc(roomId)
          .collection("peers").doc(peerId.toString())
          .set({offers: [], answers: [], candidates: []});
      res.send(`${roomId}`);
    });
