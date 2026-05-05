<template>
  <div class="sim-section">
    <h2>Fault Injection</h2>
    <p class="hint">Simulate network faults to test RADIUS server resilience</p>
    <div class="fault-grid">
      <div v-for="f in faults" :key="f.id" class="fault-card">
        <h3>{{ f.icon }} {{ f.name }}</h3>
        <p>{{ f.desc }}</p>
        <button @click="inject(f)" :disabled="f.active">{{ f.active ? 'Active...' : '▶ Inject' }}</button>
        <button v-if="f.active" class="btn-clear" @click="clear(f)">Clear</button>
        <span v-if="f.result" class="result" :class="f.result.ok?'ok':'fail'">{{ f.result.text }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
const faults = ref([
  {id:'radius-timeout',icon:'⏱',name:'RADIUS Timeout',desc:'Block RADIUS port on VM2',active:false,result:null},
  {id:'radius-reject',icon:'🚫',name:'Auth Reject',desc:'Use invalid credentials',active:false,result:null},
  {id:'latency',icon:'🐌',name:'Network Latency',desc:'Add 200ms delay on VM3',active:false,result:null},
  {id:'packet-loss',icon:'📦',name:'Packet Loss',desc:'10% packet loss',active:false,result:null},
])
async function inject(f) { f.active=true;f.result=null; try{const r=await fetch(`/api/sim/fault/${f.id}`);f.result={ok:(await r.json()).success,text:'Injected'}}catch{};f.active=false }
async function clear(f) { try{await fetch(`/api/sim/fault/clear`);f.active=false;f.result=null }catch{} }
</script>

<style scoped>
.sim-section { display:flex; flex-direction:column; gap:12px; } h2{font-size:18px;} .hint{font-size:13px;color:#888;}
.fault-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:12px; }
.fault-card { background:#fff; padding:16px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); display:flex; flex-direction:column; gap:8px; }
.fault-card h3 { font-size:15px; } .fault-card p { font-size:13px; color:#666; flex:1; }
.fault-card button { padding:6px 14px; border:none; border-radius:6px; cursor:pointer; font-size:13px; font-weight:600; background:#f59e0b; color:#fff; }
.fault-card button:disabled { opacity:0.5; } .btn-clear { background:#ef4444!important; }
.result { font-size:12px; padding:4px 8px; border-radius:4px; }
.result.ok { color:#22c55e; background:#f0fdf4; } .result.fail { color:#ef4444; background:#fef2f2; }
</style>
