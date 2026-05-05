<template>
  <div class="proto-monitor">
    <h2>Protocol Monitor</h2>
    <p class="hint">Real-time RADIUS/PPP protocol activity</p>

    <div class="stats-row">
      <div class="stat"><span class="label">Auth Sent</span><span class="value">{{ service.auth_sent || 0 }}</span></div>
      <div class="stat"><span class="label">Acct Sent</span><span class="value">{{ service.acct_sent || 0 }}</span></div>
      <div class="stat"><span class="label">Failures</span><span class="value" :class="service.radius_fail_count>0?'red':''">{{ service.radius_fail_count || 0 }}</span></div>
      <div class="stat"><span class="label">Active</span><span class="value green">{{ service.sessions_active || 0 }}</span></div>
    </div>

    <div class="log-panel">
      <div class="log-item" v-for="(l,i) in events" :key="i">
        <span class="time">{{ l.time }}</span>
        <span class="type" :class="l.type">{{ l.type }}</span>
        <span>{{ l.detail }}</span>
      </div>
      <div v-if="!events.length" class="empty">Waiting for RADIUS activity...</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const service = ref({})
const events = ref([])
let ws = null

async function startWS() {
  try {
    ws = new WebSocket(`ws://${location.host}/api/ws`)
    ws.onmessage = e => {
      try {
        const d = JSON.parse(e.data)
        const oldSvc = {auth_sent: service.value.auth_sent||0, acct_sent: service.value.acct_sent||0}
        service.value = d.service || {}
        if ((d.service?.auth_sent||0) > (oldSvc.auth_sent||0))
          events.value.unshift({time:new Date().toLocaleTimeString(),type:'auth',detail:`Access-Request sent (total: ${d.service.auth_sent})`})
        if ((d.service?.acct_sent||0) > (oldSvc.acct_sent||0))
          events.value.unshift({time:new Date().toLocaleTimeString(),type:'acct',detail:`Accounting-Request sent (total: ${d.service.acct_sent})`})
        if (events.value.length > 50) events.value.length = 50
      } catch {}
    }
    ws.onclose = () => ws = null
  } catch {}
}
onMounted(startWS)
onUnmounted(() => ws?.close())
</script>

<style scoped>
.proto-monitor { display:flex; flex-direction:column; gap:12px; } h2{font-size:18px;} .hint{font-size:13px;color:#888;}
.stats-row { display:flex; gap:16px; }
.stat { background:#fff; padding:12px 20px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); text-align:center; min-width:100px; }
.label { display:block; font-size:11px; color:#888; text-transform:uppercase; }
.value { font-size:24px; font-weight:700; } .red{color:#ef4444;} .green{color:#22c55e;}
.log-panel { background:#1a1a2e; border-radius:8px; padding:12px; max-height:400px; overflow-y:auto; font-family:monospace; font-size:12px; }
.log-item { padding:4px 0; border-bottom:1px solid #2a2a4e; display:flex; gap:12px; color:#ccc; }
.time { color:#888; width:80px; flex-shrink:0; }
.type { padding:0 6px; border-radius:3px; font-size:10px; font-weight:600; width:50px; text-align:center; }
.type.auth { background:#1e3a5f; color:#60a5fa; }
.type.acct { background:#1e4a2e; color:#4ade80; }
.empty { text-align:center; color:#666; padding:40px; }
</style>
