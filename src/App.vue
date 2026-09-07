<template>
  <div class="app">
    <Header 
      :lastUpdate="currentTime"
      :dataSource="enhancedData.metadata.dataSource"
      :currentView="currentView"
      :sidebarCollapsed="sidebarCollapsed"
      :refreshing="refreshing"
      @refresh="handleRefresh"
      @update:currentView="currentView = $event"
      @toggleSidebar="sidebarCollapsed = !sidebarCollapsed"
    />
    
    <div class="main-content">
      <!-- 左侧筛选面板（可折叠） -->
      <aside class="filter-panel" :class="{ collapsed: sidebarCollapsed }">
        <div class="filter-panel-content">
          <OperatorFilter 
            :operators="enhancedData.operators"
            v-model:selectedOperators="selectedOperators"
          />
          <MetricFilter 
            :metrics="availableMetrics"
            v-model:selectedMetrics="selectedMetrics"
          />
          
          <!-- 数据说明 -->
          <DataInfo :metadata="enhancedData.metadata" />
        </div>
      </aside>
      
      <!-- 主内容区 -->
      <main class="content-area" :class="{ expanded: sidebarCollapsed }">
        <!-- 总览视图 -->
        <OverviewDashboard 
          v-if="currentView === 'overview'"
          :operators="filteredOperators"
          :selectedMetrics="selectedMetrics"
          :quarterlyData="filteredQuarterlyData"
          :selectedYear="selectedYear"
          :availableYears="availableYears"
          :allQuarterlyData="enhancedData.quarterlyData || []"
          @update:selectedYear="selectedYear = $event"
        />
        
        <!-- 对比视图 -->
        <ComparisonView 
          v-if="currentView === 'comparison'"
          :operators="filteredOperators"
          :selectedMetrics="selectedMetrics"
          :quarterlyData="filteredQuarterlyData"
          :selectedYear="selectedYear"
          :availableYears="availableYears"
          @update:selectedYear="selectedYear = $event"
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

import enhancedDataJson from './data/enhanced-data.json'

// 数据 - 直接使用普通对象
const enhancedData = enhancedDataJson

// 筛选状态
const selectedOperators = ref([])
const selectedMetrics = ref(['revenue', 'ebitdaMargin', 'subscriberGrowth', 'arpu', 'capexRatio'])
const selectedYear = ref(2026) // 改为单选，默认最新年份
const currentView = ref('overview')
const refreshing = ref(false)
const sidebarCollapsed = ref(false) // 侧边栏折叠状态
const currentTime = ref('') // 当前显示时间

// 更新当前时间
const updateCurrentTime = () => {
  const now = new Date()
  const year = now.getFullYear()
  const month = String(now.getMonth() + 1).padStart(2, '0')
  const day = String(now.getDate()).padStart(2, '0')
  const hours = String(now.getHours()).padStart(2, '0')
  const minutes = String(now.getMinutes()).padStart(2, '0')
  currentTime.value = `${year}年${month}月${day}日 ${hours}:${minutes} SAST`
}

// 初始化时间
updateCurrentTime()

// 初始化选中所有运营商
onMounted(() => {
  selectedOperators.value = enhancedData.operators.map(op => op.id)
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

// 可用年份 - 只显示有数据的年份
const availableYears = computed(() => {
  return [2024, 2025, 2026]
})

// 筛选后的运营商
const filteredOperators = computed(() => {
  return enhancedData.operators.filter(op => selectedOperators.value.includes(op.id))
})

// 筛选后的季度数据 - 使用单选年份
const filteredQuarterlyData = computed(() => {
  return (enhancedData.quarterlyData || [])
    .filter(d => selectedOperators.value.includes(d.operatorId))
    .filter(d => {
      const year = parseInt(d.period.substring(0, 4))
      return year === selectedYear.value
    })
})

// 获取单个运营商的季度数据
const getOperatorQuarterlyData = (operatorId) => {
  return (enhancedData.quarterlyData || [])
    .filter(d => d.operatorId === operatorId)
    .filter(d => {
      const year = parseInt(d.period.substring(0, 4))
      return year === selectedYear.value
    })
}

// AI刷新处理
const handleRefresh = async () => {
  refreshing.value = true
  // 模拟刷新过程
  await new Promise(resolve => setTimeout(resolve, 1500))
  // 更新当前时间
  updateCurrentTime()
  refreshing.value = false
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
  font-family: 'Inter', 'SF Pro Display', 'Segoe UI', system-ui, -apple-system, sans-serif;
  background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #1e293b 100%);
  color: #e2e8f0;
  min-height: 100vh;
  overflow-x: hidden;
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
  min-width: 280px;
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.98) 0%, rgba(30, 41, 59, 0.95) 100%);
  border-right: 1px solid rgba(99, 102, 241, 0.15);
  overflow-y: auto;
  overflow-x: hidden;
  backdrop-filter: blur(16px);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.2);
}

.filter-panel.collapsed {
  width: 0;
  min-width: 0;
  border-right: none;
  box-shadow: none;
}

.filter-panel-content {
  padding: 20px;
  opacity: 1;
  transition: opacity 0.2s;
}

.filter-panel.collapsed .filter-panel-content {
  opacity: 0;
  pointer-events: none;
}

/* 详情视图 */
.content-area {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.4) 0%, rgba(30, 41, 59, 0.3) 100%);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.content-area.expanded {
  padding: 24px 40px;
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
    min-width: 100%;
    border-right: none;
    border-bottom: 1px solid rgba(99, 102, 241, 0.15);
  }
  
  .filter-panel.collapsed {
    height: 0;
    min-height: 0;
    width: 100%;
    min-width: 100%;
  }
}
</style>