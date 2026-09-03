<template>
  <div class="app-container">
    <Header 
      :lastUpdate="data.lastUpdate"
      :version="data.version"
      @refresh="handleRefresh"
    />
    
    <div class="main-content">
      <nav class="filter-nav">
        <OperatorFilter 
          :operators="data.operators"
          :selectedOperator="selectedOperator"
          @select="handleOperatorSelect"
        />
        <MetricFilter 
          :metrics="data.metrics"
          :selectedMetrics="selectedMetrics"
          @select="handleMetricSelect"
        />
      </nav>
      
      <main class="dashboard-main">
        <div class="view-tabs">
          <button 
            :class="['tab-btn', { active: currentView === 'overview' }]"
            @click="currentView = 'overview'"
          >
            📊 总览仪表盘
          </button>
          <button 
            :class="['tab-btn', { active: currentView === 'comparison' }]"
            @click="currentView = 'comparison'"
          >
            🔍 运营商对比
          </button>
          <button 
            :class="['tab-btn', { active: currentView === 'detail' }]"
            @click="currentView = 'detail'"
            :disabled="!selectedOperator"
          >
            📈 详情分析
          </button>
        </div>
        
        <OverviewDashboard 
          v-if="currentView === 'overview'"
          :data="data"
          :selectedOperator="selectedOperator"
          :selectedMetrics="selectedMetrics"
          @selectOperator="handleOperatorSelect"
        />
        
        <ComparisonView 
          v-if="currentView === 'comparison'"
          :data="data"
          :selectedMetrics="selectedMetrics"
        />
        
        <OperatorDetail 
          v-if="currentView === 'detail' && selectedOperator"
          :operator="getOperator(selectedOperator)"
          :operatorData="getOperatorData(selectedOperator)"
          :metrics="data.metrics"
          :rootCauseAnalysis="getRootCauseAnalysis(selectedOperator)"
        />
      </main>
    </div>
    
    <footer class="app-footer">
      <p>南部非洲运营商财报洞察看板 v1.0 | 数据来源：各运营商官方财报</p>
    </footer>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import Header from './components/Header.vue'
import OperatorFilter from './components/OperatorFilter.vue'
import MetricFilter from './components/MetricFilter.vue'
import OverviewDashboard from './components/OverviewDashboard.vue'
import ComparisonView from './components/ComparisonView.vue'
import OperatorDetail from './components/OperatorDetail.vue'

import telecomData from './data/telecom-data.json'

export default {
  name: 'App',
  components: {
    Header,
    OperatorFilter,
    MetricFilter,
    OverviewDashboard,
    ComparisonView,
    OperatorDetail
  },
  setup() {
    const data = ref(telecomData)
    const selectedOperator = ref(null)
    const selectedMetrics = ref(['revenue_growth', 'ebitda_margin', 'arpu', 'subscriber_growth'])
    const currentView = ref('overview')
    
    const handleOperatorSelect = (operatorId) => {
      selectedOperator.value = operatorId
      if (operatorId && currentView.value === 'overview') {
        currentView.value = 'detail'
      }
    }
    
    const handleMetricSelect = (metrics) => {
      selectedMetrics.value = metrics
    }
    
    const handleRefresh = () => {
      // 触发数据刷新
      alert('数据刷新功能：在实际部署中，这将触发从最新财报获取数据')
    }
    
    const getOperator = (operatorId) => {
      return data.value.operators.find(op => op.id === operatorId)
    }
    
    const getOperatorData = (operatorId) => {
      return data.value.quarterlyData.filter(d => d.operatorId === operatorId)
    }
    
    const getRootCauseAnalysis = (operatorId) => {
      return data.value.rootCauseAnalysis.filter(r => r.operatorId === operatorId)
    }
    
    return {
      data,
      selectedOperator,
      selectedMetrics,
      currentView,
      handleOperatorSelect,
      handleMetricSelect,
      handleRefresh,
      getOperator,
      getOperatorData,
      getRootCauseAnalysis
    }
  }
}
</script>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
  color: #e0e0e0;
  min-height: 100vh;
}

.app-container {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.main-content {
  flex: 1;
  display: flex;
  padding: 20px;
  gap: 20px;
}

.filter-nav {
  width: 280px;
  flex-shrink: 0;
}

.dashboard-main {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.view-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.tab-btn {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.1);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s ease;
}

.tab-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.2);
  transform: translateY(-2px);
}

.tab-btn.active {
  background: linear-gradient(135deg, #00d9ff 0%, #00b4d8 100%);
  color: #1a1a2e;
  box-shadow: 0 4px 15px rgba(0, 217, 255, 0.3);
}

.tab-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.app-footer {
  padding: 15px 20px;
  background: rgba(0, 0, 0, 0.3);
  text-align: center;
  font-size: 12px;
  color: #888;
}

/* 响应式设计 */
@media (max-width: 1024px) {
  .main-content {
    flex-direction: column;
  }
  
  .filter-nav {
    width: 100%;
  }
}

@media (max-width: 768px) {
  .view-tabs {
    flex-wrap: wrap;
  }
  
  .tab-btn {
    flex: 1;
    min-width: 120px;
  }
}
</style>