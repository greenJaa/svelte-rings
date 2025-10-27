<script lang="ts">
  // Import the 'auth' instance from your Firebase initialization file
  import { auth } from '$lib/firebase';
  import {
    createUserWithEmailAndPassword,
    signInWithEmailAndPassword,
    signInWithPopup,
    GoogleAuthProvider, // <-- Import the GoogleAuthProvider
    signOut, // <-- Added signOut for completeness
    onAuthStateChanged // <-- Added to react to auth state changes
  } from 'firebase/auth';
  import { goto } from '$app/navigation'; // <-- For redirection after login

  // Reactive variables for form inputs and messages
  let email = '';
  let password = '';
  let authError: string | null = null;
  let successMessage: string | null = null;
  let currentUser: any | null = null; // To display current user info

  // Listen for authentication state changes
  onAuthStateChanged(auth, (user) => {
    currentUser = user;
    if (user) {
      // User is signed in
      console.log('User signed in:', user.email);
      // Optional: redirect to a dashboard or home page after login
      // goto('/dashboard');
    } else {
      // User is signed out
      console.log('User signed out');
    }
  });

  // --- Email/Password Handlers ---
  async function handleSignUp() {
    authError = null;
    successMessage = null;
    try {
      await createUserWithEmailAndPassword(auth, email, password);
      successMessage = 'Sign up successful! You can now log in.';
    } catch (error: any) {
      console.error("Sign-up error:", error);
      authError = error.message;
    }
  }

  async function handleSignIn() {
    authError = null;
    successMessage = null;
    try {
      await signInWithEmailAndPassword(auth, email, password);
      successMessage = 'Sign in successful!';
      // Optional: clear form fields or redirect
      email = '';
      password = '';
    } catch (error: any) {
      console.error("Sign-in error:", error);
      authError = error.message;
    }
  }

  // --- Google Sign-in Handler ---
  async function handleGoogleSignIn() {
    authError = null;
    successMessage = null;
    try {
      // Instantiate the GoogleAuthProvider here
      const googleProvider = new GoogleAuthProvider();
      await signInWithPopup(auth, googleProvider);
      successMessage = 'Signed in with Google successfully!';
    } catch (error: any) {
      console.error("Google Sign-in error:", error);
      authError = error.message;
    }
  }

  // --- Sign Out Handler ---
  async function handleSignOut() {
    authError = null;
    successMessage = null;
    try {
      await signOut(auth);
      successMessage = 'Signed out successfully!';
      // Optional: redirect to login page or home
      // goto('/login');
    } catch (error: any) {
      console.error("Sign-out error:", error);
      authError = error.message;
    }
  }
</script>

<style>
  /* Basic styling for readability - feel free to customize */
  div {
    max-width: 400px;
    margin: 40px auto;
    padding: 20px;
    border: 1px solid #ddd;
    border-radius: 8px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  }
  h2 {
    text-align: center;
    color: #333;
  }
  label {
    display: block;
    margin-bottom: 5px;
    color: #555;
  }
  input[type="email"],
  input[type="password"] {
    width: calc(100% - 20px);
    padding: 10px;
    margin-bottom: 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
  }
  button {
    background-color: #007bff;
    color: white;
    padding: 10px 15px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 16px;
    margin-right: 10px;
  }
  button:hover {
    background-color: #0056b3;
  }
  .error {
    color: red;
    margin-top: 10px;
  }
  .success {
    color: green;
    margin-top: 10px;
  }
  .user-info {
    margin-top: 20px;
    padding-top: 15px;
    border-top: 1px solid #eee;
  }
</style>

<div>
  <h2>Authentication</h2>

  {#if currentUser}
    <div class="user-info">
      <h3>Welcome, {currentUser.displayName || currentUser.email}!</h3>
      <button on:click={handleSignOut}>Sign Out</button>
    </div>
  {:else}
    <form on:submit|preventDefault={handleSignIn}>
      <p>Sign In or Sign Up:</p>
      <label for="email">Email:</label>
      <input type="email" id="email" bind:value={email} required />

      <label for="password">Password:</label>
      <input type="password" id="password" bind:value={password} required />

      <button type="submit">Sign In</button>
      <button type="button" on:click={handleSignUp}>Sign Up</button>
    </form>

    <div style="margin-top: 20px;">
      <button type="button" on:click={handleGoogleSignIn}>Sign In with Google</button>
    </div>
  {/if}

  {#if authError}
    <p class="error">{authError}</p>
  {/if}
  {#if successMessage}
    <p class="success">{successMessage}</p>
  {/if}
</div>
