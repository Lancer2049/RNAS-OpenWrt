<template>
  <div class="network-section">
    <div class="section-header"><h2>Network Configuration</h2></div>

    <div class="card" v-for="section in sections" :key="section.title">
      <h3>{{ section.title }}</h3>
      <table>
        <thead><tr><th>Key</th><th>Value</th></tr></thead>
        <tbody>
          <tr v-for="(val, key) in section.data" :key="key">
            <td class="mono">{{ key }}</td>
            <td>
              <input v-model="section.data[key]" @blur="saveSection(section)" />
            </td>
          </tr>
          <tr v-if="Object.keys(section.data).length === 0">
            <td colspan="2" class="empty">Not configured</td>
          </tr>
        </tbody>
      </table>
      <div class="actions">
        <button class="btn-save" @click="saveSection(section)" :disabled="section.saving">
          {{ section.saving ? '...' : 'Save' }}
        </button>
        <span v-if="section.saved" class="saved-msg">✓ Saved</span>
      </div>
    </div>

    <div class="card">
      <h3>Apply Changes</h3>
      <p class="hint">After editing configs above, apply to reload affected services.</p>
      <button class="btn-apply" @click="applyAll" :disabled="applying">
        {{ applying ? 'Applying...' : 'Apply Config' }}
      </button>
      <span v-if="applied" class="saved-msg">✓ Services reloaded</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const sections = ref([
  { title: 'Interfaces', data: {}, module: 'network.d.interface/lan', saving: false, saved: false },
  { title: 'DHCP Server', data: {}, module: 'network.d.dhcp/dhcp lan', saving: false, saved: false },
  { title: 'DNS', data: {}, module: 'network.d.dhcp/dhcp_option dns', saving: false, saved: false },
  { title: 'Firewall Zone', data: {}, module: 'network.d.zone/nas', saving: false, saved: false },
])
const applying = ref(false)
const applied = ref(false)

async function loadAll() {
  const res = await fetch('/api/config')
  const cfg = (await res.json()).config || {}
  for (const s of sections.value) {
    s.data = cfg[s.module] || {}
  }
}

async function saveSection(section) {
  section.saving = true; section.saved = false
  await fetch(`/api/config/${section.module.replace('.', '/')}`, {
    method: 'PUT', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(section.data)
  })
  section.saving = false; section.saved = true
}

async function applyAll() {
  applying.value = true; applied.value = false
  await fetch('/api/config/apply', { method: 'POST' })
  applying.value = false; applied.value = true
}

onMounted(loadAll)
</script>

<style scoped>
.network-section { display: flex; flex-direction: column; gap: 16px; }
.section-header h2 { font-size: 18px; }
.card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
.card h3 { font-size: 15px; margin-bottom: 8px; color: #555; }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 6px 12px; text-align: left; border-bottom: 1px solid #eee; font-size: 13px; }
th { color: #888; font-weight: 600; text-transform: uppercase; font-size: 11px; }
.mono { font-family: monospace; font-size: 12px; }
td input { width: 100%; padding: 4px 8px; border: 1px solid #ddd; border-radius: 3px; font-size: 13px; }
td input:focus { border-color: #3b82f6; outline: none; }
.empty { text-align: center; color: #bbb; }
.actions { margin-top: 12px; display: flex; align-items: center; gap: 8px; }
.btn-save, .btn-apply { padding: 6px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; }
.btn-save { background: #22c55e; color: #fff; }
.btn-apply { background: #3b82f6; color: #fff; }
.btn-save:disabled, .btn-apply:disabled { opacity: 0.5; }
.saved-msg { color: #22c55e; font-size: 13px; }
.hint { font-size: 13px; color: #888; margin-bottom: 8px; }
</style>
