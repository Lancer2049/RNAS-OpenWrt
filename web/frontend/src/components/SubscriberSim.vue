<template>
  <div class="sim-section">
    <h2>Subscriber Simulation</h2>
    <p class="hint">Simulate multiple CPE clients connecting via various protocols</p>

    <div class="controls">
      <div class="field"><label>Protocol</label><select v-model="proto"><option v-for="p in protocols" :key="p" :value="p">{{ p }}</option></select></div>
      <div class="field"><label>Count</label><input v-model.number="count" type="number" min="1" max="50" /></div>
      <div class="field"><label>Username</label><input v-model="user" /></div>
      <div class="field"><label>Password</label><input v-model="pass" /></div>
      <button class="btn-start" @click="startSim" :disabled="running">{{ running ? 'Running...' : '▶ Start' }}</button>
      <button class="btn-stop" @click="stopSim" :disabled="!running">⏹ Stop</button>
    </div>

    <div class="progress" v-if="running">
      <div class="bar"><div class="fill" :style="{width: (results.length*100/count)+'%'}"></div></div>
      <span>{{ results.length }} / {{ count }}</span>
    </div>

    <div class="results" v-if="results.length">
      <table>
        <thead><tr><th>#</th><th>Protocol</th><th>Result</th><th>IP</th><th>Latency</th></tr></thead>
        <tbody>
          <tr v-for="r in results" :key="r.id" :class="r.ok?'ok':'fail'">
            <td>{{ r.id }}</td><td>{{ r.proto }}</td>
            <td>{{ r.ok ? '✅' : '❌ '+(r.error||'') }}</td>
            <td class="mono">{{ r.ip||'-' }}</td><td>{{ r.latency ? r.latency+'ms' : '-' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
const protocols = ['pppoe','pptp','l2tp','sstp']
const proto = ref('pppoe'), count = ref(5), user = ref('testuser'), pass = ref('testpass')
const running = ref(false), results = ref([])

async function startSim() {
  running.value = true; results.value = []
  for (let i = 1; i <= count.value; i++) {
    const start = Date.now()
    try {
      const res = await fetch(`/api/sim/connect?proto=${proto.value}&user=${user.value}&pass=${pass.value}`)
      const d = await res.json()
      results.value.push({id:i, proto:proto.value, ok:d.success, ip:d.ip, error:d.error, latency: Date.now()-start})
    } catch(e) {
      results.value.push({id:i, proto:proto.value, ok:false, error:'timeout', latency: Date.now()-start})
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
.sim-section h2 { font-size:18px; } .hint { font-size:13px; color:#888; }
.controls { display:flex; gap:12px; align-items:flex-end; flex-wrap:wrap; background:#fff; padding:16px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
.field { display:flex; flex-direction:column; gap:2px; }
.field label { font-size:11px; color:#888; text-transform:uppercase; }
.field input, .field select { padding:6px 10px; border:1px solid #ddd; border-radius:4px; font-size:14px; width:100px; }
.btn-start { padding:8px 20px; background:#22c55e; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600; }
.btn-stop { padding:8px 20px; background:#ef4444; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:14px; font-weight:600; }
.btn-start:disabled,.btn-stop:disabled { opacity:0.5; }
.progress { display:flex; align-items:center; gap:12px; }
.bar { flex:1; height:8px; background:#eee; border-radius:4px; overflow:hidden; }
.fill { height:100%; background:#3b82f6; transition:width .3s; }
.results table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); font-size:13px; }
th,td { padding:6px 10px; text-align:left; border-bottom:1px solid #eee; } th { color:#666; font-weight:600; font-size:11px; text-transform:uppercase; }
.ok { background:#f0fdf4; } .fail { background:#fef2f2; } .mono { font-family:monospace; font-size:12px; }
</style>
