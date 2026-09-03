<template>
  <div class="app">
    <Header 
      :lastUpdate="data.metadata.lastUpdate"
      :dataSource="data.metadata.dataSource"
    />
    
    <div class="main-content">
      <!-- 左侧筛选面板 -->
      <aside class="filter-panel">
        <OperatorFilter 
          :operators="data.operators"
          v-model:selectedOperators="selectedOperators"
        />
        <MetricFilter 
          :metrics="availableMetrics"
          v-model:selectedMetrics="selectedMetrics"
        />
        
        <div class="view-switcher">
          <h3>视图模式</h3>
          <div class="view-buttons">
            <button 
              :class="{ active: currentView === 'overview' }"
              @click="currentView = 'overview'"
            >
              📊 总览
            </button>
            <button 
              :class="{ active: currentView === 'comparison' }"
              @click="currentView = 'comparison'"
            >
              ⚖️ 对比
            </button>
            <button 
              :class="{ active: currentView === 'detail' }"
              @click="currentView = 'detail'"
            >
              📋 详情
            </button>
          </div>
        </div>
      </aside>
      
      <!-- 主内容区 -->
      <main class="content-area">
        <!-- 总览视图 -->
        <OverviewDashboard 
          v-if="currentView === 'overview'"
          :operators="filteredOperators"
          :selectedMetrics="selectedMetrics"
          :quarterlyData="filteredQuarterlyData"
        />
        
        <!-- 对比视图 -->
        <ComparisonView 
          v-if="currentView === 'comparison'"
          :operators="filteredOperators"
          :selectedMetrics="selectedMetrics"
          :quarterlyData="filteredQuarterlyData"
        />
        
        <!-- 详情视图 -->
        <OperatorDetail 
          v-if="currentView === 'detail'"
          :operators="filteredOperators"
          :selectedMetrics="selectedMetrics"
          :quarterlyData="filteredQuarterlyData"
        />
      </main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Header from './components/Header.vue'
import OperatorFilter from './components/OperatorFilter.vue'
import MetricFilter from './components/MetricFilter.vue'
import OverviewDashboard from './components/OverviewDashboard.vue'
import ComparisonView from './components/ComparisonView.vue'
import OperatorDetail from './components/OperatorDetail.vue'

import telecomData from './data/telecom-data.json'

// 数据
const data = ref(telecomData)

// 筛选状态
const selectedOperators = ref([])
const selectedMetrics = ref(['revenue', 'ebitdaMargin', 'subscriberGrowth', 'arpu', 'capexRatio'])
const currentView = ref('overview')

// 初始化选中所有运营商
onMounted(() => {
  selectedOperators.value = data.value.operators.map(op => op.id)
})

// 可用指标列表
const availableMetrics = computed(() => {
  return [
    { id: 'revenue', name: '营业收入', unit: '亿美元', icon: '💰' },
    { id: 'ebitdaMargin', name: 'EBITDA利润率', unit: '%', icon: '📈' },
    { id: 'subscriberGrowth', name: '订户增长率', unit: '%', icon: '👥' },
    { id: 'arpu', name: 'ARPU', unit: '美元', icon: '💵' },
    { id: 'capexRatio', name: '资本开支比', unit: '%', icon: '🏗️' },
    { id: 'debtRatio', name: '负债率', unit: '%', icon: '📊' },
    { id: 'fcf', name: '自由现金流', unit: '亿美元', icon: '💸' },
    { id: 'churnRate', name: '流失率', unit: '%', icon: '📉' }
  ]
})

// 筛选后的运营商
const filteredOperators = computed(() => {
  return data.value.operators.filter(op => selectedOperators.value.includes(op.id))
})

// 筛选后的季度数据
const filteredQuarterlyData = computed(() => {
  return data.value.quarterlyData.filter(d => selectedOperators.value.includes(d.operatorId))
})
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Inter', 'Segoe UI', system-ui, -apple-system, sans-serif;
  background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
  color: #e2e8f0;
  min-height: 100vh;
}

.app {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  display: flex;
  flex: 1;
  gap: 0;
}

/* 左侧筛选面板 */
.filter-panel {
  width: 280px;
  background: rgba(15, 23, 42, 0.95);
  border-right: 1px solid rgba(148, 163, 184, 0.1);
  padding: 20px;
  overflow-y: auto;
  backdrop-filter: blur(10px);
}

/* 视图切换 */
.view-switcher {
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid rgba(148, 163, 184, 0.1);
}

.view-switcher h3 {
  font-size: 12px;
  font-weight: 600;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 12px;
}

.view-buttons {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.view-buttons button {
  padding: 12px 16px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 8px;
  background: rgba(30, 41, 59, 0.5);
  color: #cbd5e1;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;
}

.view-buttons button:hover {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.3);
  color: #e2e8f0;
}

.view-buttons button.active {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-color: #3b82f6;
  color: white;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

/* 主内容区 */
.content-area {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  background: rgba(15, 23, 42, 0.3);
}

/* 滚动条样式 */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: rgba(15, 23, 42, 0.5);
}

::-webkit-scrollbar-thumb {
  background: rgba(148, 163, 184, 0.3);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: rgba(148, 163, 184, 0.5);
}

/* 响应式 */
@media (max-width: 1024px) {
  .main-content {
    flex-direction: column;
  }
  
  .filter-panel {
    width: 100%;
    border-right: none;
    border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  }
}
</style>
