<script>
  import { auth } from '../lib/firebase.js';
  import { signInWithEmailAndPassword } from 'firebase/auth';

  let email = '';
  let password = '';
  let error = '';

  async function login() {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      error = '';
      window.location.href = '/dashboard';
    } catch (err) {
      error = err.message;
    }
  }
</script>

<h1>Login</h1>
<input type="email" bind:value={email} placeholder="Email" />
<input type="password" bind:value={password} placeholder="Password" />
<button on:click={login}>Login</button>

{#if error}
  <p style="color:red">{error}</p>
{/if}

<a href="/register">Don't have an account? Register</a>
