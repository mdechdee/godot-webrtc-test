import * as functions from "firebase-functions";
import {firestore} from "./firestore";
import {faker} from "@faker-js/faker";

export const hostRoom = functions
    .region("asia-southeast1")
    .runWith({memory: "128MB"})
    .https.onRequest(async (req, res) => {
      const roomId = faker.random.alphaNumeric(5, {casing: "upper"});
      await firestore.collection("rooms").doc(roomId).set({
        messages: [],
      });
      res.send(`${roomId}`);
    });
