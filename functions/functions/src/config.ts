// Initialize Firebase Admin
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

export const fcm = admin.messaging();

// Initialize Cloud Firestore Database
export const db = admin.firestore();
const settings = { timestampsInSnapshots: true };
db.settings(settings);

export const storage = admin.storage();

// ENV Variables
export const stripeSecret = functions.config().stripe.secret;


import Stripe from 'stripe';
export const stripe = new Stripe(stripeSecret, {
    apiVersion: '2020-08-27',typescript:true
}); // TODO Set as Firebase environment variable