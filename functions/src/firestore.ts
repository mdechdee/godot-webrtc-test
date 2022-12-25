import * as dotenv from "dotenv";
dotenv.config();
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {strict as assert} from "node:assert";

// FUNCTION_NAME exists only in deployment, if dev use .env
const key = process.env.FUNCTION_NAME ?
  functions.config().secrets.PRIVATE_KEY_JSON :
  process.env.PRIVATE_KEY_JSON;

assert(key);
admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(key)),
});

export const firestore = admin.firestore();
