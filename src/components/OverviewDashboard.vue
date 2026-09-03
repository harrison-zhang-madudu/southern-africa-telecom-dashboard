<template>
  <div class="overview-dashboard">
    <!-- 预警区域 -->
    <div class="alerts-section">
      <h3 class="section-title">
        <span class="icon">🔔</span>
        预警与机会
      </h3>
      <div class="alerts-grid">
        <div 
          v-for="alert in data.alerts" 
          :key="alert.operatorId + alert.title"
          :class="['alert-card', alert.type, alert.level]"
        >
          <div class="alert-header">
            <span class="alert-type">{{ getAlertTypeLabel(alert.type) }}</span>
            <span class="alert-operator">{{ getOperatorName(alert.operatorId) }}</span>
          </div>
          <h4 class="alert-title">{{ alert.title }}</h4>
          <p class="alert-desc">{{ alert.description }}</p>
        </div>
      </div>
    </div>
    
    <!-- 核心指标概览 -->
    <div class="metrics-overview">
      <h3 class="section-title">
        <span class="icon">📈</span>
        核心指标概览 (2026 Q2)
      </h3>
      <div class="metrics-grid">
        <div 
          v-for="operator in data.operators" 
          :key="operator.id"
          class="operator-metrics-card"
          @click="$emit('selectOperator', operator.id)"
        >
          <div class="card-header">
            <span class="flag">{{ operator.logo }}</span>
            <h4 class="name">{{ operator.name }}</h4>
            <span class="country">{{ operator.country }}</span>
          </div>
          
          <div class="metrics-values">
            <div 
              v-for="metricId in selectedMetrics.slice(0, 4)" 
              :key="metricId"
              class="metric-item"
            >
              <span class="metric-label">{{ getMetricName(metricId) }}</span>
              <span 
                :class="['metric-value', getValueClass(operator.id, metricId)]"
              >
                {{ formatValue(operator.id, metricId) }}
              </span>
            </div>
          </div>
          
          <div class="card-footer">
            <span class="view-detail">点击查看详情 →</span>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 趋势图表 -->
    <div class="trends-section">
      <h3 class="section-title">
        <span class="icon">📊</span>
        关键趋势
      </h3>
      <div class="charts-grid">
        <div class="chart-card">
          <h4 class="chart-title">收入增长率趋势</h4>
          <TrendChart 
            :data="getTrendData('revenue_growth')"
            :operators="data.operators"
            title="收入增长率"
            unit="%"
          />
        </div>
        <div class="chart-card">
          <h4 class="chart-title">EBITDA利润率趋势</h4>
          <TrendChart 
            :data="getTrendData('ebitda_margin')"
            :operators="data.operators"
            title="EBITDA利润率"
            unit="%"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import TrendChart from './TrendChart.vue'

export default {
  name: 'OverviewDashboard',
  components: {
    TrendChart
  },
  props: {
    data: Object,
    selectedOperator: String,
    selectedMetrics: Array
  },
  emits: ['selectOperator'],
  setup(props) {
    const getOperatorName = (operatorId) => {
      const operator = props.data.operators.find(op => op.id === operatorId)
      return operator ? operator.name : operatorId
    }
    
    const getMetricName = (metricId) => {
      const metric = props.data.metrics.find(m => m.id === metricId)
      return metric ? metric.name : metricId
    }
    
    const getMetric = (metricId) => {
      return props.data.metrics.find(m => m.id === metricId)
    }
    
    const getLatestData = (operatorId) => {
      const operatorData = props.data.quarterlyData
        .filter(d => d.operatorId === operatorId)
        .sort((a, b) => a.period.localeCompare(b.period))
      return operatorData[operatorData.length - 1]
    }
    
    const formatValue = (operatorId, metricId) => {
      const latest = getLatestData(operatorId)
      if (!latest || !latest.data[metricId]) return '-'
      
      const value = latest.data[metricId]
      const metric = getMetric(metricId)
      
      if (metricId === 'fcf') {
        return `$${value}M`
      }
      return `${value.toFixed(1)}${metric?.unit || ''}`
    }
    
    const getValueClass = (operatorId, metricId) => {
      const latest = getLatestData(operatorId)
      if (!latest || !latest.data[metricId]) return ''
      
      const value = latest.data[metricId]
      const metric = getMetric(metricId)
      
      if (metric?.higherIsBetter) {
        if (value > 10) return 'positive'
        if (value < 0) return 'negative'
      } else {
        if (value < 20) return 'positive'
        if (value > 50) return 'negative'
      }
      return 'neutral'
    }
    
    const getAlertTypeLabel = (type) => {
      const labels = {
        opportunity: '机会',
        risk: '风险',
        info: '信息'
      }
      return labels[type] || type
    }
    
    const getTrendData = (metricId) => {
      const periods = ['2025 Q3', '2025 Q4', '2026 Q1', '2026 Q2']
      return periods.map(period => {
        const periodData = { period }
        props.data.operators.forEach(operator => {
          const data = props.data.quarterlyData.find(
            d => d.operatorId === operator.id && d.period === period
          )
          periodData[operator.id] = data ? data.data[metricId] : null
        })
        return periodData
      })
    }
    
    return {
      getOperatorName,
      getMetricName,
      formatValue,
      getValueClass,
      getAlertTypeLabel,
      getTrendData
    }
  }
}
</script>

<style scoped>
.overview-dashboard {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

.section-title {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 16px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 15px;
}

.section-title .icon {
  font-size: 20px;
}

/* 预警区域 */
.alerts-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.alerts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 15px;
}

.alert-card {
  padding: 15px;
  border-radius: 10px;
  border-left: 4px solid;
}

.alert-card.opportunity {
  background: rgba(0, 200, 150, 0.1);
  border-left-color: #00c896;
}

.alert-card.risk {
  background: rgba(255, 100, 100, 0.1);
  border-left-color: #ff6464;
}

.alert-card.info {
  background: rgba(100, 150, 255, 0.1);
  border-left-color: #6496ff;
}

.alert-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 11px;
}

.alert-type {
  padding: 2px 8px;
  border-radius: 10px;
  background: rgba(255, 255, 255, 0.1);
  text-transform: uppercase;
}

.alert-operator {
  color: #888;
}

.alert-title {
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 5px;
}

.alert-desc {
  font-size: 12px;
  color: #aaa;
  line-height: 1.5;
}

/* 核心指标概览 */
.metrics-overview {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 15px;
}

.operator-metrics-card {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 10px;
  padding: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.operator-metrics-card:hover {
  background: rgba(255, 255, 255, 0.1);
  transform: translateY(-3px);
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.3);
}

.card-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.flag {
  font-size: 24px;
}

.name {
  flex: 1;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
}

.country {
  font-size: 11px;
  color: #888;
  padding: 3px 8px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.metrics-values {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-bottom: 15px;
}

.metric-item {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.metric-label {
  font-size: 11px;
  color: #888;
}

.metric-value {
  font-size: 16px;
  font-weight: 600;
}

.metric-value.positive {
  color: #00c896;
}

.metric-value.negative {
  color: #ff6464;
}

.metric-value.neutral {
  color: #e0e0e0;
}

.card-footer {
  text-align: center;
}

.view-detail {
  font-size: 11px;
  color: #00d9ff;
}

/* 趋势图表 */
.trends-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(500px, 1fr));
  gap: 20px;
}

.chart-card {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 10px;
  padding: 15px;
}

.chart-title {
  font-size: 13px;
  color: #888;
  margin-bottom: 10px;
}

@media (max-width: 768px) {
  .alerts-grid,
  .metrics-grid {
    grid-template-columns: 1fr;
  }
  
  .charts-grid {
    grid-template-columns: 1fr;
  }
}
</style>