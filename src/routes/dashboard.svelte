<script>
  import { user } from '../lib/stores/user.js';
  import { onMount } from 'svelte';
  import { db } from '../lib/firebase.js';
  import { doc, getDoc, setDoc } from 'firebase/firestore';

  let loading = true;
  let rings = [];
  let newRing = '';

  async function loadRings() {
    if (!$user) return;
    const docSnap = await getDoc(doc(db, 'users', $user.uid));
    rings = docSnap.exists() ? docSnap.data().rings : [];
    loading = false;
  }

  async function addRing() {
    if (!$user || !newRing) return;
    rings.push(newRing);
    await setDoc(doc(db, 'users', $user.uid), { rings });
    newRing = '';
  }

  onMount(() => {
    const unsubscribe = user.subscribe(u => {
      if (!u) {
        window.location.href = '/login';
      } else {
        loadRings();
      }
    });
    return unsubscribe;
  });
</script>

{#if loading}
  <p>Loading...</p>
{:else}
  <h1>Dashboard</h1>
  <ul>
    {#each rings as ring}
      <li>{ring}</li>
    {/each}
  </ul>

  <input type="text" bind:value={newRing} placeholder="Add a new ring" />
  <button on:click={addRing}>Add Ring</button>
{/if}
