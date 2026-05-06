<template>
  <div class="sim-section">
    <h2 class="page-title">Subscriber Simulation</h2>
    <p class="page-hint">Simulate multiple CPE clients connecting via various protocols</p>

    <div class="controls">
      <div class="field"><label>Protocol</label><select v-model="proto"><option v-for="p in protocols" :key="p" :value="p">{{ p.toUpperCase() }}</option></select></div>
      <div class="field"><label>Count</label><input v-model.number="count" type="number" min="1" max="50" /></div>
      <div class="field"><label>User</label><input v-model="user" /></div>
      <div class="field"><label>Pass</label><input v-model="pass" /></div>
      <button class="btn-start" @click="startSim" :disabled="running">{{ running ? 'Running...' : '▶ Start' }}</button>
      <button class="btn-stop" @click="stopSim" :disabled="!running">⏹ Stop</button>
      <span class="status" :class="running?'active':'idle'">{{ running ? 'Simulation active' : 'Ready' }}</span>
    </div>

    <div class="progress" v-if="running">
      <div class="bar"><div class="fill" :style="{width: (done*100/count)+'%'}"></div></div>
      <span>{{ passed }}/{{ done }} of {{ count }} ({{ failed }} failed)</span>
    </div>

    <div class="results" v-if="results.length">
      <table>
        <thead><tr><th>#</th><th>Proto</th><th>Status</th><th>IP</th><th>Latency</th></tr></thead>
        <tbody>
          <tr v-for="r in results" :key="r.id" :class="r.ok?'row-ok':'row-fail'">
            <td>{{ r.id }}</td><td>{{ r.proto }}</td>
            <td>{{ r.ok ? '✅' : '❌' }}</td>
            <td class="mono">{{ r.ip||'-' }}</td><td>{{ r.latency ? r.latency+'ms' : '-' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!running" class="empty-state">
      <div class="icon">👥</div>
      <div class="text">No simulation running</div>
      <div class="sub">Configure parameters above and click Start to simulate subscriber connections</div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
const protocols = ['pppoe','pptp','l2tp','sstp']
const proto = ref('pppoe'), count = ref(5), user = ref('testuser'), pass = ref('testpass')
const running = ref(false), results = ref([]), done = ref(0), passed = ref(0), failed = ref(0)

async function startSim() {
  running.value = true; results.value = []; done.value = 0; passed.value = 0; failed.value = 0
  for (let i = 1; i <= count.value; i++) {
    const start = Date.now()
    try {
      const res = await fetch(`/api/sim/connect?proto=${proto.value}&user=${user.value}&pass=${pass.value}`)
      const d = await res.json()
      const ok = d.success
      results.value.push({id:i, proto:proto.value, ok, ip:d.ip, latency: Date.now()-start})
      done.value++; if (ok) passed.value++; else failed.value++
    } catch(e) {
      results.value.push({id:i, proto:proto.value, ok:false, latency: Date.now()-start})
      done.value++; failed.value++
    }
  }
  running.value = false
}
async function stopSim() {
  await fetch('/api/sim/stop')
  running.value = false
}
</script>

<style scoped>
.sim-section { display:flex; flex-direction:column; gap:12px; }
.controls { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; background:#fff; padding:16px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
.field { display:flex; flex-direction:column; gap:2px; }
.field label { font-size:10px; color:#888; text-transform:uppercase; }
.field input, .field select { padding:6px 10px; border:1px solid #ddd; border-radius:4px; font-size:14px; width:90px; }
.btn-start { padding:8px 20px; background:#22c55e; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600; }
.btn-stop { padding:8px 20px; background:#ef4444; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600; }
.btn-start:disabled,.btn-stop:disabled { opacity:0.5; }
.status { font-weight:600; font-size:13px; } .active { color:#22c55e; } .idle { color:#94a3b8; }
.progress { display:flex; align-items:center; gap:12px; }
.bar { flex:1; height:8px; background:#eee; border-radius:4px; overflow:hidden; }
.fill { height:100%; background:#3b82f6; transition:width .3s; }
.row-ok { background:#f0fdf4; } .row-fail { background:#fef2f2; }
</style>
