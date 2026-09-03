<template>
  <div class="overview-dashboard">
    <!-- 顶部预警区域 -->
    <section class="alerts-section">
      <h2>
        <span class="icon">🚨</span>
        风险与机会预警
      </h2>
      <div class="alerts-grid">
        <div 
          v-for="alert in alerts" 
          :key="alert.id"
          class="alert-card"
          :class="alert.type"
        >
          <div class="alert-icon">{{ alert.type === 'risk' ? '⚠️' : '✨' }}</div>
          <div class="alert-content">
            <div class="alert-title">{{ alert.title }}</div>
            <div class="alert-desc">{{ alert.description }}</div>
          </div>
          <div class="alert-operator">{{ alert.operator }}</div>
        </div>
      </div>
    </section>
    
    <!-- 指标卡片 -->
    <section class="metrics-section">
      <h2>
        <span class="icon">📈</span>
        核心指标概览
      </h2>
      <div class="metrics-grid">
        <div 
          v-for="metric in selectedMetricsData" 
          :key="metric.id"
          class="metric-card"
        >
          <div class="metric-header">
            <span class="metric-icon">{{ metric.icon }}</span>
            <span class="metric-name">{{ metric.name }}</span>
          </div>
          <div class="metric-value">
            {{ formatValue(metric.avgValue, metric.unit) }}
          </div>
          <div class="metric-change" :class="metric.trend">
            <span class="arrow">{{ metric.trend === 'up' ? '↑' : metric.trend === 'down' ? '↓' : '→' }}</span>
            <span>{{ Math.abs(metric.changePercent).toFixed(1) }}%</span>
            <span class="period">vs 上期</span>
          </div>
          <div class="metric-chart">
            <MiniChart :data="metric.trendData" :color="getMetricColor(metric.trend)" />
          </div>
        </div>
      </div>
    </section>
    
    <!-- 运营商趋势对比 -->
    <section class="trends-section">
      <h2>
        <span class="icon">📊</span>
        运营商趋势对比
      </h2>
      
      <div class="chart-controls">
        <label>
          <span>选择指标:</span>
          <select v-model="selectedTrendMetric">
            <option v-for="m in selectedMetrics" :key="m" :value="m">
              {{ getMetricName(m) }}
            </option>
          </select>
        </label>
      </div>
      
      <div class="trend-chart-container">
        <TrendChart 
          :data="trendChartData"
          :metricName="getMetricName(selectedTrendMetric)"
          :operators="operators"
        />
      </div>
    </section>
    
    <!-- 数据表格 -->
    <section class="table-section">
      <h2>
        <span class="icon">📋</span>
        详细数据表
      </h2>
      <div class="table-container">
        <table class="data-table">
          <thead>
            <tr>
              <th>运营商</th>
              <th v-for="m in selectedMetrics" :key="m">{{ getMetricName(m) }}</th>
              <th>最新季度</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="op in operators" :key="op.id">
              <td class="operator-cell">
                <span class="flag">{{ getFlag(op.country) }}</span>
                <span class="name">{{ op.name }}</span>
              </td>
              <td v-for="m in selectedMetrics" :key="m" class="value-cell">
                {{ formatValue(getOperatorMetric(op.id, m), getMetricUnit(m)) }}
              </td>
              <td class="quarter-cell">{{ getLatestQuarter(op.id) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import TrendChart from './TrendChart.vue'
import MiniChart from './MiniChart.vue'

const props = defineProps({
  operators: Array,
  selectedMetrics: Array,
  quarterlyData: Array
})

const selectedTrendMetric = ref(props.selectedMetrics[0] || 'revenue')

// 预警数据
const alerts = computed(() => {
  const alertList = []
  
  props.operators.forEach(op => {
    const latestData = props.quarterlyData
      .filter(d => d.operatorId === op.id)
      .sort((a, b) => b.quarter.localeCompare(a.quarter))[0]
    
    if (latestData) {
      // 检测风险
      if (latestData.subscriberGrowth < 0) {
        alertList.push({
          id: `${op.id}-sub-decline`,
          type: 'risk',
          title: '订户流失',
          description: `订户增长率 ${latestData.subscriberGrowth.toFixed(1)}%`,
          operator: op.name
        })
      }
      if (latestData.debtRatio > 70) {
        alertList.push({
          id: `${op.id}-high-debt`,
          type: 'risk',
          title: '高负债风险',
          description: `负债率 ${latestData.debtRatio.toFixed(1)}%`,
          operator: op.name
        })
      }
      if (latestData.churnRate > 5) {
        alertList.push({
          id: `${op.id}-high-churn`,
          type: 'risk',
          title: '高流失率',
          description: `流失率 ${latestData.churnRate.toFixed(1)}%`,
          operator: op.name
        })
      }
      // 检测机会
      if (latestData.ebitdaMargin > 40) {
        alertList.push({
          id: `${op.id}-high-margin`,
          type: 'opportunity',
          title: '高盈利能力',
          description: `EBITDA利润率 ${latestData.ebitdaMargin.toFixed(1)}%`,
          operator: op.name
        })
      }
      if (latestData.subscriberGrowth > 10) {
        alertList.push({
          id: `${op.id}-high-growth`,
          type: 'opportunity',
          title: '高增长',
          description: `订户增长 ${latestData.subscriberGrowth.toFixed(1)}%`,
          operator: op.name
        })
      }
    }
  })
  
  return alertList.slice(0, 6)
})

// 指标数据
const selectedMetricsData = computed(() => {
  const metricConfigs = {
    revenue: { name: '营业收入', icon: '💰', unit: '亿美元' },
    ebitdaMargin: { name: 'EBITDA利润率', icon: '📈', unit: '%' },
    subscriberGrowth: { name: '订户增长率', icon: '👥', unit: '%' },
    arpu: { name: 'ARPU', icon: '💵', unit: '美元' },
    capexRatio: { name: '资本开支比', icon: '🏗️', unit: '%' },
    debtRatio: { name: '负债率', icon: '📊', unit: '%' },
    fcf: { name: '自由现金流', icon: '💸', unit: '亿美元' },
    churnRate: { name: '流失率', icon: '📉', unit: '%' }
  }
  
  return props.selectedMetrics.map(metricId => {
    const config = metricConfigs[metricId] || { name: metricId, icon: '📊', unit: '' }
    
    // 计算平均值和趋势
    const values = props.quarterlyData.map(d => d[metricId]).filter(v => v != null)
    const avgValue = values.length > 0 ? values.reduce((a, b) => a + b, 0) / values.length : 0
    
    // 计算变化
    const sortedData = [...props.quarterlyData].sort((a, b) => b.quarter.localeCompare(a.quarter))
    const latest = sortedData[0]?.[metricId] || 0
    const previous = sortedData[1]?.[metricId] || latest
    const changePercent = previous !== 0 ? ((latest - previous) / Math.abs(previous)) * 100 : 0
    
    const trend = changePercent > 2 ? 'up' : changePercent < -2 ? 'down' : 'stable'
    
    // 趋势数据
    const trendData = sortedData.slice(0, 8).reverse().map(d => d[metricId] || 0)
    
    return {
      id: metricId,
      ...config,
      avgValue,
      changePercent,
      trend,
      trendData
    }
  })
})

// 趋势图数据
const trendChartData = computed(() => {
  return props.quarterlyData
    .filter(d => props.operators.some(op => op.id === d.operatorId))
    .sort((a, b) => a.quarter.localeCompare(b.quarter))
})

// 辅助方法
const getMetricName = (metricId) => {
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
  return names[metricId] || metricId
}

const getMetricUnit = (metricId) => {
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
  return units[metricId] || ''
}

const getMetricColor = (trend) => {
  return trend === 'up' ? '#4ade80' : trend === 'down' ? '#f87171' : '#60a5fa'
}

const getFlag = (country) => {
  const flags = {
    'South Africa': '🇿🇦',
    'Nigeria': '🇳🇬',
    'Zimbabwe': '🇿🇼',
    'Kenya': '🇰🇪',
    'Ghana': '🇬🇭',
    'Tanzania': '🇹🇿'
  }
  return flags[country] || '🌍'
}

const formatValue = (value, unit) => {
  if (value == null) return '-'
  if (unit === '%') return value.toFixed(1) + '%'
  if (unit === '亿美元') return '$' + value.toFixed(2) + 'B'
  if (unit === '美元') return '$' + value.toFixed(2)
  return value.toFixed(2)
}

const getOperatorMetric = (operatorId, metricId) => {
  const data = props.quarterlyData
    .filter(d => d.operatorId === operatorId)
    .sort((a, b) => b.quarter.localeCompare(a.quarter))[0]
  return data?.[metricId] || 0
}

const getLatestQuarter = (operatorId) => {
  const data = props.quarterlyData
    .filter(d => d.operatorId === operatorId)
    .sort((a, b) => b.quarter.localeCompare(a.quarter))[0]
  return data?.quarter || '-'
}
</script>

<style scoped>
.overview-dashboard {
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

h2 {
  font-size: 16px;
  font-weight: 600;
  color: #f1f5f9;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon {
  font-size: 18px;
}

/* 预警区域 */
.alerts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 12px;
}

.alert-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid;
}

.alert-card.risk {
  background: rgba(239, 68, 68, 0.1);
  border-color: rgba(239, 68, 68, 0.3);
}

.alert-card.opportunity {
  background: rgba(34, 197, 94, 0.1);
  border-color: rgba(34, 197, 94, 0.3);
}

.alert-icon {
  font-size: 20px;
}

.alert-content {
  flex: 1;
}

.alert-title {
  font-size: 13px;
  font-weight: 600;
  color: #f1f5f9;
}

.alert-desc {
  font-size: 12px;
  color: #94a3b8;
  margin-top: 2px;
}

.alert-operator {
  font-size: 11px;
  color: #64748b;
  padding: 4px 8px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 4px;
}

/* 指标卡片 */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
}

.metric-card {
  background: rgba(15, 23, 42, 0.5);
  border-radius: 10px;
  border: 1px solid rgba(148, 163, 184, 0.1);
  padding: 16px;
  transition: all 0.2s ease;
}

.metric-card:hover {
  border-color: rgba(59, 130, 246, 0.3);
  transform: translateY(-2px);
}

.metric-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.metric-icon {
  font-size: 20px;
}

.metric-name {
  font-size: 13px;
  color: #94a3b8;
}

.metric-value {
  font-size: 28px;
  font-weight: 700;
  color: #f1f5f9;
  margin-bottom: 8px;
}

.metric-change {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  margin-bottom: 12px;
}

.metric-change.up {
  color: #4ade80;
}

.metric-change.down {
  color: #f87171;
}

.metric-change.stable {
  color: #60a5fa;
}

.period {
  color: #64748b;
}

.metric-chart {
  height: 40px;
}

/* 趋势图 */
.chart-controls {
  margin-bottom: 16px;
}

.chart-controls label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #94a3b8;
}

.chart-controls select {
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  background: rgba(30, 41, 59, 0.5);
  color: #f1f5f9;
  font-size: 13px;
  cursor: pointer;
}

.trend-chart-container {
  height: 300px;
}

/* 数据表格 */
.table-container {
  overflow-x: auto;
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table th,
.data-table td {
  padding: 12px 16px;
  text-align: left;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
}

.data-table th {
  font-size: 12px;
  font-weight: 600;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  background: rgba(15, 23, 42, 0.5);
}

.data-table td {
  font-size: 14px;
  color: #e2e8f0;
}

.operator-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.flag {
  font-size: 16px;
}

.value-cell {
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px;
}

.quarter-cell {
  color: #94a3b8;
  font-size: 12px;
}

.data-table tbody tr:hover {
  background: rgba(59, 130, 246, 0.05);
}
</style>