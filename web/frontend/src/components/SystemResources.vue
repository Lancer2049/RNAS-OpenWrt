<template>
  <div class="resources-section" v-if="data">
    <h3>System Resources</h3>
    <div class="res-grid">
      <div class="res-card">
        <div class="res-label">Memory</div>
        <div class="res-bar"><div class="res-fill blue" :style="{width: memPct+'%'}"></div></div>
        <div class="res-value">{{ data.memory || '--' }}</div>
      </div>
      <div class="res-card">
        <div class="res-label">Disk</div>
        <div class="res-bar"><div class="res-fill green" :style="{width: diskPct+'%'}"></div></div>
        <div class="res-value">{{ data.disk || '--' }}</div>
      </div>
      <div class="res-card">
        <div class="res-label">Load Average</div>
        <div class="res-value mono">{{ data.load || '--' }}</div>
      </div>
      <div class="res-card">
        <div class="res-label">Boot Time</div>
        <div class="res-value mono">{{ data.boot_time || '--' }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
const data = ref(null)

const memPct = computed(() => {
  if (!data.value?.memory) return 0
  const parts = data.value.memory.split('/')
  if (parts.length < 2) return 0
  const used = parts[0].replace(/[^0-9.]/g,'')
  const total = parts[1].replace(/[^0-9.]/g,'')
  return total > 0 ? (parseFloat(used)/parseFloat(total)*100) : 0
})
const diskPct = computed(() => {
  if (!data.value?.disk) return 0
  const parts = data.value.disk.split('/')
  return parts.length > 1 ? (parseFloat(parts[0].replace(/[^0-9.]/g,''))) : 0
})

async function load() {
  try { const r = await fetch('/api/system/status'); data.value = await r.json() } catch {}
}
onMounted(load)
</script>

<style scoped>
.resources-section { margin-bottom: 20px; background:#fff; padding:16px 20px; border-radius:10px; box-shadow:0 2px 8px rgba(0,0,0,0.06); }
.resources-section h3 { font-size:14px; color:#64748b; margin-bottom:12px; text-transform:uppercase; letter-spacing:.5px; }
.res-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(180px,1fr)); gap:14px; }
.res-label { font-size:10px; color:#94a3b8; text-transform:uppercase; letter-spacing:.5px; margin-bottom:4px; }
.res-bar { height:8px; background:#e2e8f0; border-radius:4px; overflow:hidden; margin-bottom:4px; }
.res-fill { height:100%; border-radius:4px; transition:width .5s; }
.res-fill.blue { background:#3b82f6; } .res-fill.green { background:#22c55e; }
.res-value { font-size:13px; font-weight:600; } .mono { font-family:monospace; }
</style>
