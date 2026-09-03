<template>
  <div class="operator-detail">
    <!-- 运营商选择 -->
    <section class="selector-section">
      <h2>
        <span class="icon">🔍</span>
        选择运营商查看详情
      </h2>
      
      <div class="operator-tabs">
        <button 
          v-for="op in operators" 
          :key="op.id"
          :class="{ active: selectedOperator === op.id }"
          @click="selectedOperator = op.id"
        >
          {{ getFlag(op.country) }} {{ op.name }}
        </button>
      </div>
    </section>
    
    <template v-if="currentOperator">
      <!-- 基本信息 -->
      <section class="info-section">
        <div class="info-header">
          <div class="info-main">
            <span class="flag">{{ getFlag(currentOperator.country) }}</span>
            <div class="name-info">
              <h2>{{ currentOperator.name }}</h2>
              <span class="country">{{ currentOperator.country }}</span>
            </div>
          </div>
          <div class="info-stats">
            <div class="stat">
              <span class="stat-label">用户规模</span>
              <span class="stat-value">{{ formatNumber(currentOperator.subscribers) }}</span>
            </div>
            <div class="stat">
              <span class="stat-label">最新季度</span>
              <span class="stat-value">{{ latestQuarter }}</span>
            </div>
          </div>
        </div>
      </section>
      
      <!-- 核心指标仪表盘 -->
      <section class="gauges-section">
        <h3>
          <span class="icon">📊</span>
          核心指标仪表盘
        </h3>
        
        <div class="gauges-grid">
          <div 
            v-for="metric in gaugeMetrics" 
            :key="metric.id"
            class="gauge-card"
          >
            <GaugeChart 
              :value="metric.value"
              :max="metric.max"
              :title="metric.name"
              :unit="metric.unit"
              :color="metric.color"
            />
          </div>
        </div>
      </section>
      
      <!-- 指标趋势 -->
      <section class="trends-section">
        <h3>
          <span class="icon">📈</span>
          指标趋势
        </h3>
        
        <div class="metric-tabs">
          <button 
            v-for="m in selectedMetrics" 
            :key="m"
            :class="{ active: activeMetric === m }"
            @click="activeMetric = m"
          >
            {{ getMetricName(m) }}
          </button>
        </div>
        
        <div class="trend-chart-container">
          <SingleTrendChart 
            :data="operatorTrendData"
            :metricName="getMetricName(activeMetric)"
            :metricUnit="getMetricUnit(activeMetric)"
          />
        </div>
      </section>
      
      <!-- 根因分析 -->
      <section class="root-cause-section">
        <h3>
          <span class="icon">🔬</span>
          根因分析
        </h3>
        
        <div class="root-cause-content">
          <!-- 指标变化概述 -->
          <div class="change-summary">
            <div class="change-card" :class="overallChange.trend">
              <div class="change-icon">
                {{ overallChange.trend === 'up' ? '📈' : overallChange.trend === 'down' ? '📉' : '➡️' }}
              </div>
              <div class="change-info">
                <div class="change-label">{{ getMetricName(activeMetric) }}</div>
                <div class="change-value">
                  {{ overallChange.change > 0 ? '+' : '' }}{{ overallChange.change.toFixed(2) }}
                  <span class="change-percent">({{ overallChange.percent.toFixed(1) }}%)</span>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 主要因素 -->
          <div class="factors-section">
            <h4>主要影响因素</h4>
            <div class="factors-list">
              <div 
                v-for="factor in rootCauseFactors" 
                :key="factor.id"
                class="factor-item"
                :class="factor.impact"
              >
                <div class="factor-header">
                  <span class="factor-icon">{{ factor.icon }}</span>
                  <span class="factor-name">{{ factor.name }}</span>
                  <span class="factor-contribution">{{ factor.contribution }}%</span>
                </div>
                <div class="factor-bar">
                  <div 
                    class="bar-fill"
                    :style="{ width: factor.contribution + '%' }"
                  ></div>
                </div>
                <div class="factor-desc">{{ factor.description }}</div>
              </div>
            </div>
          </div>
          
          <!-- 风险与机会 -->
          <div class="risk-opportunity">
            <div class="risks">
              <h4>⚠️ 潜在风险</h4>
              <ul>
                <li v-for="risk in risks" :key="risk">{{ risk }}</li>
              </ul>
            </div>
            <div class="opportunities">
              <h4>✨ 改善机会</h4>
              <ul>
                <li v-for="opp in opportunities" :key="opp">{{ opp }}</li>
              </ul>
            </div>
          </div>
        </div>
      </section>
    </template>
    
    <div v-else class="no-selection">
      <div class="placeholder">
        <span class="icon">👈</span>
        <p>请选择一个运营商查看详细分析</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import GaugeChart from './GaugeChart.vue'
import SingleTrendChart from './SingleTrendChart.vue'

const props = defineProps({
  operators: Array,
  selectedMetrics: Array,
  quarterlyData: Array
})

const selectedOperator = ref(null)
const activeMetric = ref(props.selectedMetrics[0] || 'revenue')

// 当前运营商信息
const currentOperator = computed(() => {
  if (!selectedOperator.value) return null
  return props.operators.find(op => op.id === selectedOperator.value)
})

// 运营商季度数据
const operatorQuarterlyData = computed(() => {
  if (!selectedOperator.value) return []
  return props.quarterlyData
    .filter(d => d.operatorId === selectedOperator.value)
    .sort((a, b) => a.quarter.localeCompare(b.quarter))
})

// 最新季度
const latestQuarter = computed(() => {
  if (!operatorQuarterlyData.value.length) return '-'
  const sorted = [...operatorQuarterlyData.value].sort((a, b) => b.quarter.localeCompare(a.quarter))
  return sorted[0]?.quarter || '-'
})

// 仪表盘指标
const gaugeMetrics = computed(() => {
  if (!operatorQuarterlyData.value.length) return []
  
  const latest = operatorQuarterlyData.value[operatorQuarterlyData.value.length - 1]
  
  return [
    { 
      id: 'ebitdaMargin',
      name: 'EBITDA利润率',
      value: latest?.ebitdaMargin || 0,
      max: 60,
      unit: '%',
      color: '#10b981'
    },
    { 
      id: 'subscriberGrowth',
      name: '订户增长率',
      value: Math.max(0, latest?.subscriberGrowth || 0),
      max: 20,
      unit: '%',
      color: '#3b82f6'
    },
    { 
      id: 'arpu',
      name: 'ARPU',
      value: latest?.arpu || 0,
      max: 15,
      unit: '$',
      color: '#f59e0b'
    },
    { 
      id: 'debtRatio',
      name: '负债率',
      value: 100 - (latest?.debtRatio || 0),
      max: 100,
      unit: '%',
      color: latest?.debtRatio > 70 ? '#ef4444' : '#10b981'
    }
  ]
})

// 趋势数据
const operatorTrendData = computed(() => {
  return operatorQuarterlyData.value.map(d => ({
    quarter: d.quarter,
    value: d[activeMetric.value] || 0
  }))
})

// 整体变化
const overallChange = computed(() => {
  if (operatorTrendData.value.length < 2) {
    return { change: 0, percent: 0, trend: 'stable' }
  }
  
  const data = operatorTrendData.value
  const latest = data[data.length - 1].value
  const previous = data[data.length - 2].value
  const change = latest - previous
  const percent = previous !== 0 ? (change / Math.abs(previous)) * 100 : 0
  
  return {
    change,
    percent,
    trend: change > 0 ? 'up' : change < 0 ? 'down' : 'stable'
  }
})

// 根因分析因素
const rootCauseFactors = computed(() => {
  if (!currentOperator.value) return []
  
  // 根据运营商和指标生成分析因素
  const factors = []
  const latest = operatorQuarterlyData.value[operatorQuarterlyData.value.length - 1]
  
  // 基于实际数据的分析
  if (latest) {
    if (latest.subscriberGrowth < 5) {
      factors.push({
        id: 'competition',
        name: '市场竞争加剧',
        icon: '⚔️',
        contribution: 35,
        impact: 'negative',
        description: '区域内新进入者增加，价格战激烈'
      })
    }
    
    if (latest.arpu < 5) {
      factors.push({
        id: 'arpu',
        name: 'ARPU下滑',
        icon: '📉',
        contribution: 25,
        impact: 'negative',
        description: '低端用户占比提升，套餐ARPU下降'
      })
    }
    
    if (latest.ebitdaMargin > 40) {
      factors.push({
        id: 'efficiency',
        name: '运营效率提升',
        icon: '⚡',
        contribution: 30,
        impact: 'positive',
        description: '网络共享、运维自动化降低成本'
      })
    }
    
    if (latest.capexRatio > 20) {
      factors.push({
        id: 'capex',
        name: '资本开支增加',
        icon: '🏗️',
        contribution: 20,
        impact: 'negative',
        description: '5G网络建设投入加大，短期利润承压'
      })
    }
    
    if (latest.churnRate > 3) {
      factors.push({
        id: 'churn',
        name: '用户流失',
        icon: '🚪',
        contribution: 15,
        impact: 'negative',
        description: '竞品促销导致部分用户转网'
      })
    }
  }
  
  // 补充默认因素
  if (factors.length < 3) {
    factors.push({
      id: 'macro',
      name: '宏观环境影响',
      icon: '🌍',
      contribution: 15,
      impact: 'neutral',
      description: '汇率波动、通胀影响运营成本'
    })
  }
  
  return factors.slice(0, 5)
})

// 风险列表
const risks = computed(() => {
  const riskList = []
  const latest = operatorQuarterlyData.value[operatorQuarterlyData.value.length - 1]
  
  if (latest) {
    if (latest.debtRatio > 70) riskList.push('高负债率可能影响融资能力和财务稳健性')
    if (latest.churnRate > 4) riskList.push('用户流失率较高，需加强客户维系')
    if (latest.subscriberGrowth < 0) riskList.push('订户负增长，市场份额可能流失')
    if (latest.fcf < 0) riskList.push('自由现金流为负，投资能力受限')
  }
  
  if (riskList.length === 0) {
    riskList.push('暂无明显风险信号')
  }
  
  return riskList
})

// 机会列表
const opportunities = computed(() => {
  const oppList = []
  const latest = operatorQuarterlyData.value[operatorQuarterlyData.value.length - 1]
  
  if (latest) {
    if (latest.ebitdaMargin > 40) oppList.push('高盈利能力为投资和创新提供资金支持')
    if (latest.subscriberGrowth > 5) oppList.push('订户快速增长，规模效应显现')
    if (latest.arpu > 8) oppList.push('ARPU较高，用户价值挖掘空间大')
    if (latest.fcf > 1) oppList.push('充裕的自由现金流，可加大分红或投资')
  }
  
  if (oppList.length === 0) {
    oppList.push('关注市场机会，持续改善运营')
  }
  
  return oppList
})

// 辅助方法
const getFlag = (country) => {
  const flags = {
    'South Africa': '🇿🇦',
    'Nigeria': '🇳🇬',
    'Zimbabwe': '🇿🇼'
  }
  return flags[country] || '🌍'
}

const formatNumber = (num) => {
  if (num >= 100) return (num / 1000).toFixed(1) + '亿'
  return num + 'M'
}

const getMetricName = (id) => {
  const names = {
    revenue: '营业收入',
    ebitdaMargin: 'EBITDA利润率',
    subscriberGrowth: '订户增长率',
    arpu: 'ARPU',
    capexRatio: '资本开支比',
    debtRatio: '负债率',
    fcf: '自由现金流',
    churnRate: '流失率'
  }
  return names[id] || id
}

const getMetricUnit = (id) => {
  const units = {
    revenue: '亿美元',
    ebitdaMargin: '%',
    subscriberGrowth: '%',
    arpu: '美元',
    capexRatio: '%',
    debtRatio: '%',
    fcf: '亿美元',
    churnRate: '%'
  }
  return units[id] || ''
}
</script>

<style scoped>
.operator-detail {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

section {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.1);
  padding: 20px;
}

h2, h3 {
  font-size: 16px;
  font-weight: 600;
  color: #f1f5f9;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

h4 {
  font-size: 14px;
  font-weight: 600;
  color: #f1f5f9;
  margin-bottom: 12px;
}

/* 运营商选择 */
.operator-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.operator-tabs button {
  padding: 10px 16px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 8px;
  background: rgba(30, 41, 59, 0.5);
  color: #94a3b8;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.operator-tabs button:hover {
  border-color: rgba(59, 130, 246, 0.3);
  color: #e2e8f0;
}

.operator-tabs button.active {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-color: #3b82f6;
  color: white;
}

/* 基本信息 */
.info-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.info-main {
  display: flex;
  align-items: center;
  gap: 16px;
}

.flag {
  font-size: 40px;
}

.name-info h2 {
  margin: 0;
  font-size: 24px;
}

.country {
  color: #94a3b8;
  font-size: 14px;
}

.info-stats {
  display: flex;
  gap: 32px;
}

.stat {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.stat-label {
  font-size: 12px;
  color: #64748b;
}

.stat-value {
  font-size: 18px;
  font-weight: 600;
  color: #f1f5f9;
}

/* 仪表盘 */
.gauges-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 16px;
}

.gauge-card {
  background: rgba(15, 23, 42, 0.3);
  border-radius: 10px;
  padding: 16px;
  height: 180px;
}

/* 趋势 */
.metric-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.metric-tabs button {
  padding: 8px 14px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.5);
  color: #94a3b8;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.metric-tabs button:hover {
  border-color: rgba(59, 130, 246, 0.3);
  color: #e2e8f0;
}

.metric-tabs button.active {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.trend-chart-container {
  height: 250px;
}

/* 根因分析 */
.root-cause-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.change-summary {
  display: flex;
  justify-content: center;
}

.change-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 32px;
  border-radius: 12px;
  border: 1px solid;
}

.change-card.up {
  background: rgba(34, 197, 94, 0.1);
  border-color: rgba(34, 197, 94, 0.3);
}

.change-card.down {
  background: rgba(239, 68, 68, 0.1);
  border-color: rgba(239, 68, 68, 0.3);
}

.change-card.stable {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.3);
}

.change-icon {
  font-size: 32px;
}

.change-label {
  font-size: 14px;
  color: #94a3b8;
}

.change-value {
  font-size: 24px;
  font-weight: 700;
  color: #f1f5f9;
}

.change-percent {
  font-size: 14px;
  color: #94a3b8;
}

/* 因素列表 */
.factors-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.factor-item {
  padding: 16px;
  background: rgba(15, 23, 42, 0.3);
  border-radius: 8px;
  border-left: 3px solid;
}

.factor-item.positive {
  border-left-color: #10b981;
}

.factor-item.negative {
  border-left-color: #ef4444;
}

.factor-item.neutral {
  border-left-color: #3b82f6;
}

.factor-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.factor-icon {
  font-size: 16px;
}

.factor-name {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
  color: #f1f5f9;
}

.factor-contribution {
  font-size: 13px;
  font-weight: 600;
  color: #60a5fa;
}

.factor-bar {
  height: 4px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 2px;
  margin-bottom: 8px;
}

.bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #60a5fa);
  border-radius: 2px;
}

.factor-desc {
  font-size: 12px;
  color: #94a3b8;
}

/* 风险与机会 */
.risk-opportunity {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.risks, .opportunities {
  padding: 16px;
  background: rgba(15, 23, 42, 0.3);
  border-radius: 8px;
}

.risks ul, .opportunities ul {
  list-style: none;
  padding: 0;
}

.risks li, .opportunities li {
  padding: 8px 0;
  font-size: 13px;
  color: #cbd5e1;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
}

.risks li:last-child, .opportunities li:last-child {
  border-bottom: none;
}

/* 无选择 */
.no-selection {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 300px;
}

.placeholder {
  text-align: center;
  color: #64748b;
}

.placeholder .icon {
  font-size: 48px;
  display: block;
  margin-bottom: 16px;
}

.placeholder p {
  font-size: 16px;
}
</style>