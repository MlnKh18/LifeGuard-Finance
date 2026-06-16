import { initializeApp, cert, getApps, type App } from 'firebase-admin/app';
import { getAuth, type Auth } from 'firebase-admin/auth';
import { env } from '@shared/utils/env.js';

let app: App;
let auth: Auth;

export function getFirebaseAdmin(): { app: App; auth: Auth } {
  if (!app) {
    const existingApps = getApps();

    if (existingApps.length > 0) {
      app = existingApps[0];
    } else {
      app = initializeApp({
        credential: cert({
          projectId: env.FIREBASE_PROJECT_ID,
          clientEmail: env.FIREBASE_CLIENT_EMAIL,
          privateKey: env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        }),
      });
    }

    auth = getAuth(app);
  }

  return { app, auth };
}

export async function verifyIdToken(idToken: string) {
  const { auth } = getFirebaseAdmin();
  return auth.verifyIdToken(idToken);
}

export async function getFirebaseUser(uid: string) {
  const { auth } = getFirebaseAdmin();
  return auth.getUser(uid);
}
