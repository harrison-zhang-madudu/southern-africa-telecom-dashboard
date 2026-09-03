<template>
  <div class="operator-detail">
    <!-- 运营商基本信息 -->
    <div class="info-header">
      <div class="operator-info">
        <span class="flag">{{ operator.logo }}</span>
        <div class="info-text">
          <h2>{{ operator.name }}</h2>
          <p class="country">{{ operator.country }} · {{ operator.region }}</p>
          <p class="description">{{ operator.description }}</p>
        </div>
      </div>
      
      <div class="latest-report">
        <span class="label">最新财报：</span>
        <span class="period">{{ operator.latestReport.period }}</span>
        <span class="date">发布于 {{ operator.latestReport.publishDate }}</span>
        <a :href="operator.latestReport.reportUrl" target="_blank" class="report-link">
          查看原文 →
        </a>
      </div>
    </div>
    
    <!-- 子公司信息 -->
    <div class="subsidiaries-section" v-if="operator.subsidiaries && operator.subsidiaries.length > 0">
      <h3 class="section-title">
        <span class="icon">🏛</span>
        旗下子公司
      </h3>
      <div class="subsidiaries-list">
        <span 
          v-for="sub in operator.subsidiaries" 
          :key="sub"
          class="subsidiary-tag"
        >
          {{ sub }}
        </span>
      </div>
    </div>
    
    <!-- 核心指标仪表盘 -->
    <div class="metrics-dashboard">
      <h3 class="section-title">
        <span class="icon">📊</span>
        核心指标仪表盘
      </h3>
      <div class="gauges-grid">
        <div 
          v-for="metric in metrics.slice(0, 4)" 
          :key="metric.id"
          class="gauge-card"
        >
          <GaugeChart 
            :value="getLatestMetricValue(metric.id)"
            :title="metric.name"
            :unit="metric.unit"
            :min="getMetricRange(metric.id).min"
            :max="getMetricRange(metric.id).max"
            :higherIsBetter="metric.higherIsBetter"
          />
        </div>
      </div>
    </div>
    
    <!-- 指标趋势图 -->
    <div class="trends-section">
      <h3 class="section-title">
        <span class="icon">📈</span>
        指标趋势
      </h3>
      <div class="trend-charts-grid">
        <div 
          v-for="metric in metrics.slice(0, 4)" 
          :key="metric.id"
          class="trend-card"
        >
          <h4 class="trend-title">{{ metric.name }}</h4>
          <SingleTrendChart 
            :data="getMetricTrendData(metric.id)"
            :title="metric.name"
            :unit="metric.unit"
          />
        </div>
      </div>
    </div>
    
    <!-- 根因分析 -->
    <div class="root-cause-section" v-if="rootCauseAnalysis && rootCauseAnalysis.length > 0">
      <h3 class="section-title">
        <span class="icon">🔬</span>
        根因分析
      </h3>
      
      <div 
        v-for="analysis in rootCauseAnalysis" 
        :key="analysis.metric"
        class="analysis-card"
      >
        <div class="analysis-header">
          <h4 class="metric-name">{{ getMetricName(analysis.metric) }}</h4>
          <span :class="['change-value', analysis.change.startsWith('+') ? 'positive' : 'negative']">
            {{ analysis.change }}
          </span>
        </div>
        
        <div class="analysis-content">
          <!-- 主要原因 -->
          <div class="causes-section">
            <h5 class="causes-title">
              <span class="icon">🎯</span>
              主要驱动因素
            </h5>
            <div class="causes-list">
              <div 
                v-for="cause in analysis.primaryCauses" 
                :key="cause.cause"
                class="cause-item primary"
              >
                <div class="cause-header">
                  <span class="cause-name">{{ cause.cause }}</span>
                  <span :class="['impact-badge', cause.impact]">
                    {{ getImpactLabel(cause.impact) }}影响
                  </span>
                </div>
                <div class="cause-contribution">
                  贡献度：<strong>{{ cause.contribution }}</strong>
                </div>
                <div class="cause-evidence">
                  <span class="evidence-icon">💡</span>
                  {{ cause.evidence }}
                </div>
              </div>
            </div>
          </div>
          
          <!-- 次要原因 -->
          <div class="causes-section secondary" v-if="analysis.secondaryCauses && analysis.secondaryCauses.length > 0">
            <h5 class="causes-title">
              <span class="icon">📌</span>
              次要因素
            </h5>
            <div class="causes-list">
              <div 
                v-for="cause in analysis.secondaryCauses" 
                :key="cause.cause"
                class="cause-item secondary"
              >
                <div class="cause-header">
                  <span class="cause-name">{{ cause.cause }}</span>
                </div>
                <div class="cause-contribution">
                  贡献度：<strong>{{ cause.contribution }}</strong>
                </div>
                <div class="cause-evidence">
                  <span class="evidence-icon">💡</span>
                  {{ cause.evidence }}
                </div>
              </div>
            </div>
          </div>
          
          <!-- 风险与机会 -->
          <div class="risk-opportunity-section">
            <div class="risks" v-if="analysis.risks && analysis.risks.length > 0">
              <h5 class="risk-title">
                <span class="icon">⚠️</span>
                潜在风险
              </h5>
              <ul class="risk-list">
                <li v-for="risk in analysis.risks" :key="risk">{{ risk }}</li>
              </ul>
            </div>
            
            <div class="opportunities" v-if="analysis.opportunities && analysis.opportunities.length > 0">
              <h5 class="opportunity-title">
                <span class="icon">🌟</span>
                发展机会
              </h5>
              <ul class="opportunity-list">
                <li v-for="opp in analysis.opportunities" :key="opp">{{ opp }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import GaugeChart from './GaugeChart.vue'
import SingleTrendChart from './SingleTrendChart.vue'

export default {
  name: 'OperatorDetail',
  components: {
    GaugeChart,
    SingleTrendChart
  },
  props: {
    operator: Object,
    operatorData: Array,
    metrics: Array,
    rootCauseAnalysis: Array
  },
  setup(props) {
    const getMetricName = (metricId) => {
      const metric = props.metrics.find(m => m.id === metricId)
      return metric ? metric.name : metricId
    }
    
    const getLatestMetricValue = (metricId) => {
      const sortedData = [...props.operatorData].sort((a, b) => b.period.localeCompare(a.period))
      const latest = sortedData[0]
      return latest?.data[metricId] || 0
    }
    
    const getMetricRange = (metricId) => {
      const ranges = {
        revenue_growth: { min: -10, max: 30 },
        ebitda_margin: { min: 0, max: 60 },
        arpu: { min: 0, max: 15 },
        subscriber_growth: { min: -10, max: 25 },
        capex_ratio: { min: 0, max: 35 },
        debt_ratio: { min: 0, max: 80 },
        fcf: { min: -100, max: 2000 },
        churn_rate: { min: 0, max: 10 }
      }
      return ranges[metricId] || { min: 0, max: 100 }
    }
    
    const getMetricTrendData = (metricId) => {
      return [...props.operatorData]
        .sort((a, b) => a.period.localeCompare(b.period))
        .map(d => ({
          period: d.period,
          value: d.data[metricId] || 0
        }))
    }
    
    const getImpactLabel = (impact) => {
      const labels = {
        high: '高',
        medium: '中',
        low: '低'
      }
      return labels[impact] || impact
    }
    
    return {
      getMetricName,
      getLatestMetricValue,
      getMetricRange,
      getMetricTrendData,
      getImpactLabel
    }
  }
}
</script>

<style scoped>
.operator-detail {
  display: flex;
  flex-direction: column;
  gap: 25px;
}

/* 基本信息 */
.info-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
  gap: 20px;
}

.operator-info {
  display: flex;
  gap: 15px;
}

.flag {
  font-size: 48px;
}

.info-text h2 {
  font-size: 24px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 5px;
}

.info-text .country {
  font-size: 13px;
  color: #888;
  margin-bottom: 8px;
}

.info-text .description {
  font-size: 14px;
  color: #aaa;
  line-height: 1.5;
}

.latest-report {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 8px;
  text-align: right;
}

.latest-report .label {
  font-size: 12px;
  color: #888;
}

.latest-report .period {
  font-size: 18px;
  font-weight: 600;
  color: #00d9ff;
}

.latest-report .date {
  font-size: 11px;
  color: #666;
}

.report-link {
  font-size: 12px;
  color: #00d9ff;
  text-decoration: none;
}

.report-link:hover {
  text-decoration: underline;
}

/* 子公司 */
.subsidiaries-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 15px 20px;
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
  font-size: 18px;
}

.subsidiaries-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.subsidiary-tag {
  padding: 6px 12px;
  border-radius: 15px;
  background: rgba(0, 217, 255, 0.1);
  color: #00d9ff;
  font-size: 12px;
}

/* 仪表盘 */
.metrics-dashboard {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.gauges-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
}

.gauge-card {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 10px;
  padding: 15px;
}

/* 趋势图 */
.trends-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.trend-charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.trend-card {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 10px;
  padding: 15px;
}

.trend-title {
  font-size: 13px;
  color: #888;
  margin-bottom: 10px;
}

/* 根因分析 */
.root-cause-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.analysis-card {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 20px;
}

.analysis-card:last-child {
  margin-bottom: 0;
}

.analysis-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.metric-name {
  font-size: 16px;
  font-weight: 600;
  color: #fff;
}

.change-value {
  font-size: 20px;
  font-weight: bold;
}

.change-value.positive {
  color: #00c896;
}

.change-value.negative {
  color: #ff6464;
}

.analysis-content {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.causes-section {
  flex: 1;
}

.causes-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #888;
  margin-bottom: 12px;
}

.causes-title .icon {
  font-size: 16px;
}

.causes-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.cause-item {
  padding: 12px;
  border-radius: 8px;
}

.cause-item.primary {
  background: rgba(0, 217, 255, 0.08);
  border-left: 3px solid #00d9ff;
}

.cause-item.secondary {
  background: rgba(255, 255, 255, 0.03);
  border-left: 3px solid #555;
}

.cause-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.cause-name {
  font-weight: 500;
  color: #fff;
}

.impact-badge {
  padding: 3px 10px;
  border-radius: 10px;
  font-size: 11px;
  font-weight: 500;
}

.impact-badge.high {
  background: rgba(255, 100, 100, 0.2);
  color: #ff6464;
}

.impact-badge.medium {
  background: rgba(255, 200, 100, 0.2);
  color: #ffc864;
}

.cause-contribution {
  font-size: 13px;
  color: #aaa;
  margin-bottom: 6px;
}

.cause-contribution strong {
  color: #00d9ff;
}

.cause-evidence {
  font-size: 12px;
  color: #888;
  line-height: 1.5;
}

.evidence-icon {
  margin-right: 5px;
}

/* 风险与机会 */
.risk-opportunity-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 10px;
}

.risks, .opportunities {
  padding: 15px;
  border-radius: 8px;
}

.risks {
  background: rgba(255, 100, 100, 0.05);
}

.opportunities {
  background: rgba(0, 200, 150, 0.05);
}

.risk-title, .opportunity-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  margin-bottom: 10px;
}

.risk-title {
  color: #ff6464;
}

.opportunity-title {
  color: #00c896;
}

.risk-list, .opportunity-list {
  padding-left: 20px;
  font-size: 12px;
  line-height: 1.8;
}

.risk-list li {
  color: #aaa;
}

.opportunity-list li {
  color: #aaa;
}

@media (max-width: 1024px) {
  .info-header {
    flex-direction: column;
  }
  
  .latest-report {
    align-items: flex-start;
    text-align: left;
  }
  
  .trend-charts-grid {
    grid-template-columns: 1fr;
  }
  
  .risk-opportunity-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .gauges-grid {
    grid-template-columns: 1fr 1fr;
  }
}
</style>