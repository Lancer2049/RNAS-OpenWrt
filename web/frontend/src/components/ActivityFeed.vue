<template>
  <div class="activity-section" v-if="events.length">
    <h3>Recent Activity</h3>
    <div class="activity-list">
      <div v-for="(e,i) in events" :key="i" class="activity-item">
        <span class="time">{{ e.time }}</span>
        <span class="dot" :class="e.type"></span>
        <span>{{ e.text }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
const events = ref([])
let lastAuth = 0, lastAcct = 0

async function poll() {
  try {
    const r = await fetch('/api/status')
    const s = (await r.json()).service || {}
    const now = new Date().toLocaleTimeString()
    if (s.auth_sent > lastAuth && lastAuth > 0)
      events.value.unshift({time:now,type:'auth',text:`Auth request sent (total: ${s.auth_sent})`})
    if (s.acct_sent > lastAcct && lastAcct > 0)
      events.value.unshift({time:now,type:'acct',text:`Accounting request sent (total: ${s.acct_sent})`})
    lastAuth = s.auth_sent||0; lastAcct = s.acct_sent||0
    if (events.value.length > 20) events.value.length = 20
  } catch {}
}
onMounted(() => { poll(); setInterval(poll, 3000) })
</script>

<style scoped>
.activity-section{background:#fff;padding:16px 20px;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,.06);margin-bottom:20px}
.activity-section h3{font-size:14px;color:#64748b;margin-bottom:10px;text-transform:uppercase;letter-spacing:.5px}
.activity-list{display:flex;flex-direction:column;gap:4px;max-height:160px;overflow-y:auto}
.activity-item{display:flex;align-items:center;gap:10px;font-size:12px;color:#64748b}
.time{color:#94a3b8;font-family:monospace;font-size:11px;width:70px;flex-shrink:0}
.dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}
.dot.auth{background:#3b82f6} .dot.acct{background:#22c55e}
</style>
