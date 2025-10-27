<script>
  import { auth } from '../lib/firebase.js';
  import { signInWithEmailAndPassword } from 'firebase/auth';
  import { user } from '../lib/stores/user.js';

  let email = '';
  let password = '';
  let error = '';

  async function login() {
    try {
      await signInWithEmailAndPassword(auth, email, password);
      error = '';
      // redirect to home
      window.location.href = '/';
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

