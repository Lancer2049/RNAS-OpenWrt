<template>
  <div class="proto-config">
    <h2 class="page-title">Protocol Configuration</h2>
    <p class="page-hint">Configure access protocols — changes require Apply to take effect</p>

    <div class="proto-tabs">
      <button v-for="p in protocols" :key="p.id" :class="{active:active===p.id}" @click="active=p.id;loadProto(p.id)">
        {{ p.icon }} {{ p.name }}
        <span class="status-dot" :class="p.enabled?'on':'off'"></span>
      </button>
    </div>

    <div class="proto-form" v-if="current">
      <div class="form-header">
        <label class="toggle">
          <input type="checkbox" v-model="current.enabled" @change="save" />
          <span>{{ current.enabled ? 'Enabled' : 'Disabled' }}</span>
        </label>
      </div>

      <div class="field-row" v-for="f in current.fields" :key="f.key">
        <label>{{ f.label }}</label>
        <select v-if="f.key==='interface'" v-model="current.values[f.key]" class="field-input">
          <option v-for="iface in interfaces" :key="iface" :value="iface">{{ iface }}</option>
        </select>
        <select v-else-if="f.type==='yesno'" v-model="current.values[f.key]" class="field-input">
          <option value="yes">yes</option><option value="no">no</option>
        </select>
        <input v-else :type="f.type||'text'" v-model="current.values[f.key]" :placeholder="f.default" class="field-input" />
        <span class="field-hint">{{ f.hint }}</span>
      </div>

      <div class="form-actions">
        <button class="btn-primary" @click="save" :disabled="saving">{{ saving ? 'Saving...' : 'Save' }}</button>
        <button class="btn-primary" @click="apply" :disabled="applying">{{ applying ? 'Applying...' : 'Apply & Restart' }}</button>
        <span v-if="msg" class="msg" :class="msgType">{{ msg }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'

const active = ref('pppoe')
const current = ref(null)
const saving = ref(false), applying = ref(false)
const msg = ref(''), msgType = ref('ok')
const interfaces = ref(['ens33','lo','eth0'])

const protocols = reactive([
  {id:'pppoe',name:'PPPoE',icon:'📡',enabled:false,section:'access.d.pppoe', module:'pppoe',
    fields:[{key:'enabled',label:'Enabled',type:'yesno',hint:''},{key:'interface',label:'Interface',hint:''},{key:'mtu',label:'MTU',type:'number',default:'1492',hint:'576-1500'},{key:'ac_name',label:'AC Name',default:'RNAS',hint:''},{key:'service_name',label:'Service Name',hint:'optional'}]},
  {id:'pptp',name:'PPTP',icon:'🔒',enabled:false,section:'access.d.pptp', module:'pptp',
    fields:[{key:'enabled',label:'Enabled',type:'yesno',hint:''},{key:'interface',label:'Interface',hint:''},{key:'mtu',label:'MTU',type:'number',default:'1436',hint:'576-1500'}]},
  {id:'l2tp',name:'L2TP',icon:'🛡',enabled:false,section:'access.d.l2tp', module:'l2tp',
    fields:[{key:'enabled',label:'Enabled',type:'yesno',hint:''},{key:'interface',label:'Interface',hint:''},{key:'port',label:'Port',type:'number',default:'1701',hint:'1-65535'},{key:'mtu',label:'MTU',type:'number',default:'1460',hint:'576-1500'}]},
  {id:'sstp',name:'SSTP',icon:'🔐',enabled:false,section:'access.d.sstp', module:'sstp',
    fields:[{key:'enabled',label:'Enabled',type:'yesno',hint:''},{key:'interface',label:'Interface',hint:''},{key:'port',label:'Port',type:'number',default:'443',hint:'1-65535'},{key:'accept',label:'Accept',type:'yesno',hint:'ssl/proxy'},{key:'ssl_pemfile',label:'SSL Cert',default:'/etc/rnas/ssl/sstp.pem',hint:''}]},
  {id:'ipoe',name:'IPoE',icon:'🌐',enabled:false,section:'access.d.ipoe', module:'ipoe',
    fields:[{key:'enabled',label:'Enabled',type:'yesno',hint:''},{key:'interface',label:'Interface',hint:''},{key:'ip_pool',label:'IP Pool',default:'default',hint:''},{key:'opt_src',label:'Gateway IP',default:'192.168.100.1',hint:''}]},
])

async function loadProto(id) {
  const p = protocols.find(p=>p.id===id); if (!p) return
  try {
    const r = await fetch('/api/config')
    const cfg = (await r.json()).config || {}
    const data = cfg[p.section] || {}
    const core = cfg['access.d.core'] || {}
    p.enabled = core[p.module] === 'yes'
    current.value = { ...p, values: {...data} }
  } catch {}
}

async function save() {
  if (!current.value) return; saving.value = true
  const p = protocols.find(p=>p.id===active.value); if (!p) return
  try {
    await fetch(`/api/config/${p.module}`, {method:'PUT',headers:{'Content-Type':'application/json'},body:JSON.stringify(current.value.values)})
    // Also update core enabled
    await fetch('/api/config/core', {method:'PUT',headers:{'Content-Type':'application/json'},body:JSON.stringify({[p.module]:current.value.enabled?'yes':'no'})})
    p.enabled = current.value.enabled
    msg.value='Saved'; msgType.value='ok'
  } catch { msg.value='Save failed'; msgType.value='err' }
  saving.value = false
}

async function apply() {
  applying.value = true
  try {
    await fetch('/api/config/apply', {method:'POST'})
    msg.value='Applied & restarted'; msgType.value='ok'
  } catch { msg.value='Apply failed'; msgType.value='err' }
  applying.value = false
}

async function loadInterfaces() {
  try { const r = await fetch('/api/network/status'); const d = await r.json(); interfaces.value = (d.interfaces||[]).map(i=>i.name).filter(n=>n!=='lo') } catch {}
}

onMounted(() => { loadProto('pppoe'); loadInterfaces() })
</script>

<style scoped>
.proto-config{display:flex;flex-direction:column;gap:16px}
.proto-tabs{display:flex;gap:4px;flex-wrap:wrap}
.proto-tabs button{padding:8px 18px;border:1px solid #e2e8f0;background:#fff;border-radius:6px 6px 0 0;cursor:pointer;font-size:13px;display:flex;align-items:center;gap:6px;transition:all .15s}
.proto-tabs button.active{background:#3b82f6;color:#fff;border-color:#3b82f6;font-weight:600}
.proto-tabs button:hover:not(.active){background:#f8faff}
.status-dot{width:8px;height:8px;border-radius:50%}.status-dot.on{background:#22c55e}.status-dot.off{background:#e2e8f0}
.proto-tabs button.active .status-dot.off{background:rgba(255,255,255,.5)}

.proto-form{background:#fff;padding:20px;border-radius:0 8px 8px 8px;box-shadow:0 2px 8px rgba(0,0,0,.06)}
.form-header{margin-bottom:16px}
.toggle{display:flex;align-items:center;gap:10px;cursor:pointer;font-size:14px;font-weight:600}
.toggle input{width:18px;height:18px}

.field-row{display:flex;align-items:center;gap:8px;margin-bottom:10px}
.field-row label{width:120px;font-size:13px;color:#64748b;flex-shrink:0}
.field-input{padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px;flex:1;max-width:300px}
.field-input:focus{border-color:#3b82f6;outline:none}
.field-hint{font-size:10px;color:#94a3b8;width:80px}

.form-actions{display:flex;gap:10px;align-items:center;margin-top:16px;padding-top:12px;border-top:1px solid #f0f0f0}
.msg{font-size:13px;font-weight:500}.ok{color:#22c55e}.err{color:#ef4444}
</style>
