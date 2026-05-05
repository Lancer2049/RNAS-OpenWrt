<template>
  <div class="profiles-section">
    <h2>PPP Profiles</h2>
    <p class="hint">Default configuration per protocol type (like RouterOS /ppp profile)</p>
    <div class="profile-grid">
      <div v-for="p in profiles" :key="p.name" class="profile-card">
        <h3>{{ p.icon }} {{ p.name }}</h3>
        <table>
          <tr v-for="(v,k) in p.data" :key="k"><td>{{ k }}</td><td class="mono">{{ v }}</td></tr>
        </table>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
const profiles = ref([])
async function load() {
  try {
    const r = await fetch('/api/config')
    const cfg = (await r.json()).config || {}
    const map = {
      pppoe: {icon:'📡',section:'access.d.pppoe'}, pptp:{icon:'🔒',section:'access.d.pptp'},
      l2tp:{icon:'🛡',section:'access.d.l2tp'}, sstp:{icon:'🔐',section:'access.d.sstp'},
      ipoe:{icon:'🌐',section:'access.d.ipoe'}
    }
    profiles.value = Object.entries(map).map(([name,{icon,section}])=>({name:name.toUpperCase(),icon,data:cfg[section]||{}}))
  } catch {}
}
onMounted(load)
</script>
<style scoped>
.profiles-section{display:flex;flex-direction:column;gap:12px} h2{font-size:18px} .hint{font-size:13px;color:#888}
.profile-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:12px}
.profile-card{background:#fff;padding:16px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.profile-card h3{font-size:15px;margin-bottom:8px}
table{width:100%;font-size:12px} td{padding:3px 6px;border-bottom:1px solid #f0f0f0} td:first-child{color:#888;width:80px}
.mono{font-family:monospace;font-size:11px}
</style>
