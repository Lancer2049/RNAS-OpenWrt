<template>
  <div class="sessions-section">
    <div class="section-header">
      <h2>Active Sessions ({{ sessions.length }})</h2>
      <div class="header-actions">
        <input v-model="filter" placeholder="Filter..." class="filter-input" />
        <button class="btn-refresh" @click="$emit('refresh')" :disabled="loading">{{ loading ? '...' : '↻' }}</button>
        <button class="btn-disconnect-all" @click="disconnectAll" :disabled="!sessions.length">Disconnect All</button>
      </div>
    </div>
    <table v-if="filtered.length">
      <thead>
        <tr>
          <th @click="sortBy='username'" class="sortable">User {{sortBy==='username'?'▾':''}}</th>
          <th @click="sortBy='type'" class="sortable">Proto {{sortBy==='type'?'▾':''}}</th>
          <th>Caller-ID</th>
          <th @click="sortBy='ip'" class="sortable">IP {{sortBy==='ip'?'▾':''}}</th>
          <th @click="sortBy='uptime_raw'" class="sortable">Uptime {{sortBy==='uptime_raw'?'▾':''}}</th>
          <th>RX</th>
          <th>TX</th>
          <th>Rate</th>
          <th></th>
        </tr>
      </thead>
      <tbody>
        <template v-for="s in sorted" :key="s.sid">
          <tr @click="toggleDetail(s)" class="session-row" :class="{expanded: expanded===s.sid}">
            <td>{{ s.username||'-' }}</td>
            <td><span class="type-badge">{{ s.type||'-' }}</span></td>
            <td class="mono">{{ s.calling_sid||s.sid }}</td>
            <td class="mono">{{ s.ip||'-' }}</td>
            <td>{{ fmtUptime(s.uptime_raw) }}</td>
            <td>{{ fmtBytes(s.rx_bytes_raw) }}</td>
            <td>{{ fmtBytes(s.tx_bytes_raw) }}</td>
            <td class="mono">{{ fmtRate(s.rxRate) }} / {{ fmtRate(s.txRate) }}</td>
            <td><button class="btn-disconnect" @click.stop="$emit('disconnect',s.sid)">Disconnect</button></td>
          </tr>
          <tr v-if="expanded===s.sid" class="detail-row">
            <td colspan="9">
              <div class="detail-grid">
                <div><label>SID</label><span class="mono">{{ s.sid }}</span></div>
                <div><label>Interface</label><span>{{ s.ifname||'ppp'+(s.sid?.slice(-2)||'0') }}</span></div>
                <div><label>Caller-ID</label><span class="mono">{{ s.calling_sid||s.sid }}</span></div>
                <div><label>State</label><span class="badge" :class="s.state">{{ s.state||'active' }}</span></div>
                <div><label>Compression</label><span>{{ s.comp||'none' }}</span></div>
                <div><label>RX Total</label><span>{{ fmtBytes(s.rx_bytes_raw) }}</span></div>
                <div><label>TX Total</label><span>{{ fmtBytes(s.tx_bytes_raw) }}</span></div>
                <div><label>RX Rate</label><span class="mono">{{ fmtRate(s.rxRate) }}</span></div>
                <div><label>TX Rate</label><span class="mono">{{ fmtRate(s.txRate) }}</span></div>
                <div><label>Uptime</label><span>{{ fmtUptime(s.uptime_raw) }}</span></div>
                <div><label>Duration</label><span>{{ s.uptime_raw||0 }}s</span></div>
              </div>
            </td>
          </tr>
        </template>
      </tbody>
    </table>
    <div v-else-if="!loading" class="empty">No active sessions</div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
const props = defineProps({ sessions: Array, loading: Boolean })
defineEmits(['disconnect', 'refresh'])

const filter = ref(''), sortBy = ref('uptime_raw'), expanded = ref(null)
const prevRx = ref({}), prevTx = ref({}), prevTs = ref(0)

function toggleDetail(s) { expanded.value = expanded.value===s.sid ? null : s.sid }
const filtered = computed(() => {
  if (!filter.value) return (props.sessions||[]).map(s => {
    const now = Date.now(), dt = Math.max((now-(prevTs.value||now))/1000, 1)
    const rx = parseInt(s.rx_bytes_raw)||0, tx = parseInt(s.tx_bytes_raw)||0
    const rxRate = prevRx.value[s.sid] ? Math.max(0,(rx-prevRx.value[s.sid])*8/dt) : 0
    const txRate = prevTx.value[s.sid] ? Math.max(0,(tx-prevTx.value[s.sid])*8/dt) : 0
    prevRx.value[s.sid]=rx; prevTx.value[s.sid]=tx; prevTs.value=now
    return {...s, rxRate, txRate}
  })
  return (props.sessions||[]).filter(s => (s.username||''+s.ip||''+s.type||'').toLowerCase().includes(filter.value.toLowerCase()))
})
const sorted = computed(() => [...filtered.value].sort((a,b) => (a[sortBy.value]||0)-(b[sortBy.value]||0)))

async function disconnectAll() { for (const s of props.sessions) await fetch(`/api/sessions/${s.sid}/disconnect`,{method:'POST'}); location.reload() }
function fmtBytes(n){if(!n)return'0B';if(n<1024)return n+'B';return n<1e6?(n/1024).toFixed(1)+'K':(n/1e6).toFixed(1)+'M'}
function fmtRate(bps){if(!bps)return'0';if(bps<1e3)return bps+'bps';return bps<1e6?(bps/1e3).toFixed(0)+'K':(bps/1e6).toFixed(1)+'M'}
function fmtUptime(r){if(!r)return'-';const s=parseInt(r);if(isNaN(s))return r;if(s<60)return s+'s';if(s<3600)return Math.floor(s/60)+'m';return Math.floor(s/3600)+'h'}
</script>

<style scoped>
.sessions-section{background:#fff;padding:20px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.section-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;flex-wrap:wrap;gap:8px}
.section-header h2{font-size:16px}
.header-actions{display:flex;gap:8px;align-items:center}
.filter-input{padding:4px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;width:140px}
.btn-refresh{padding:4px 12px;background:#3b82f6;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px}
.btn-disconnect-all{padding:4px 12px;background:#ef4444;color:#fff;border:none;border-radius:4px;cursor:pointer;font-size:12px}
table{width:100%;border-collapse:collapse}
th,td{padding:6px 8px;text-align:left;border-bottom:1px solid #eee;font-size:12px}
th{color:#666;font-weight:600;font-size:10px;text-transform:uppercase;cursor:default}
th.sortable{cursor:pointer} th.sortable:hover{color:#3b82f6}
.session-row{cursor:pointer} .session-row:hover{background:#f8faff}
.session-row.expanded{background:#f0f4ff}
.type-badge{background:#f0f4ff;color:#3b82f6;padding:1px 6px;border-radius:3px;font-size:11px}
.mono{font-family:monospace;font-size:11px}
.btn-disconnect{padding:2px 8px;background:#ef4444;color:#fff;border:none;border-radius:3px;cursor:pointer;font-size:10px}
.detail-row td{background:#fafbff;padding:0}
.detail-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:6px;padding:10px 16px}
.detail-grid div{display:flex;flex-direction:column;gap:2px}
.detail-grid label{font-size:10px;color:#888;text-transform:uppercase}
.detail-grid span{font-size:13px}
.badge{padding:2px 8px;border-radius:10px;font-size:10px;font-weight:600}
.badge.active{background:#dcfce7;color:#166534} .badge.finishing,.badge.finish{background:#fef9c3;color:#854d0e}
.empty{text-align:center;color:#999;padding:30px}
</style>
