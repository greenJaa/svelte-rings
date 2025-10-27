<script>
  import { user } from '../lib/stores/user.js';
  import { auth } from '../lib/firebase.js';
  import { signOut } from 'firebase/auth';

  function logout() {
    signOut(auth).then(() => {
      window.location.href = '/';
    });
  }
</script>

<nav>
  {#if $user}
    <span>Welcome {$user.email}</span>
    <button on:click={logout}>Logout</button>
  {:else}
    <a href="/login">Login</a> | <a href="/register">Register</a>
  {/if}
</nav>

<slot />

