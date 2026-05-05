<template>
  <div class="tool-section">
    <h2>Packet Sniffer</h2>
    <p class="hint">Capture RADIUS/PPP traffic for analysis (tcpdump :1812/1813/3799)</p>
    <div class="controls">
      <button @click="start" :disabled="running" class="btn-start">▶ Start Capture</button>
      <button @click="stop" :disabled="!running" class="btn-stop">⏹ Stop</button>
      <span v-if="running" class="status running">● Capturing... ({{ formatSize(size) }})</span>
      <span v-else class="status stopped">○ Stopped</span>
    </div>
    <p class="path" v-if="size>0">File: /tmp/rnas-sniffer.pcap ({{ formatSize(size) }})</p>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
const running=ref(false), size=ref(0)
async function check(){try{const r=await fetch('/api/sniffer/status');const d=await r.json();running.value=d.running;size.value=d.size}catch{}}
async function start(){await fetch('/api/sniffer/start');check()}
async function stop(){await fetch('/api/sniffer/stop');check()}
function formatSize(n){if(!n)return'0B';if(n<1024)return n+'B';return (n/1024).toFixed(1)+'KB'}
onMounted(check)
</script>
<style scoped>
.tool-section{display:flex;flex-direction:column;gap:12px} h2{font-size:18px} .hint{font-size:13px;color:#888}
.controls{display:flex;gap:12px;align-items:center;background:#fff;padding:16px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.btn-start{padding:8px 20px;background:#22c55e;color:#fff;border:none;border-radius:6px;cursor:pointer;font-size:14px;font-weight:600}
.btn-stop{padding:8px 20px;background:#ef4444;color:#fff;border:none;border-radius:6px;cursor:pointer;font-size:14px;font-weight:600}
button:disabled{opacity:.5}
.status{font-size:14px;font-weight:600} .running{color:#22c55e} .stopped{color:#9ca3af}
.path{font-family:monospace;font-size:12px;color:#666}
</style>
