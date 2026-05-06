<template>
  <div class="quick-actions">
    <h3>Quick Actions</h3>
    <div class="actions-grid">
      <div class="action-card" @click="$emit('nav','subscriber-sim')">
        <span class="icon">👥</span><span class="label">Simulate Subscribers</span>
      </div>
      <div class="action-card" @click="$emit('nav','scenario-runner')">
        <span class="icon">▶</span><span class="label">Run Scenario</span>
      </div>
      <div class="action-card" @click="$emit('nav','radius-editor')">
        <span class="icon">🔧</span><span class="label">RADIUS Test</span>
      </div>
      <div class="action-card" @click="$emit('nav','sniffer')">
        <span class="icon">📡</span><span class="label">Capture Packets</span>
      </div>
      <div class="action-card" @click="$emit('refresh')">
        <span class="icon">🔄</span><span class="label">Refresh All</span>
      </div>
      <div class="action-card" @click="window.open('http://192.168.0.202:8000','_blank')">
        <span class="icon">🔗</span><span class="label">Open AirOS</span>
      </div>
    </div>
  </div>
</template>

<script setup>
defineEmits(['nav','refresh'])
</script>

<style scoped>
.quick-actions { margin-bottom: 20px; }
.quick-actions h3 { font-size: 14px; color: #64748b; margin-bottom: 10px; text-transform: uppercase; letter-spacing: 0.5px; }
.actions-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); gap: 8px; }
.action-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 8px; padding: 14px 16px; display: flex; flex-direction: column; align-items: center; gap: 6px; cursor: pointer; transition: all 0.15s; }
.action-card:hover { border-color: #3b82f6; box-shadow: 0 2px 8px rgba(59,130,246,0.15); transform: translateY(-1px); }
.action-card .icon { font-size: 24px; }
.action-card .label { font-size: 12px; color: #64748b; font-weight: 500; text-align: center; }
</style>
