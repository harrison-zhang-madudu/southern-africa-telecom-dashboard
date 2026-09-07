<template>
  <div class="operator-detail">
    <div v-for="operator in operators" :key="operator.id" class="detail-card">
      <div class="detail-header">
        <h3>{{ operator.flag }} {{ operator.name }} - 财务指标详情</h3>
        <p class="country-info">{{ operator.country }} | {{ operator.currency }}</p>
      </div>
      
      <!-- 核心指标仪表盘 -->
      <div class="metrics-dashboard">
        <div class="metric-gauge" v-for="metric in displayMetrics" :key="metric.id">
          <GaugeChart 
            :value="getLatestMetric(operator.id, metric.id)"
            :max="getMetricMax(metric.id)"
            :title="metric.name"
            :unit="metric.unit"
            :color="getMetricColor(metric.id)"
          />
        </div>
      </div>
      
      <!-- 趋势图 -->
      <div class="trend-section">
        <h4>📈 指标趋势</h4>
        <div class="trend-chart-container">
          <SingleTrendChart 
            v-for="metric in selectedMetrics.slice(0, 3)"
            :key="metric"
            :data="getOperatorTrendData(operator.id, metric)"
            :metricName="getMetricName(metric)"
            :unit="getMetricUnit(metric)"
          />
        </div>
      </div>
      
      <!-- 根因分析 -->
      <div class="root-cause-section" v-if="getRootCause(operator.id)">
        <h4>🔍 根因分析</h4>
        <div class="root-cause-content">
          <div class="analysis-metrics">
            <div 
              v-for="(analysis, idx) in getRootCause(operator.id).metrics" 
              :key="idx"
              class="analysis-item"
            >
              <div class="analysis-header">
                <span class="metric-name">{{ getMetricLabel(analysis.metric) }}</span>
                <span :class="['change', analysis.change.startsWith('+') ? 'positive' : 'negative']">
                  {{ analysis.change }}
                </span>
              </div>
              
              <div class="drivers">
                <div class="drivers-title">影响因素：</div>
                <div 
                  v-for="(driver, dIdx) in analysis.drivers" 
                  :key="dIdx"
                  class="driver-item"
                >
                  <div class="driver-header">
                    <span class="driver-name">{{ driver.factor }}</span>
                    <div class="driver-contribution">
                      <div class="contribution-bar">
                        <div 
                          class="contribution-fill"
                          :style="{ 
                            width: driver.contribution + '%',
                            background: getTrendColor(driver.trend)
                          }"
                        ></div>
                      </div>
                      <span class="contribution-value">{{ driver.contribution }}%</span>
                    </div>
                  </div>
                  <p class="driver-desc">{{ driver.description }}</p>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 风险与机会 -->
          <div class="risks-opportunities">
            <div class="risks" v-if="getRootCause(operator.id).risks?.length">
              <h5>⚠️ 风险提示</h5>
              <div 
                v-for="(risk, rIdx) in getRootCause(operator.id).risks" 
                :key="rIdx"
                :class="['risk-item', `severity-${risk.severity}`]"
              >
                <div class="risk-header">
                  <span class="risk-name">{{ risk.risk }}</span>
                  <span :class="['severity-badge', risk.severity]">{{ getSeverityLabel(risk.severity) }}</span>
                </div>
                <p class="risk-desc">{{ risk.description }}</p>
              </div>
            </div>
            
            <div class="opportunities" v-if="getRootCause(operator.id).opportunities?.length">
              <h5>💡 改善机会</h5>
              <div 
                v-for="(opp, oIdx) in getRootCause(operator.id).opportunities" 
                :key="oIdx"
                :class="['opportunity-item', `potential-${opp.potential}`]"
              >
                <div class="opp-header">
                  <span class="opp-name">{{ opp.opportunity }}</span>
                  <span :class="['potential-badge', opp.potential]">{{ getPotentialLabel(opp.potential) }}</span>
                </div>
                <p class="opp-desc">{{ opp.description }}</p>
                <span class="opp-timeline">时间线：{{ opp.timeline }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="no-data" v-else>
        <p>暂无该运营商的根因分析数据</p>
      </div>
    </div>
  </div>
</template>

<script>
import GaugeChart from './GaugeChart.vue'
import SingleTrendChart from './SingleTrendChart.vue'
import enhancedData from '../data/enhanced-data.json'

export default {
  name: 'OperatorDetail',
  components: { GaugeChart, SingleTrendChart },
  props: {
    operators: { type: Array, required: true },
    selectedMetrics: { type: Array, required: true },
    quarterlyData: { type: Array, required: true }
  },
  data() {
    return {
      rootCauseData: enhancedData.rootCauseAnalysis || {}
    }
  },
  computed: {
    displayMetrics() {
      return [
        { id: 'revenue', name: '营业收入', unit: '亿美元' },
        { id: 'ebitdaMargin', name: 'EBITDA利润率', unit: '%' },
        { id: 'subscriberGrowth', name: '订户增长', unit: '%' },
        { id: 'arpu', name: 'ARPU', unit: '美元' }
      ]
    }
  },
  methods: {
    getLatestMetric(operatorId, metricId) {
      const data = this.quarterlyData
        .filter(d => d.operatorId === operatorId)
        .sort((a, b) => b.period.localeCompare(a.period))
      return data[0]?.[metricId] || 0
    },
    getMetricMax(metricId) {
      const maxs = { revenue: 25, ebitdaMargin: 50, subscriberGrowth: 15, arpu: 6 }
      return maxs[metricId] || 100
    },
    getMetricColor(metricId) {
      const colors = { 
        revenue: '#3b82f6', 
        ebitdaMargin: '#10b981', 
        subscriberGrowth: '#8b5cf6', 
        arpu: '#f59e0b' 
      }
      return colors[metricId] || '#3b82f6'
    },
    getOperatorTrendData(operatorId, metricId) {
      return this.quarterlyData
        .filter(d => d.operatorId === operatorId)
        .sort((a, b) => a.period.localeCompare(b.period))
        .map(d => ({
          period: d.periodLabel,
          value: d[metricId] || 0
        }))
    },
    getMetricName(metricId) {
      const names = {
        revenue: '营业收入',
        ebitdaMargin: 'EBITDA利润率',
        subscriberGrowth: '订户增长',
        arpu: 'ARPU',
        capexRatio: '资本开支比',
        debtRatio: '负债率',
        fcf: '自由现金流',
        churnRate: '流失率'
      }
      return names[metricId] || metricId
    },
    getMetricUnit(metricId) {
      const units = {
        revenue: '亿美元',
        ebitdaMargin: '%',
        subscriberGrowth: '%',
        arpu: '美元',
        capexRatio: '%',
        debtRatio: '倍',
        fcf: '亿美元',
        churnRate: '%'
      }
      return units[metricId] || ''
    },
    getMetricLabel(metric) {
      const labels = {
        revenue: '营业收入变化',
        ebitdaMargin: 'EBITDA利润率变化',
        subscriberGrowth: '订户增长率变化',
        arpu: 'ARPU变化'
      }
      return labels[metric] || metric
    },
    getRootCause(operatorId) {
      return this.rootCauseData[operatorId]
    },
    getTrendColor(trend) {
      const colors = {
        positive: '#10b981',
        negative: '#ef4444',
        neutral: '#64748b'
      }
      return colors[trend] || '#64748b'
    },
    getSeverityLabel(severity) {
      const labels = { critical: '严重', high: '高', medium: '中', low: '低' }
      return labels[severity] || severity
    },
    getPotentialLabel(potential) {
      const labels = { high: '高潜力', medium: '中潜力', low: '低潜力' }
      return labels[potential] || potential
    }
  }
}
</script>

<style scoped>
.operator-detail {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.detail-card {
  background: rgba(30, 41, 59, 0.8);
  border-radius: 16px;
  padding: 24px;
}

.detail-header {
  margin-bottom: 20px;
}

.detail-header h3 {
  font-size: 20px;
  color: #e2e8f0;
  margin: 0 0 4px 0;
}

.country-info {
  font-size: 14px;
  color: #64748b;
}

.metrics-dashboard {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 24px;
}

@media (max-width: 768px) {
  .metrics-dashboard {
    grid-template-columns: repeat(2, 1fr);
  }
}

.metric-gauge {
  background: rgba(15, 23, 42, 0.5);
  border-radius: 12px;
  padding: 16px;
}

.trend-section {
  margin-bottom: 24px;
}

.trend-section h4 {
  font-size: 16px;
  color: #e2e8f0;
  margin-bottom: 16px;
}

.trend-chart-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

@media (max-width: 1024px) {
  .trend-chart-container {
    grid-template-columns: 1fr;
  }
}

.root-cause-section {
  border-top: 1px solid rgba(148, 163, 184, 0.1);
  padding-top: 24px;
}

.root-cause-section h4 {
  font-size: 16px;
  color: #e2e8f0;
  margin-bottom: 16px;
}

.root-cause-content {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.analysis-metrics {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.analysis-item {
  background: rgba(15, 23, 42, 0.5);
  border-radius: 12px;
  padding: 16px;
}

.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.metric-name {
  font-size: 14px;
  font-weight: 600;
  color: #e2e8f0;
}

.change {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 6px;
}

.change.positive {
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
}

.change.negative {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.1);
}

.drivers-title {
  font-size: 12px;
  color: #64748b;
  margin-bottom: 8px;
}

.driver-item {
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
}

.driver-item:last-child {
  margin-bottom: 0;
  padding-bottom: 0;
  border-bottom: none;
}

.driver-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.driver-name {
  font-size: 13px;
  color: #e2e8f0;
  font-weight: 500;
}

.driver-contribution {
  display: flex;
  align-items: center;
  gap: 8px;
}

.contribution-bar {
  width: 80px;
  height: 6px;
  background: rgba(100, 116, 139, 0.2);
  border-radius: 3px;
  overflow: hidden;
}

.contribution-fill {
  height: 100%;
  border-radius: 3px;
}

.contribution-value {
  font-size: 12px;
  color: #94a3b8;
  min-width: 35px;
}

.driver-desc {
  font-size: 12px;
  color: #64748b;
  line-height: 1.4;
}

.risks-opportunities {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 768px) {
  .risks-opportunities {
    grid-template-columns: 1fr;
  }
}

.risks h5, .opportunities h5 {
  font-size: 14px;
  color: #e2e8f0;
  margin: 0 0 12px 0;
}

.risk-item, .opportunity-item {
  background: rgba(15, 23, 42, 0.5);
  border-radius: 8px;
  padding: 12px;
  margin-bottom: 8px;
}

.risk-header, .opp-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.risk-name, .opp-name {
  font-size: 13px;
  color: #e2e8f0;
  font-weight: 500;
}

.severity-badge, .potential-badge {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
}

.severity-critical { background: rgba(239, 68, 68, 0.2); color: #ef4444; }
.severity-high { background: rgba(249, 115, 22, 0.2); color: #f97316; }
.severity-medium { background: rgba(234, 179, 8, 0.2); color: #eab308; }
.severity-low { background: rgba(100, 116, 139, 0.2); color: #94a3b8; }

.potential-high { background: rgba(16, 185, 129, 0.2); color: #10b981; }
.potential-medium { background: rgba(59, 130, 246, 0.2); color: #3b82f6; }
.potential-low { background: rgba(100, 116, 139, 0.2); color: #94a3b8; }

.risk-desc, .opp-desc {
  font-size: 12px;
  color: #94a3b8;
  line-height: 1.4;
  margin: 0;
}

.opp-timeline {
  display: block;
  font-size: 11px;
  color: #64748b;
  margin-top: 4px;
}

.no-data {
  text-align: center;
  padding: 40px;
  color: #64748b;
}
</style>