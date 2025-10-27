<script>
  import { auth } from '../lib/firebase.js';
  import { createUserWithEmailAndPassword } from 'firebase/auth';

  let email = '';
  let password = '';
  let error = '';

  async function register() {
    try {
      await createUserWithEmailAndPassword(auth, email, password);
      error = '';
      window.location.href = '/';
    } catch (err) {
      error = err.message;
    }
  }
</script>

<h1>Register</h1>
<input type="email" bind:value={email} placeholder="Email" />
<input type="password" bind:value={password} placeholder="Password" />
<button on:click={register}>Sign Up</button>

{#if error}
  <p style="color:red">{error}</p>
{/if}

