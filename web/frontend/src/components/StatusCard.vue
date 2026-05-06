<template>
  <div class="dashboard-top">
    <div class="status-grid">
      <div class="card accent-blue">
        <div class="card-icon">⏱</div>
        <div><div class="card-label">Uptime</div><div class="card-value">{{ service.uptime||'--' }}</div></div>
      </div>
      <div class="card accent-green">
        <div class="card-icon">👥</div>
        <div><div class="card-label">Active Sessions</div><div class="card-value">{{ service.sessions_active||0 }}</div></div>
      </div>
      <div class="card accent-purple">
        <div class="card-icon">📡</div>
        <div><div class="card-label">RADIUS State</div><div class="card-value" :class="service.radius_state==='active'?'text-green':'text-red'">{{ service.radius_state||'--' }}</div></div>
      </div>
      <div class="card accent-orange">
        <div class="card-icon">🔐</div>
        <div><div class="card-label">Auth Sent</div><div class="card-value">{{ service.auth_sent||0 }}</div></div>
      </div>
      <div class="card accent-cyan">
        <div class="card-icon">📊</div>
        <div><div class="card-label">Acct Sent</div><div class="card-value">{{ service.acct_sent||0 }}</div></div>
      </div>
      <div class="card accent-red">
        <div class="card-icon">⚠️</div>
        <div><div class="card-label">Failures</div><div class="card-value" :class="service.radius_fail_count?'text-red':''">{{ service.radius_fail_count||0 }}</div></div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({ service: Object })
</script>

<style scoped>
.dashboard-top { margin-bottom: 20px; }
.status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(170px, 1fr)); gap: 12px; }
.card { background: #fff; padding: 16px 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); display: flex; align-items: center; gap: 14px; border-left: 4px solid #e2e8f0; transition: transform 0.15s, box-shadow 0.15s; }
.card:hover { transform: translateY(-2px); box-shadow: 0 4px 16px rgba(0,0,0,0.1); }
.card-icon { font-size: 28px; line-height: 1; }
.card-label { font-size: 10px; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 600; margin-bottom: 2px; }
.card-value { font-size: 22px; font-weight: 700; line-height: 1.2; }
.text-green { color: #22c55e; } .text-red { color: #ef4444; }
.accent-blue { border-left-color: #3b82f6; } .accent-green { border-left-color: #22c55e; }
.accent-purple { border-left-color: #8b5cf6; } .accent-orange { border-left-color: #f59e0b; }
.accent-cyan { border-left-color: #06b6d4; } .accent-red { border-left-color: #ef4444; }
</style>
