<template>
  <div class="sim-section">
    <h2>Scenario Runner</h2>
    <p class="hint">Run predefined test scenarios with one click</p>
    <div class="scenario-grid">
      <div v-for="s in scenarios" :key="s.id" class="scenario-card" :class="{running: s.running}">
        <h3>{{ s.name }}</h3>
        <p>{{ s.description }}</p>
        <button @click="runScenario(s)" :disabled="s.running">{{ s.running ? 'Running...' : '▶ Run' }}</button>
        <span v-if="s.result" class="result" :class="s.result.ok?'ok':'fail'">{{ s.result.text }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
const scenarios = ref([])
async function load() { try{const r=await fetch('/api/scenarios');scenarios.value=((await r.json()).scenarios||[]).map(s=>({...s,running:false,result:null}))}catch{} }
async function runScenario(s) {
  s.running=true; s.result=null
  try{const r=await fetch(`/api/scenarios/${s.id}/load`,{method:'POST'});const d=await r.json();s.result={ok:d.success,text:d.success?`${d.applied}/${d.total} applied`:'Failed'}}catch{}
  s.running=false
}
onMounted(load)
</script>

<style scoped>
.sim-section { display:flex; flex-direction:column; gap:12px; } h2{font-size:18px;} .hint{font-size:13px;color:#888;}
.scenario-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(260px,1fr)); gap:12px; }
.scenario-card { background:#fff; padding:16px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); display:flex; flex-direction:column; gap:8px; }
.scenario-card h3 { font-size:15px; } .scenario-card p { font-size:13px; color:#666; flex:1; }
.scenario-card button { padding:8px 16px; background:#3b82f6; color:#fff; border:none; border-radius:6px; cursor:pointer; font-size:13px; font-weight:600; }
.scenario-card button:disabled { opacity:0.5; }
.result { font-size:12px; padding:4px 8px; border-radius:4px; }
.result.ok { color:#22c55e; background:#f0fdf4; } .result.fail { color:#ef4444; background:#fef2f2; }
.running { border-left:3px solid #3b82f6; }
</style>
