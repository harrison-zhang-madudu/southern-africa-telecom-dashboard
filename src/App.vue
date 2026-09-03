<template>
  <div class="app">
    <Header 
      :lastUpdate="enhancedData.metadata.lastUpdatedSA"
      :dataSource="enhancedData.metadata.dataSource"
      @refresh="handleRefresh"
    />
    
    <div class="main-content">
      <!-- 左侧筛选面板 -->
      <aside class="filter-panel">
        <OperatorFilter 
          :operators="enhancedData.operators"
          v-model:selectedOperators="selectedOperators"
        />
        <MetricFilter 
          :metrics="availableMetrics"
          v-model:selectedMetrics="selectedMetrics"
        />
        
        <!-- 年份筛选 -->
        <div class="year-filter">
          <h3>📅 年份筛选</h3>
          <div class="year-buttons">
            <button 
              v-for="year in availableYears"
              :key="year"
              :class="{ active: selectedYears.includes(year) }"
              @click="toggleYear(year)"
            >
              {{ year }}
            </button>
          </div>
        </div>
        
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
            <button 
              :class="{ active: currentView === 'macro' }"
              @click="currentView = 'macro'"
            >
              🌍 宏观
            </button>
          </div>
        </div>
        
        <!-- 数据说明 -->
        <DataInfo :metadata="enhancedData.metadata" />
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
        <div v-if="currentView === 'detail'" class="detail-view">
          <div v-for="operator in filteredOperators" :key="operator.id" class="operator-section">
            <div class="operator-header-enhanced">
              <div class="operator-info">
                <h2>{{ operator.flag }} {{ operator.name }}</h2>
                <p class="country">{{ operator.country }} | {{ operator.currency }}</p>
              </div>
              
              <!-- 股价信息 -->
              <StockInfo v-if="operator.stock && !operator.stock.isPrivate" :stock="operator.stock" />
              <div v-else class="private-company">
                <span class="private-badge">🔒 私有公司</span>
                <span class="private-note">{{ operator.stock?.note || '无公开股价数据' }}</span>
              </div>
            </div>
            
            <!-- 财报链接 -->
            <InvestorLinks 
              :investorRelations="operator.investorRelations"
              :fiscalYear="operator.fiscalYear"
            />
            
            <!-- 详情内容 -->
            <OperatorDetail 
              :operators="[operator]"
              :selectedMetrics="selectedMetrics"
              :quarterlyData="getOperatorQuarterlyData(operator.id)"
            />
          </div>
        </div>
        
        <!-- 宏观视图 -->
        <div v-if="currentView === 'macro'" class="macro-view">
          <MacroNews :macroData="enhancedData.macroData" />
          
          <!-- 运营商股价概览 -->
          <div class="stock-overview">
            <h3>📈 运营商股价概览</h3>
            <div class="stock-grid">
              <div 
                v-for="operator in filteredOperators.filter(o => o.stock && !o.stock.isPrivate)" 
                :key="operator.id"
                class="stock-card"
              >
                <div class="stock-card-header">
                  <span class="flag">{{ operator.flag }}</span>
                  <span class="name">{{ operator.shortName }}</span>
                </div>
                <StockInfo :stock="operator.stock" />
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
    
    <!-- AI刷新状态提示 -->
    <div v-if="refreshing" class="refresh-overlay">
      <div class="refresh-spinner"></div>
      <span>AI 正在刷新数据...</span>
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
import DataInfo from './components/DataInfo.vue'
import StockInfo from './components/StockInfo.vue'
import MacroNews from './components/MacroNews.vue'
import InvestorLinks from './components/InvestorLinks.vue'

import enhancedData from './data/enhanced-data.json'

// 数据
const data = ref(enhancedData)

// 筛选状态
const selectedOperators = ref([])
const selectedMetrics = ref(['revenue', 'ebitdaMargin', 'subscriberGrowth', 'arpu', 'capexRatio'])
const selectedYears = ref([2024, 2025, 2026])
const currentView = ref('overview')
const refreshing = ref(false)

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

// 可用年份
const availableYears = computed(() => {
  return [2022, 2023, 2024, 2025, 2026]
})

// 切换年份
const toggleYear = (year) => {
  const index = selectedYears.value.indexOf(year)
  if (index > -1) {
    selectedYears.value.splice(index, 1)
  } else {
    selectedYears.value.push(year)
    selectedYears.value.sort((a, b) => a - b)
  }
}

// 筛选后的运营商
const filteredOperators = computed(() => {
  return data.value.operators.filter(op => selectedOperators.value.includes(op.id))
})

// 筛选后的季度数据
const filteredQuarterlyData = computed(() => {
  return (data.value.quarterlyData || [])
    .filter(d => selectedOperators.value.includes(d.operatorId))
    .filter(d => {
      const year = parseInt(d.period.substring(0, 4))
      return selectedYears.value.includes(year)
    })
})

// 获取单个运营商的季度数据
const getOperatorQuarterlyData = (operatorId) => {
  return (data.value.quarterlyData || [])
    .filter(d => d.operatorId === operatorId)
    .filter(d => {
      const year = parseInt(d.period.substring(0, 4))
      return selectedYears.value.includes(year)
    })
}

// AI刷新处理
const handleRefresh = async () => {
  refreshing.value = true
  // 模拟刷新过程
  await new Promise(resolve => setTimeout(resolve, 2000))
  refreshing.value = false
  alert('数据刷新完成！')
}

// 暴露给模板的数据（已在上方定义）
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
  width: 300px;
  background: rgba(15, 23, 42, 0.95);
  border-right: 1px solid rgba(148, 163, 184, 0.1);
  padding: 20px;
  overflow-y: auto;
  backdrop-filter: blur(10px);
}

/* 年份筛选 */
.year-filter {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid rgba(148, 163, 184, 0.1);
}

.year-filter h3 {
  font-size: 12px;
  font-weight: 600;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 12px;
}

.year-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.year-buttons button {
  padding: 6px 12px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.5);
  color: #cbd5e1;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.year-buttons button:hover {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.3);
}

.year-buttons button.active {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-color: #3b82f6;
  color: white;
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

/* 详情视图 */
.detail-view {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.operator-section {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 16px;
  padding: 24px;
}

.operator-header-enhanced {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 20px;
  gap: 20px;
  flex-wrap: wrap;
}

.operator-info h2 {
  font-size: 24px;
  color: #e2e8f0;
  margin-bottom: 4px;
}

.operator-info .country {
  font-size: 14px;
  color: #64748b;
}

.private-company {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 16px;
  background: rgba(15, 23, 42, 0.5);
  border-radius: 12px;
  border: 1px dashed rgba(148, 163, 184, 0.2);
}

.private-badge {
  font-size: 14px;
  color: #94a3b8;
}

.private-note {
  font-size: 12px;
  color: #64748b;
}

/* 宏观视图 */
.macro-view {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.stock-overview {
  background: rgba(30, 41, 59, 0.8);
  border-radius: 16px;
  padding: 20px;
}

.stock-overview h3 {
  font-size: 20px;
  color: #e2e8f0;
  margin-bottom: 16px;
}

.stock-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
  gap: 16px;
}

.stock-card {
  background: rgba(15, 23, 42, 0.5);
  border-radius: 12px;
  padding: 16px;
}

.stock-card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.stock-card-header .flag {
  font-size: 20px;
}

.stock-card-header .name {
  font-size: 16px;
  font-weight: 600;
  color: #e2e8f0;
}

/* 刷新状态 */
.refresh-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.9);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
  z-index: 1000;
}

.refresh-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid rgba(59, 130, 246, 0.2);
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
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