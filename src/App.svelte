<script>
import { onMount } from "svelte";
import { initializeApp } from "firebase/app";
import { getAuth, signInWithPopup, GoogleAuthProvider, signOut, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, getDoc, setDoc } from "firebase/firestore";

// --- Firebase setup ---
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

console.log(import.meta.env.VITE_FIREBASE_API_KEY);
console.log(import.meta.env); // shows all exposed variables

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

// --- Firestore persistence ---
async function saveToFirestore() {
    if (!user) return;

    const userRef = doc(db, "users", user.uid);
    await setDoc(userRef, {
        rhythms: rhythms.map(r => r.store()),
        instruments: Object.fromEntries(
            Object.entries(instruments).map(([k,v]) => [k,v.sym_list.map(s => s.description)])
        ),
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

// Listen for auth changes on mount
onMount(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
        user = u;
        if (user) await loadFromFirestore();
    });
    return () => unsubscribe();
});

// --- Reactive Firestore saving (debounced for performance) ---
let saveTimeout;
$: if (user) {
    clearTimeout(saveTimeout);
    saveTimeout = setTimeout(() => saveToFirestore(), 500); // save 0.5s after last change
}

// ------------------- existing App.svelte code below -------------------
// keep all your imports, instruments, rhythms, active, etc.
// just place this Firebase code above your existing code

</script>

<!-- Login/Logout UI -->
{#if !user}
<button on:click={login}>Login with Google</button>
{:else}
<div>
    Logged in as {user.displayName} <button on:click={logout}>Logout</button>
</div>
{/if}

<!-- Your existing App.svelte UI goes here -->
