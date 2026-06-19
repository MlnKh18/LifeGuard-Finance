import { initializeApp } from 'firebase/app';
import { getAuth, createUserWithEmailAndPassword } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyAeewj6g7eZWd_g1W4WP7kiDYeItuopT4M",
  authDomain: "lifeguard-finance.firebaseapp.com",
  projectId: "lifeguard-finance",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);

async function runTest() {
  const email = `test-${Date.now()}@email.com`;
  const password = "Password123!";
  
  try {
    console.log("Registering user in Firebase...");
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const token = await userCredential.user.getIdToken();
    console.log("Got ID Token. Syncing with Backend...");
    
    const response = await fetch('https://lifeguard-finance-backend.vercel.app/api/v1/auth/sync-user', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        role: 'HEAD_OF_FAMILY',
      })
    });
    
    const data = await response.json();
    if (response.ok) {
      console.log("Backend Sync Success:", data);
    } else {
      console.error("Backend Error:", response.status, data);
    }
  } catch (error) {
    console.error("Test Error:", error);
  }
  process.exit(0);
}

runTest();
