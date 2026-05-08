<template>
  <div class="health-section" v-if="data">
    <h3>System Health</h3>
    <div class="health-grid">
      <div class="health-item" v-for="s in data" :key="s.name">
        <span class="dot" :class="s.active==='active'?'up':'down'"></span>
        <span class="name">{{ s.name }}</span>
        <span class="state">{{ s.active==='active'?'UP':'DOWN' }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
const data = ref(null)
async function load() {
  try { const r = await fetch('/api/system/status'); data.value = (await r.json()).services } catch {}
}
onMounted(() => { load(); setInterval(load, 10000) })
</script>

<style scoped>
.health-section{background:#fff;padding:14px 18px;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,.06);margin-bottom:16px}
.health-section h3{font-size:13px;color:#64748b;margin-bottom:8px;text-transform:uppercase;letter-spacing:.5px}
.health-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:4px}
.health-item{display:flex;align-items:center;gap:8px;font-size:12px;padding:4px 0}
.dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}.dot.up{background:#22c55e}.dot.down{background:#ef4444}
.name{color:#64748b;flex:1}.state{font-weight:600;font-size:11px}.state{color:#22c55e}
.health-item:has(.down) .state{color:#ef4444}
</style>
