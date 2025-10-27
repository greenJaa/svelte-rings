// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
// Import the Authentication and Firestore SDKs
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyBIHef4A_WLXDpC6G9sI5X4ua52O-6f6Cg",
  authDomain: "svelte-rings.firebaseapp.com",
  projectId: "svelte-rings",
  storageBucket: "svelte-rings.firebasestorage.app",
  messagingSenderId: "935307364369",
  appId: "1:935307364369:web:0b311edfceda3a4caa89b0",
  measurementId: "G-226691LZLT"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

// Initialize Firebase Authentication and Cloud Firestore
export const auth = getAuth(app);
export const db = getFirestore(app);

