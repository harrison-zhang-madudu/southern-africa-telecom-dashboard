<template>
  <div class="comparison-view">
    <h3 class="section-title">
      <span class="icon">🔍</span>
      运营商对比分析 (2026 Q2)
    </h3>
    
    <!-- 雷达图对比 -->
    <div class="radar-section">
      <h4 class="subsection-title">综合能力雷达图</h4>
      <div class="radar-container" ref="radarRef"></div>
    </div>
    
    <!-- 指标对比表 -->
    <div class="comparison-table-section">
      <h4 class="subsection-title">关键指标对比</h4>
      <div class="table-container">
        <table class="comparison-table">
          <thead>
            <tr>
              <th>运营商</th>
              <th v-for="metric in selectedMetrics" :key="metric">
                {{ getMetricName(metric) }}
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="operator in operators" :key="operator.id">
              <td class="operator-cell">
                <span class="flag">{{ operator.logo }}</span>
                <span class="name">{{ operator.name }}</span>
              </td>
              <td 
                v-for="metric in selectedMetrics" 
                :key="metric"
                :class="['value-cell', getValueClass(operator.id, metric)]"
              >
                {{ formatValue(operator.id, metric) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    
    <!-- 排名分析 -->
    <div class="ranking-section">
      <h4 class="subsection-title">指标排名</h4>
      <div class="ranking-grid">
        <div 
          v-for="metric in selectedMetrics" 
          :key="metric"
          class="ranking-card"
        >
          <h5 class="ranking-title">{{ getMetricName(metric) }}</h5>
          <div class="ranking-list">
            <div 
              v-for="(item, index) in getRanking(metric)" 
              :key="item.operatorId"
              :class="['ranking-item', `rank-${index + 1}`]"
            >
              <span class="rank">{{ index + 1 }}</span>
              <span class="operator">{{ item.operatorName }}</span>
              <span class="value">{{ item.value }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, watch, computed } from 'vue'
import * as echarts from 'echarts'

export default {
  name: 'ComparisonView',
  props: {
    data: Object,
    selectedMetrics: Array
  },
  setup(props) {
    const radarRef = ref(null)
    let radarChart = null
    
    const operators = computed(() => props.data.operators)
    
    const getMetricName = (metricId) => {
      const metric = props.data.metrics.find(m => m.id === metricId)
      return metric ? metric.name : metricId
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
      const metric = props.data.metrics.find(m => m.id === metricId)
      
      if (metricId === 'fcf') {
        return `$${value}M`
      }
      return `${value.toFixed(1)}${metric?.unit || ''}`
    }
    
    const getValueClass = (operatorId, metricId) => {
      const latest = getLatestData(operatorId)
      if (!latest || !latest.data[metricId]) return ''
      
      const value = latest.data[metricId]
      const metric = props.data.metrics.find(m => m.id === metricId)
      
      if (metric?.higherIsBetter) {
        if (value > 10) return 'positive'
        if (value < 0) return 'negative'
      } else {
        if (value < 20) return 'positive'
        if (value > 50) return 'negative'
      }
      return 'neutral'
    }
    
    const getRanking = (metricId) => {
      const ranking = props.data.operators.map(operator => {
        const latest = getLatestData(operator.id)
        const value = latest?.data[metricId] || 0
        const metric = props.data.metrics.find(m => m.id === metricId)
        
        return {
          operatorId: operator.id,
          operatorName: operator.name,
          value: metricId === 'fcf' ? `$${value}M` : `${value.toFixed(1)}${metric?.unit || ''}`,
          rawValue: value,
          higherIsBetter: metric?.higherIsBetter ?? true
        }
      })
      
      return ranking.sort((a, b) => {
        return a.higherIsBetter ? b.rawValue - a.rawValue : a.rawValue - b.rawValue
      })
    }
    
    const initRadarChart = () => {
      if (!radarRef.value) return
      
      radarChart = echarts.init(radarRef.value)
      
      const indicators = props.selectedMetrics.map(metricId => {
        const metric = props.data.metrics.find(m => m.id === metricId)
        return {
          name: metric?.name || metricId,
          max: 50
        }
      })
      
      const series = props.data.operators.map(operator => {
        const latest = getLatestData(operator.id)
        return {
          name: operator.name,
          value: props.selectedMetrics.map(metricId => {
            const value = latest?.data[metricId] || 0
            // 归一化到0-50范围
            return Math.min(Math.max(value, 0), 50)
          })
        }
      })
      
      const option = {
        tooltip: {
          trigger: 'item',
          backgroundColor: 'rgba(26, 26, 46, 0.9)',
          borderColor: 'rgba(255, 255, 255, 0.2)',
          textStyle: {
            color: '#e0e0e0'
          }
        },
        legend: {
          data: props.data.operators.map(op => op.name),
          bottom: 0,
          textStyle: {
            color: '#888',
            fontSize: 11
          },
          itemWidth: 15,
          itemHeight: 8
        },
        radar: {
          indicator: indicators,
          shape: 'polygon',
          splitNumber: 5,
          axisName: {
            color: '#888',
            fontSize: 11
          },
          splitLine: {
            lineStyle: {
              color: 'rgba(255, 255, 255, 0.1)'
            }
          },
          splitArea: {
            show: true,
            areaStyle: {
              color: ['rgba(0, 217, 255, 0.02)', 'rgba(0, 217, 255, 0.05)']
            }
          },
          axisLine: {
            lineStyle: {
              color: 'rgba(255, 255, 255, 0.2)'
            }
          }
        },
        series: [{
          type: 'radar',
          data: series.map((s, i) => ({
            ...s,
            areaStyle: {
              opacity: 0.2
            }
          }))
        }],
        color: ['#00d9ff', '#00c896', '#ff9f43', '#ff6464', '#a855f7', '#3b82f6']
      }
      
      radarChart.setOption(option)
    }
    
    onMounted(() => {
      initRadarChart()
      
      window.addEventListener('resize', () => {
        radarChart?.resize()
      })
    })
    
    watch(() => props.selectedMetrics, () => {
      initRadarChart()
    }, { deep: true })
    
    return {
      radarRef,
      operators,
      getMetricName,
      formatValue,
      getValueClass,
      getRanking
    }
  }
}
</script>

<style scoped>
.comparison-view {
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
}

.section-title .icon {
  font-size: 20px;
}

.subsection-title {
  font-size: 13px;
  color: #888;
  margin-bottom: 15px;
}

.radar-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.radar-container {
  width: 100%;
  height: 400px;
}

.comparison-table-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.table-container {
  overflow-x: auto;
}

.comparison-table {
  width: 100%;
  border-collapse: collapse;
}

.comparison-table th,
.comparison-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.comparison-table th {
  font-size: 12px;
  color: #888;
  font-weight: 500;
  text-transform: uppercase;
}

.operator-cell {
  display: flex;
  align-items: center;
  gap: 10px;
}

.operator-cell .flag {
  font-size: 20px;
}

.operator-cell .name {
  font-weight: 500;
  color: #fff;
}

.value-cell {
  font-weight: 600;
  font-size: 14px;
}

.value-cell.positive {
  color: #00c896;
}

.value-cell.negative {
  color: #ff6464;
}

.value-cell.neutral {
  color: #e0e0e0;
}

.ranking-section {
  background: rgba(255, 255, 255, 0.03);
  border-radius: 12px;
  padding: 20px;
}

.ranking-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: 15px;
}

.ranking-card {
  background: rgba(0, 0, 0, 0.2);
  border-radius: 10px;
  padding: 15px;
}

.ranking-title {
  font-size: 12px;
  color: #888;
  margin-bottom: 10px;
}

.ranking-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.05);
}

.rank {
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  font-size: 12px;
  font-weight: bold;
}

.ranking-item.rank-1 .rank {
  background: linear-gradient(135deg, #ffd700 0%, #ff9500 100%);
  color: #1a1a2e;
}

.ranking-item.rank-2 .rank {
  background: linear-gradient(135deg, #c0c0c0 0%, #a0a0a0 100%);
  color: #1a1a2e;
}

.ranking-item.rank-3 .rank {
  background: linear-gradient(135deg, #cd7f32 0%, #b87333 100%);
  color: #1a1a2e;
}

.ranking-item .operator {
  flex: 1;
  font-size: 12px;
  color: #e0e0e0;
}

.ranking-item .value {
  font-size: 13px;
  font-weight: 600;
  color: #00d9ff;
}

@media (max-width: 768px) {
  .ranking-grid {
    grid-template-columns: 1fr;
  }
}
</style>