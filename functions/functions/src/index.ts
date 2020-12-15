import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {assert, assertUID} from './helpers';
import {getOrCreateCustomer, getUser} from './customers';
import {storage, db, fcm} from './config';


import Stripe from 'stripe';


export const stripeSecret = functions.config().stripe.secret;

const stripe = new Stripe(stripeSecret, {
    apiVersion: '2020-08-27', typescript: true
});

exports.retrievePromotionCode = functions.region('europe-west1').https.onCall(async (data, context) => {

    const code = assert(data, 'code')

    const promotionCode = await stripe.promotionCodes.list({
        limit: 1,
        code: code,
        active: true,
    });

    if (promotionCode.data[0] == null) {
        throw new functions.https.HttpsError('not-found', `function called with an unknown code: ${code}`);
    }
    return promotionCode;
});

exports.paymentIntentUploadEvents = functions.region('europe-west1').https.onCall(async (data, context) => {
    const amount = assert(data, 'amount');

    const description = assert(data, 'description');
    const paymentMethodId = assert(data, 'paymentMethodId');
    const uid = assertUID(context);
    const user = await getUser(uid);
    const customer = await getOrCreateCustomer(uid);
    const promotionCodeId = data['idPromotionCode'];

    const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: 'eur',
        payment_method_types: ['card'],
        customer: customer.id,
        payment_method: paymentMethodId,
        metadata: {uid: uid},
        confirm: true,
        receipt_email: user!.email,
        description: description,
    });

    if (paymentIntent.status === 'succeeded' && promotionCodeId != null) {
        await stripe.customers.update(
            customer.id,
            {promotion_code: promotionCodeId}
        );
    }

    console.log(paymentIntent.status);

    return paymentIntent;

});


exports.paymentIntent = functions.region('europe-west1').https.onCall(async (data, context) => {
    const amount = assert(data, 'amount');
    const stripeAccount = assert(data, 'stripeAccount')
    const description = assert(data, 'description');
    const paymentMethodId = assert(data, 'paymentMethodId');
    const uid = assertUID(context);
    const user = await getUser(uid);
    const customer = await getOrCreateCustomer(uid);
    //const transportAmount = assert(data,'transportAmount');
    const promotionCodeId = data['idPromotionCode'];
    const nbParticipant = assert(data, 'nbParticipant');

    const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: 'eur',
        payment_method_types: ['card'],
        customer: customer.id,
        payment_method: paymentMethodId,
        metadata: {uid: uid},
        confirm: true,
        receipt_email: user!.email,
        description: description,
        application_fee_amount: 100 * nbParticipant,
        on_behalf_of: stripeAccount,
        transfer_data: {
            destination: stripeAccount
        }
    });

    if (paymentIntent.status === 'succeeded' && promotionCodeId != null) {
        await stripe.customers.update(
            customer.id,
            {promotion_code: promotionCodeId}
        );
    }

    console.log(paymentIntent.status);

    return paymentIntent;

});

exports.paymentIntentAuthorize = functions.region('europe-west1').https.onCall(async (data, context) => {
    const amount = assert(data, 'amount');
    const description = assert(data, 'description');
    const paymentMethodId = assert(data, 'paymentMethodId');
    const uid = assertUID(context);
    const user = await getUser(uid);
    const customer = await getOrCreateCustomer(uid);

    const paymentIntent = await stripe.paymentIntents.create({
        amount: amount,
        currency: 'eur',
        payment_method_types: ['card'],
        capture_method: 'manual',
        customer: customer.id,
        payment_method: paymentMethodId,
        metadata: {uid: uid},
        confirm: true,
        receipt_email: user!.email,
        description: description,

    });

    console.log(paymentIntent.status);

    return paymentIntent;

});

exports.paymentIntentCaptureFunds = functions.region('europe-west1').https.onCall(async (data, context) => {
    const amount = data['amount'];

    const paymentMethodId = assert(data, 'paymentMethodId');

    if (amount != null) {
        return await stripe.paymentIntents.capture(paymentMethodId, {
            amount_to_capture: amount
        });

    } else {
        return await stripe.paymentIntents.capture(paymentMethodId, {});
    }


});


exports.uploadFileToStripe = functions.region('europe-west1').https.onCall(async (data, context) => {

    const bucket = storage.bucket('van-event.appspot.com');
    const path = require('path');
    const os = require('os');
    const fs = require('fs');
    const fileName: string = assert(data, 'fileName');
    const stripeAccount = assert(data, 'stripeAccount');
    const person = assert(data, 'person');
    const tempFilePath = path.join(os.tmpdir(), fileName);
    await bucket.file(fileName).download({destination: tempFilePath});

    console.log('File created at', tempFilePath);

    const fileUpload = await stripe.files.create({
        purpose: 'identity_document',
        file: {
            data: fs.readFileSync(tempFilePath),
            name: 'fileUploadDoc.png',
            type: 'application/octet-stream',
        },
    });

    fileName.startsWith('back') ?
        await stripe.accounts.updatePerson(
            stripeAccount,
            person,
            {
                verification: {
                    document: {
                        back: fileUpload.id
                    }
                }
            }
        ) : fileName.startsWith('front') ? await stripe.accounts.updatePerson(
        stripeAccount,
        person,
        {
            verification: {
                document: {
                    front: fileUpload.id
                }
            }
        }
        ) : await stripe.accounts.updatePerson(//justificatif de domicile
        stripeAccount,
        person,
        {
            verification: {
                additional_document: {
                    front: fileUpload.id
                }
            }
        }
        );
    const account_token = await stripe.tokens.create(
        {
            account: {
                company: {
                    owners_provided: true,
                    directors_provided: true,
                    executives_provided: true,
                }
            }
        }
    )

    return await stripe.accounts.update(
        stripeAccount,
        {
            account_token: account_token.id
        }
    )

});


exports.createStripeAccount = functions.region('europe-west1').https.onCall(async (data, context) => {

    const email = assert(data, 'email')
    const nomSociete = assert(data, 'nomSociete');
    const business_type = assert(data, 'business_type')
    const support_email = assert(data, 'support_email');
    const phone = assert(data, 'phone');
    const url = data['url'];
    const city = assert(data, 'city');
    const line1 = assert(data, 'line1');
    const line2 = data['line2'];
    const postal_code = assert(data, 'postal_code');
    const state = assert(data, 'state');
    const account_holder_name = assert(data, 'account_holder_name');
    const account_holder_type = assert(data, 'account_holder_type');
    const account_number = assert(data, 'account_number');//IBAN
    const SIREN = assert(data, 'siren');
    const first_name = assert(data, 'first_name');
    const last_name = assert(data, 'last_name');
    const date_of_birth: string = assert(data, 'date_of_birth');

    const external_account = await stripe.tokens.create({
        bank_account: {
            country: 'FR',
            currency: 'eur',
            account_holder_name: account_holder_name,
            account_holder_type: account_holder_type,
            account_number: account_number,
        },
    });

    console.log('try account and person');

    const accountResult = await stripe.tokens.create({
        account: {
            business_type: business_type,
            company: {
                name: nomSociete,
                phone: phone,
                tax_id: SIREN,
                address: {
                    line1: line1,
                    line2: line2,
                    city: city,
                    state: state,
                    postal_code: postal_code,
                },
            },
            tos_shown_and_accepted: true,
        }
    });

    console.log(accountResult.id);


    const createStripeAccount = await stripe.accounts.create({
        country: 'FR',
        type: 'custom',
        account_token: accountResult.id,
        email: email,
        capabilities: {
            card_payments: {requested: true},
            transfers: {requested: true},
        },
        external_account: external_account.id,
        default_currency: 'EUR',
        business_profile: {
            name: nomSociete,
            support_phone: phone,
            support_email: support_email,
            product_description: 'Des billets pour des évènement, pour les utilisateurs de l\'application, débit au moment de l\'achat.',
            url: url,
            mcc: '8999'
        },
    });

    const year = date_of_birth.substring(0, 4);
    const month = date_of_birth.substring(5, 7);
    const day = date_of_birth.substring(8)

    const dob: any = {
        day: day,
        month: month,
        year: year,
    };

    const person = await stripe.accounts.createPerson(
        createStripeAccount.id,
        {
            first_name: first_name,
            last_name: last_name,
            email: email,
            phone: phone,
            dob: dob,
            address: {
                line1: line1,
                line2: line2,
                city: city,
                state: state,
                postal_code: postal_code,
            },
            relationship: {
                owner: true,
                representative: true,
                title: 'CEO',
            }
        }
    );

    console.log(createStripeAccount.id);
    console.log(person.id);


    return {
        stripeAccount: createStripeAccount.id,
        person: person.id
    };

});

exports.allStripeAccounts = functions.region('europe-west1').https.onCall(async (data, context) => {

    return stripe.accounts.list();

});

exports.retrieveStripeAccount = functions.region('europe-west1').https.onCall(async (data, context) => {
    const stripeAccount = assert(data, 'stripeAccount');

    return await stripe.accounts.retrieve(
        stripeAccount
    );

});

exports.updateStripeAccount = functions.region('europe-west1').https.onCall(async (data, context) => {

    const stripeAccount = assert(data, 'stripeAccount');

    const email = data['email'];
    const nomSociete = data['nomSociete'];
    const business_type = data['business_type'];
    const support_email = data['support_email'];
    const phone = data['phone'];
    const url = data['url'];
    const support_url = data['support_url'];
    const city = data['city'];
    const country = data['country'];
    const line1 = data['line1'];
    const line2 = data['line2'];
    const postal_code = data['postal_code'];
    const state = data['state'];
    const account_holder_name = data['account_holder_name'];
    const account_holder_type = data['account_holder_type'];
    const account_number = data['account_number'];//IBAN

    if (account_holder_name || account_holder_type || account_number) {

        const external_account = await stripe.tokens.create({
            bank_account: {
                country: 'FR',
                currency: 'eur',
                account_holder_name: account_holder_name,
                account_holder_type: account_holder_type,
                account_number: account_number,
            },
        });

        await stripe.accounts.updateExternalAccount(
            stripeAccount,
            external_account.bank_account?.id as string,
        );

    }

    const createStripeAccount = await stripe.accounts.update(stripeAccount, {
        email: email,
        capabilities: {
            card_payments: {requested: true},
            transfers: {requested: true},
        },
        default_currency: 'EUR',
        business_profile: {
            name: nomSociete,
            support_phone: phone,
            support_email: support_email,
            product_description: 'Des billets pour des évènement, pour les utilisateurs de l\'application, débit au moment de l\'achat.',
            url: url,
            support_url: support_url,
        },
        business_type: business_type,
        company: {
            address: {
                city: city,
                line1: line1,
                line2: line2,
                postal_code: postal_code,
                country: country,
                state: state,
            },
        },
    });

    console.log(createStripeAccount)
    return createStripeAccount;
});

exports.deleteStripeAccount = functions.region('europe-west1').https.onCall(async (data, context) => {

    const stripeAccount = assert(data, 'stripeAccount');
    return await stripe.accounts.del(
        stripeAccount
    );

});

exports.balance = functions.region('europe-west1').https.onCall(async (data, context) => {

    const stripeAccount = assert(data, 'stripeAccount');
    return await stripe.balance.retrieve(
        {stripeAccount: stripeAccount}
    );

});

exports.payout = functions.region('europe-west1').https.onCall(async (data, context) => {

    const amount = assert(data, 'amount');
    const stripeAccount = assert(data, 'stripeAccount');

    return await stripe.payouts.create({
        amount: amount,
        currency: 'eur',
        source_type: 'bank_account',

    }, {
        stripeAccount: stripeAccount
    });

});

exports.payoutList = functions.region('europe-west1').https.onCall(async (data, context) => {

    const stripeAccount = assert(data, 'stripeAccount');

    return stripe.payouts.list({}, {
        stripeAccount: stripeAccount
    });

});


exports.transfersList = functions.region('europe-west1').https.onCall(async (data, context) => {

    const stripeAccount = assert(data, 'stripeAccount');

    return stripe.transfers.list({},
        {stripeAccount: stripeAccount}
    );
});

exports.retrievePerson = functions.region('europe-west1').https.onCall(async (data, context) => {

    const person = assert(data, 'person');
    const stripeAccount = assert(data, 'stripeAccount');

    return await stripe.accounts.retrievePerson(
        stripeAccount,
        person,
    );

});

exports.sendTransport = functions.region('europe-west1').firestore
    .document('transports/{transportId}')
    .onCreate(async (snap, context) => {
        console.log(`----------------start function--------------------`)

        const transportId = context.params.transportId;

        console.log(`Le transportId : ${transportId}`)

        const doc = snap.data()

        const ville = doc!.adresseZone[0]
        const nbPersonne = doc!.nbPersonne
        const dateTime: Date = doc!.dateTime.toDate()
        console.log(dateTime.toJSON)

        const date = dateTime.toJSON().slice(0, 10).split('-').reverse().join('/');

        // Get push token user to (receive)
        const querySnapshot = await db.collection('users').doc('269idfQJ8Bg1QpfjXP5equkzahJ3')
            .collection('tokens').get();

        const tokens = querySnapshot.docs.map((snap: { id: any; }) => snap.id);

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: `Nouvelle demande de transport`,
                body: `À: ${ville}, pour ${nbPersonne} personne, le ${date}`,
                badge: '1',
                tag: snap.id,
                click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
            },
        };

        return fcm.sendToDevice(tokens, payload);

    });


exports.sendMessages = functions.region('europe-west1').firestore
    .document('chats/{chatId}/messages/{message}')
    .onCreate(async (snap, context) => {
        console.log(`----------------start function--------------------`)

        const chatId = context.params.chatId;

        console.log(`Le chatId : ${chatId}`)

        const doc = snap.data()
        const idFrom = doc!.idFrom
        const idTo = doc!.idTo
        const contentMessage = doc!.message
        const date = doc!.date.toDate()
        const type = doc!.type
        const replyMessageId = doc!.replyMessageId
        const replyType = doc!.replyType


        if (idTo != null) {
            // Get push token user to (receive)
            const querySnapshot = await db.collection('users').doc(idTo).collection('tokens').get();

            const tokens = querySnapshot.docs.map((snap: { id: any; }) => snap.id);

            // Get info user from (sent)
            const userFrom = await db.collection('users').doc(idFrom).get();
            console.log(`Found user from: ${userFrom.data()!.nom}`)

            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: `Nouveau message de: ${userFrom.data()!.nom}`,
                    body: contentMessage,
                    badge: '1',
                    tag: chatId,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
                },
                data: {
                    chatId: chatId,
                    type: type.toString(),
                    idFrom: idFrom,
                    idTo: idTo,
                    date: date.toJSON().toString(),
                    replyMessageId: replyMessageId,
                    replyType: replyType.toString(),
                }
            };

            return fcm.sendToDevice(tokens, payload);

        } else {
            // Get info user from (sent)
            const userFrom = await db.collection('users').doc(idFrom).get();
            console.log(`Found user from: ${userFrom.data()!.nom}`)

            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: `Nouveau message de: ${userFrom.data()!.nom}`,
                    body: contentMessage,
                    badge: '1',
                    tag: chatId,
                    click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
                },
                data: {
                    chatId: chatId,
                    type: type.toString(),
                    idFrom: idFrom,
                    date: date.toJSON().toString(),
                    replyMessageId: replyMessageId,
                    replyType: replyType.toString(),
                }
            };

            return fcm.sendToTopic(chatId, payload);

        }

    });
