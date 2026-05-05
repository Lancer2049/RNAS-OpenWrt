<template>
  <div class="queue-section">
    <h2>Queue Management</h2>
    <p class="hint">Bandwidth control — Simple Queue rules</p>

    <div class="add-form">
      <input v-model="newName" placeholder="Name" class="field" />
      <input v-model="newTarget" placeholder="Target IP" class="field" />
      <input v-model="newRate" placeholder="Rate (e.g. 10M/20M)" class="field" />
      <select v-model="newProto" class="field"><option value="all">All</option><option>pppoe</option><option>l2tp</option><option>sstp</option></select>
      <button @click="addQueue" class="btn-add">+ Add</button>
    </div>

    <table v-if="queues.length">
      <thead><tr><th>Name</th><th>Target</th><th>Rate</th><th>Burst</th><th>TX</th><th>RX</th><th>Status</th><th></th></tr></thead>
      <tbody>
        <tr v-for="q in queues" :key="q.name">
          <td class="mono">{{ q.name }}</td>
          <td>{{ q.target }}</td>
          <td class="mono">{{ q.rate }}</td>
          <td class="mono">{{ q.burst||'none' }}</td>
          <td>{{ formatBytes(q.tx) }}</td>
          <td>{{ formatBytes(q.rx) }}</td>
          <td><span class="badge" :class="q.active?'active':'inactive'">{{ q.active?'Active':'Idle' }}</span></td>
          <td><button @click="removeQueue(q.name)" class="btn-del">✕</button></td>
        </tr>
      </tbody>
    </table>
    <div v-else class="empty">No queue rules defined</div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
const queues = reactive([])
const newName = ref(''), newTarget = ref(''), newRate = ref('10M'), newProto = ref('all')

async function loadQueues() {
  try { const r = await fetch('/api/queues'); const d = await r.json(); queues.length=0; queues.push(...(d.queues||[])) } catch {}
}
function addQueue() {
  if (!newName.value||!newTarget.value) return
  queues.push({name:newName.value, target:newTarget.value, rate:newRate.value, burst:'', tx:0, rx:0, active:true, proto:newProto.value})
  newName.value=''; newTarget.value=''; newRate.value='10M'
  fetch('/api/queues',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({queues:[...queues]})})
}
function removeQueue(name) {
  const i = queues.findIndex(q=>q.name===name)
  if (i>=0) { queues.splice(i,1); fetch('/api/queues',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({queues:[...queues]})}) }
}
function formatBytes(n){if(!n)return'0B';if(n<1024)return n+'B';if(n<1e6)return(n/1024).toFixed(1)+'K';return(n/1e6).toFixed(1)+'M'}
onMounted(loadQueues)
</script>

<style scoped>
.queue-section { display:flex; flex-direction:column; gap:12px; } h2{font-size:18px;} .hint{font-size:13px;color:#888;}
.add-form { display:flex; gap:8px; flex-wrap:wrap; background:#fff; padding:12px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
.field { padding:6px 10px; border:1px solid #ddd; border-radius:4px; font-size:13px; }
.btn-add { padding:6px 16px; background:#22c55e; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:13px; font-weight:600; }
table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); font-size:13px; }
th,td { padding:8px 10px; text-align:left; border-bottom:1px solid #eee; } th { color:#666; font-weight:600; font-size:11px; text-transform:uppercase; }
.mono { font-family:monospace; font-size:12px; }
.badge { padding:2px 8px; border-radius:10px; font-size:11px; }
.badge.active { background:#dcfce7; color:#166534; } .badge.inactive { background:#f3f4f6; color:#9ca3af; }
.btn-del { padding:2px 8px; background:#fee; border:1px solid #fcc; border-radius:3px; cursor:pointer; font-size:12px; color:#c33; }
.empty { text-align:center; color:#999; padding:40px; }
</style>
