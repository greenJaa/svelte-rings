import { writable } from 'svelte/store';
import { auth } from './firebase';
import { onAuthStateChanged } from 'firebase/auth';

export const user = writable(null);

// Listen for Firebase Auth state changes
onAuthStateChanged(auth, (u) => {
  user.set(u);
});

