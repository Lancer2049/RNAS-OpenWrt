<template>
  <div class="test-page">
    <h2 class="page-title">Test Results</h2>
    <p class="page-hint">Recent test runs — click to view details</p>

    <div class="test-card" v-if="regression">
      <div class="test-header">
        <h3>🧪 Regression Test</h3>
        <span class="badge" :class="regressionPassed ? 'pass' : 'fail'">{{ regressionPassed ? 'PASS' : 'FAIL' }}</span>
      </div>
      <pre class="test-output">{{ regression }}</pre>
    </div>
    <div class="test-card" v-else>
      <h3>🧪 Regression Test</h3>
      <p class="empty">Not yet run</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
const regression = ref('')
const regressionPassed = computed(() => regression.value.includes('0 failed'))

async function load() {
  try {
    const r = await fetch('/api/test/results')
    const d = await r.json()
    regression.value = d.regression || ''
  } catch {}
}
onMounted(load)
</script>

<style scoped>
.test-page{display:flex;flex-direction:column;gap:16px}
.test-card{background:#fff;padding:20px;border-radius:10px;box-shadow:0 2px 8px rgba(0,0,0,.06)}
.test-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:12px}
.test-header h3{font-size:15px}
.badge{padding:4px 12px;border-radius:6px;font-size:12px;font-weight:700}
.badge.pass{background:#dcfce7;color:#166534}.badge.fail{background:#fee2e2;color:#991b1b}
.test-output{background:#1e293b;color:#0f0;padding:14px;border-radius:6px;font-family:monospace;font-size:11px;max-height:400px;overflow-y:auto;white-space:pre-wrap}
.empty{color:#94a3b8;font-size:13px;padding:20px}
</style>
