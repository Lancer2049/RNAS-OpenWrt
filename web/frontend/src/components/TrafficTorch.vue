<template>
  <div class="torch-section">
    <h2>Traffic Torch</h2>
    <p class="hint">Real-time per-session traffic analysis (like RouterOS Torch)</p>

    <div class="controls">
      <select v-model="interval"><option :value="1">1s</option><option :value="3">3s</option><option :value="5">5s</option></select>
      <label class="auto"><input type="checkbox" v-model="autoRefresh" /> Auto-refresh</label>
      <span class="total">Total: {{ formatBps(totalRx+totalTx) }}</span>
    </div>

    <table v-if="traffic.length">
      <thead><tr><th>IP</th><th>User</th><th>Proto</th><th>RX Rate</th><th>TX Rate</th><th>RX Total</th><th>TX Total</th><th>Bar</th></tr></thead>
      <tbody>
        <tr v-for="t in traffic" :key="t.ip">
          <td class="mono">{{ t.ip }}</td><td>{{ t.username }}</td><td>{{ t.type }}</td>
          <td class="mono rate">{{ formatBps(t.rxRate) }}</td><td class="mono rate">{{ formatBps(t.txRate) }}</td>
          <td class="mono">{{ formatBytes(t.rxBytes) }}</td><td class="mono">{{ formatBytes(t.txBytes) }}</td>
          <td><div class="bar"><div class="fill" :style="{width: barWidth(t.rxRate+t.txRate)+'%'}"></div></div></td>
        </tr>
      </tbody>
    </table>
    <div v-else class="empty">No active sessions — traffic will appear here</div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const traffic = ref([])
const totalRx = ref(0), totalTx = ref(0)
const interval = ref(3), autoRefresh = ref(true)
const prevRx = {}, prevTx = {}
let timer = null

async function fetchTraffic() {
  try {
    const r = await fetch('/api/status')
    const d = await r.json()
    const sessions = d.sessions || []
    const now = Date.now()
    const result = []
    totalRx.value=0; totalTx.value=0

    for (const s of sessions) {
      const ip = s.ip||s.sid
      const rx = parseInt(s.rx_bytes_raw)||0, tx = parseInt(s.tx_bytes_raw)||0
      const prx = (prevRx[ip]||{val:rx,ts:now})
      const ptx = (prevTx[ip]||{val:tx,ts:now})
      const dt = Math.max((now-prx.ts)/1000, 0.1)
      const rxRate = Math.max(0, (rx-prx.val)*8/dt)
      const txRate = Math.max(0, (tx-ptx.val)*8/dt)
      prevRx[ip]={val:rx,ts:now}; prevTx[ip]={val:tx,ts:now}
      totalRx.value+=rxRate; totalTx.value+=txRate
      result.push({ip, username:s.username||'-', type:s.type||'-', rxRate, txRate, rxBytes:rx, txBytes:tx})
    }
    traffic.value = result.sort((a,b)=>(b.rxRate+b.txRate)-(a.rxRate+a.txRate))
  } catch {}
}

const maxRate = computed(()=>Math.max(...traffic.value.map(t=>t.rxRate+t.txRate),1))
function barWidth(rate) { return Math.min((rate/maxRate.value)*100,100) }
function formatBps(bps){if(!bps)return'0bps';if(bps<1e3)return bps.toFixed(0)+'bps';if(bps<1e6)return(bps/1e3).toFixed(1)+'Kbps';return(bps/1e6).toFixed(1)+'Mbps'}
function formatBytes(n){if(!n)return'0B';if(n<1024)return n+'B';if(n<1e6)return(n/1024).toFixed(1)+'K';return(n/1e6).toFixed(1)+'M'}

onMounted(()=>{fetchTraffic();timer=setInterval(fetchTraffic,interval.value*1000)})
onUnmounted(()=>clearInterval(timer))
</script>

<style scoped>
.torch-section { display:flex; flex-direction:column; gap:12px; } h2{font-size:18px;} .hint{font-size:13px;color:#888;}
.controls { display:flex; gap:16px; align-items:center; background:#fff; padding:8px 16px; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); }
.controls select { padding:4px 8px; border:1px solid #ddd; border-radius:4px; } .total { margin-left:auto; font-weight:600; color:#3b82f6; }
table { width:100%; border-collapse:collapse; background:#fff; border-radius:8px; box-shadow:0 1px 3px rgba(0,0,0,0.08); font-size:13px; }
th,td { padding:6px 10px; text-align:left; border-bottom:1px solid #eee; } th { color:#666; font-weight:600; font-size:11px; text-transform:uppercase; }
.mono { font-family:monospace; font-size:12px; } .rate { color:#3b82f6; font-weight:600; }
.bar { width:60px; height:6px; background:#eee; border-radius:3px; overflow:hidden; } .fill { height:100%; background:#3b82f6; border-radius:3px; }
.empty { text-align:center; color:#999; padding:40px; }
</style>
