<template>
  <div class="tool-section">
    <h2>Scheduler</h2>
    <p class="hint">Automated test runs — run regression/benchmark on schedule</p>
    <div class="add-form">
      <input v-model="newName" placeholder="Task name" class="field" />
      <select v-model="newAction" class="field">
        <option value="regression">Regression Test</option>
        <option value="benchmark">Benchmark</option>
        <option value="vsa-smoke">VSA Smoke Test</option>
      </select>
      <input v-model="newInterval" placeholder="Interval (minutes)" type="number" class="field" min="1" />
      <button @click="addTask" class="btn-add">+ Add</button>
    </div>
    <table v-if="tasks.length">
      <thead><tr><th>Name</th><th>Action</th><th>Interval</th><th>Last Run</th><th>Next Run</th><th></th></tr></thead>
      <tbody>
        <tr v-for="t in tasks" :key="t.name"><td>{{ t.name }}</td><td>{{ t.action }}</td><td>{{ t.interval }}m</td><td>{{ t.last || '-' }}</td><td>{{ t.next || '-' }}</td><td><button @click="removeTask(t.name)" class="btn-del">✕</button></td></tr>
      </tbody>
    </table>
    <div v-else class="empty">No scheduled tasks</div>
  </div>
</template>
<script setup>
import { ref, reactive } from 'vue'
const tasks = reactive([]), newName=ref(''), newAction=ref('regression'), newInterval=ref(60)
function addTask(){if(!newName.value)return;tasks.push({name:newName.value,action:newAction.value,interval:newInterval.value,last:'',next:new Date(Date.now()+newInterval.value*60000).toLocaleTimeString()});newName.value=''}
function removeTask(name){const i=tasks.findIndex(t=>t.name===name);if(i>=0)tasks.splice(i,1)}
</script>
<style scoped>
.tool-section{display:flex;flex-direction:column;gap:12px} h2{font-size:18px} .hint{font-size:13px;color:#888}
.add-form{display:flex;gap:8px;flex-wrap:wrap;background:#fff;padding:12px;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
.field{padding:6px 10px;border:1px solid #ddd;border-radius:4px;font-size:13px}
.btn-add{padding:6px 16px;background:#22c55e;color:#fff;border:none;border-radius:6px;cursor:pointer;font-size:13px;font-weight:600}
table{width:100%;border-collapse:collapse;background:#fff;border-radius:8px;box-shadow:0 1px 3px rgba(0,0,0,.08);font-size:13px}
th,td{padding:8px 10px;text-align:left;border-bottom:1px solid #eee} th{color:#666;font-weight:600;font-size:11px;text-transform:uppercase}
.btn-del{padding:2px 8px;background:#fee;border:1px solid #fcc;border-radius:3px;cursor:pointer;font-size:12px;color:#c33}
.empty{text-align:center;color:#999;padding:40px}
</style>
