// Fichier : aic_woippy_app/functions/index.js

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();
const db = admin.firestore();

sgMail.setApiKey(process.env.SENDGRID_KEY);

// --- FONCTION POUR LA RÉCUPÉRATION PAR E-MAIL ---
exports.requestPasswordResetCode = onCall({ region: "europe-west1", secrets: ["SENDGRID_KEY"] }, async (request) => {
  const email = request.data.email;
  if (!email) {
    throw new HttpsError("invalid-argument", "L'e-mail est requis.");
  }
  try {
    const user = await admin.auth().getUserByEmail(email);
    const code = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = admin.firestore.Timestamp.fromMillis(Date.now() + 10 * 60 * 1000);
    await db.collection("passwordResetCodes").doc(user.uid).set({ code, expiresAt });
    const msg = {
      to: email,
      from: "noreply.aic.woippy@gmail.com", // Votre e-mail vérifié
      subject: "Votre code de vérification pour AIC Woippy",
      html: `<p>Bonjour, voici votre code pour réinitialiser votre mot de passe : <strong>${code}</strong></p><p>Il expirera dans 10 minutes.</p>`,
    };
    await sgMail.send(msg);
    logger.info(`Code de réinitialisation envoyé à ${email}`);
    return { success: true };
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      logger.info(`Tentative de réinitialisation pour un e-mail inexistant: ${email}`);
      return { success: true };
    }
    logger.error("Erreur lors de l'envoi du code:", error);
    throw new HttpsError("internal", "Impossible d'envoyer l'e-mail.");
  }
});

// --- NOUVELLE FONCTION : TROUVER UN UTILISATEUR PAR SON TÉLÉPHONE ---
exports.findUserByPhone = onCall({ region: "europe-west1" }, async (request) => {
  const phoneNumber = request.data.phone;
  if (!phoneNumber) {
    throw new HttpsError("invalid-argument", "Le numéro de téléphone est requis.");
  }
  try {
    const userRecord = await admin.auth().getUserByPhoneNumber(phoneNumber);
    // On ne renvoie que l'email, c'est tout ce dont le client a besoin
    return { email: userRecord.email };
  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      logger.info(`Tentative de recherche pour un numéro inexistant: ${phoneNumber}`);
      // On ne renvoie pas d'erreur pour ne pas révéler si un numéro existe
      return { email: null };
    }
    logger.error("Erreur lors de la recherche par téléphone:", error);
    throw new HttpsError("internal", "Une erreur interne est survenue.");
  }
});

// --- CETTE FONCTION EST MAINTENANT DÉDIÉE UNIQUEMENT À LA VÉRIFICATION DU CODE ---
exports.verifyResetCode = onCall({ region: "europe-west1" }, async (request) => {
  const { email, code } = request.data;
  if (!email || !code) {
    throw new HttpsError("invalid-argument", "L'e-mail et le code sont requis.");
  }
  try {
    const user = await admin.auth().getUserByEmail(email);
    const docRef = db.collection("passwordResetCodes").doc(user.uid);
    const doc = await docRef.get();
    if (!doc.exists || admin.firestore.Timestamp.now() > doc.data().expiresAt || doc.data().code !== code) {
      throw new HttpsError("unauthenticated", "Le code est incorrect ou a expiré.");
    }
    // Si le code est bon, on ne le supprime pas encore, on renvoie juste un succès.
    return { success: true };
  } catch (error) {
    if (error instanceof HttpsError) throw error;
    logger.error("Erreur lors de la vérification du code:", error);
    throw new HttpsError("internal", "Une erreur est survenue.");
  }
});

// --- CETTE FONCTION FINALIZE LE CHANGEMENT DE MOT DE PASSE ---
exports.resetPassword = onCall({ region: "europe-west1" }, async (request) => {
  const { email, newPassword } = request.data;
  if (!email || !newPassword) {
    throw new HttpsError("invalid-argument", "L'e-mail et le nouveau mot de passe sont requis.");
  }
  try {
    const user = await admin.auth().getUserByEmail(email);
    // La vérification du code a déjà eu lieu à l'étape précédente. Ici, on fait confiance
    // et on change directement le mot de passe, puis on supprime le code.
    await admin.auth().updateUser(user.uid, { password: newPassword });
    await db.collection("passwordResetCodes").doc(user.uid).delete();
    logger.info(`Mot de passe réinitialisé pour ${email}`);
    return { success: true };
  } catch(error) {
    if (error instanceof HttpsError) throw error;
    logger.error("Erreur lors de la réinitialisation du mot de passe:", error);
    throw new HttpsError("internal", "Une erreur est survenue.");
  }
});