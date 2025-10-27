<script>
  import { user } from '../lib/stores/user.js';
  import { onMount } from 'svelte';

  onMount(() => {
    if (!$user) {
      window.location.href = '/login';
    }
  });
</script>

<h1>Dashboard</h1>
<p>Only logged-in users can see this.</p>

