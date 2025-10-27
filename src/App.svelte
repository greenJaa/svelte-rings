<script>
import { onMount } from "svelte";
import { initializeApp } from "firebase/app";
import { getAuth, signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, getDoc, setDoc } from "firebase/firestore";

// --- Firebase setup ---
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT_ID.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT_ID.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID"
};
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

let user = null;

// --- Authentication ---
function login() {
    const provider = new GoogleAuthProvider();
    signInWithPopup(auth, provider);
}

function logout() {
    signOut(auth);
}

// Listen for auth state changes
onAuthStateChanged(auth, async (u) => {
    user = u;
    if (user) {
        await loadFromFirestore();
    }
});

// --- Firestore persistence ---
async function saveToFirestore() {
    if (!user) return;
    const userRef = doc(db, "users", user.uid);
    await setDoc(userRef, {
        rhythms: rhythms.map(r => r.store()),
        instruments: Object.fromEntries(Object.entries(instruments).map(([k,v]) => [k,v.sym_list.map(s => s.description)])),
        active,
        bpm
    });
    console.log("Saved to Firestore");
}

async function loadFromFirestore() {
    if (!user) return;
    const userRef = doc(db, "users", user.uid);
    const snapshot = await getDoc(userRef);
    if (snapshot.exists()) {
        const data = snapshot.data();
        if (data.rhythms) rhythms = data.rhythms.map(r => Rhythm.fromLoaded(r, instruments));
        if (data.instruments) {
            for (let name in data.instruments) {
                if (name in instruments) instruments[name].sym_list = data.instruments[name].map(desc => symbols[desc]);
            }
        }
        if (data.active) active = data.active;
        if (data.bpm) bpm = data.bpm;
        console.log("Loaded from Firestore");
    }
}

// --- Call saveToFirestore whenever something changes ---
$: if (user) saveToFirestore();

// ------------------- existing App.svelte code below -------------------
// keep all your imports, instruments, rhythms, active, etc.
// just place this Firebase code above your existing code
</script>

<!-- Add login/logout buttons somewhere in the UI -->
{#if !user}
<button on:click={login}>Login with Google</button>
{:else}
<div>
    Logged in as {user.displayName} <button on:click={logout}>Logout</button>
</div>
{/if}
