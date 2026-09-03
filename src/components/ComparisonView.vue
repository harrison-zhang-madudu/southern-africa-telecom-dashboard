<template>
  <div class="comparison-view">
    <!-- 雷达图对比 -->
    <section class="radar-section">
      <h2>
        <span class="icon">🎯</span>
        运营商综合能力雷达图
      </h2>
      
      <div class="radar-container">
        <div class="radar-chart" ref="radarRef"></div>
        
        <div class="radar-legend">
          <div 
            v-for="(op, index) in operators" 
            :key="op.id"
            class="legend-item"
          >
            <span class="legend-color" :style="{ background: colors[index] }"></span>
            <span class="legend-name">{{ op.name }}</span>
          </div>
        </div>
      </div>
    </section>
    
    <!-- 排名对比 -->
    <section class="ranking-section">
      <h2>
        <span class="icon">🏆</span>
        指标排名
      </h2>
      
      <div class="ranking-tabs">
        <button 
          v-for="m in selectedMetrics" 
          :key="m"
          :class="{ active: activeMetric === m }"
          @click="activeMetric = m"
        >
          {{ getMetricName(m) }}
        </button>
      </div>
      
      <div class="ranking-list">
        <div 
          v-for="(item, index) in rankingData" 
          :key="item.operatorId"
          class="ranking-item"
          :class="{ top: index === 0 }"
        >
          <div class="rank">
            <span class="rank-num">{{ index + 1 }}</span>
            <span class="rank-medal" v-if="index === 0">🥇</span>
            <span class="rank-medal" v-else-if="index === 1">🥈</span>
            <span class="rank-medal" v-else-if="index === 2">🥉</span>
          </div>
          <div class="operator-info">
            <span class="flag">{{ getFlag(item.country) }}</span>
            <span class="name">{{ item.name }}</span>
          </div>
          <div class="value-bar">
            <div 
              class="bar-fill"
              :style="{ width: item.percent + '%' }"
              :class="getBarClass(index)"
            ></div>
          </div>
          <div class="value">{{ formatValue(item.value) }}</div>
        </div>
      </div>
    </section>
    
    <!-- 差异分析 -->
    <section class="gap-section">
      <h2>
        <span class="icon">📊</span>
        Top1 vs 其他运营商差距分析
      </h2>
      
      <div class="gap-chart" ref="gapRef"></div>
    </section>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  operators: Array,
  selectedMetrics: Array,
  quarterlyData: Array
})

const radarRef = ref(null)
const gapRef = ref(null)
const activeMetric = ref(props.selectedMetrics[0] || 'revenue')
let radarChart = null
let gapChart = null

const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4']

// 排名数据
const rankingData = computed(() => {
  const data = props.operators.map(op => {
    const latestData = props.quarterlyData
      .filter(d => d.operatorId === op.id)
      .sort((a, b) => b.quarter.localeCompare(a.quarter))[0]
    
    return {
      operatorId: op.id,
      name: op.name,
      country: op.country,
      value: latestData?.[activeMetric.value] || 0
    }
  })
  
  // 排序
  const sorted = [...data].sort((a, b) => b.value - a.value)
  const max = sorted[0]?.value || 1
  
  return sorted.map(item => ({
    ...item,
    percent: (item.value / max) * 100
  }))
})

// 初始化雷达图
const initRadarChart = () => {
  if (!radarRef.value) return
  
  if (radarChart) {
    radarChart.dispose()
  }
  
  radarChart = echarts.init(radarRef.value, null, { renderer: 'svg' })
  
  // 指标配置
  const metricConfigs = [
    { key: 'revenue', name: '营收规模', max: 10 },
    { key: 'ebitdaMargin', name: '盈利能力', max: 50 },
    { key: 'subscriberGrowth', name: '增长潜力', max: 20 },
    { key: 'arpu', name: '用户价值', max: 15 },
    { key: 'debtRatio', name: '财务稳健', max: 100 },
    { key: 'fcf', name: '现金流', max: 3 }
  ]
  
  // 构建数据
  const series = props.operators.map((op, index) => {
    const latestData = props.quarterlyData
      .filter(d => d.operatorId === op.id)
      .sort((a, b) => b.quarter.localeCompare(a.quarter))[0]
    
    return {
      name: op.name,
      value: metricConfigs.map(config => {
        let val = latestData?.[config.key] || 0
        // 负债率是反向指标
        if (config.key === 'debtRatio') {
          val = Math.max(0, 100 - val)
        }
        return val
      }),
      lineStyle: {
        color: colors[index % colors.length],
        width: 2
      },
      areaStyle: {
        color: colors[index % colors.length] + '30'
      },
      itemStyle: {
        color: colors[index % colors.length]
      }
    }
  })
  
  const option = {
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(15, 23, 42, 0.9)',
      borderColor: 'rgba(148, 163, 184, 0.2)',
      textStyle: { color: '#e2e8f0' }
    },
    radar: {
      indicator: metricConfigs.map(c => ({ name: c.name, max: c.max })),
      shape: 'polygon',
      splitNumber: 4,
      axisName: {
        color: '#94a3b8',
        fontSize: 12
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.1)'
        }
      },
      splitArea: {
        areaStyle: {
          color: ['rgba(30, 41, 59, 0.3)', 'rgba(30, 41, 59, 0.1)']
        }
      },
      axisLine: {
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.2)'
        }
      }
    },
    series: [{
      type: 'radar',
      data: series
    }]
  }
  
  radarChart.setOption(option, true)
}

// 初始化差距图
const initGapChart = () => {
  if (!gapRef.value || rankingData.value.length < 2) return
  
  if (gapChart) {
    gapChart.dispose()
  }
  
  gapChart = echarts.init(gapRef.value, null, { renderer: 'svg' })
  
  const top1 = rankingData.value[0]
  const others = rankingData.value.slice(1)
  
  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(15, 23, 42, 0.9)',
      borderColor: 'rgba(148, 163, 184, 0.2)',
      textStyle: { color: '#e2e8f0' }
    },
    grid: {
      left: 100,
      right: 60,
      top: 20,
      bottom: 40
    },
    xAxis: {
      type: 'value',
      axisLine: { show: false },
      splitLine: {
        lineStyle: { color: 'rgba(148, 163, 184, 0.1)' }
      },
      axisLabel: { color: '#94a3b8' }
    },
    yAxis: {
      type: 'category',
      data: others.map(o => o.name),
      axisLine: {
        lineStyle: { color: 'rgba(148, 163, 184, 0.2)' }
      },
      axisLabel: { color: '#94a3b8' }
    },
    series: [{
      name: '差距',
      type: 'bar',
      data: others.map(o => top1.value - o.value),
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#3b82f6' },
          { offset: 1, color: '#60a5fa' }
        ])
      },
      label: {
        show: true,
        position: 'right',
        formatter: (params) => params.value.toFixed(2),
        color: '#e2e8f0'
      }
    }]
  }
  
  gapChart.setOption(option, true)
}

// 辅助方法
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

const getFlag = (country) => {
  const flags = {
    'South Africa': '🇿🇦',
    'Nigeria': '🇳🇬',
    'Zimbabwe': '🇿🇼'
  }
  return flags[country] || '🌍'
}

const formatValue = (val) => {
  return val.toFixed(2)
}

const getBarClass = (index) => {
  if (index === 0) return 'gold'
  if (index === 1) return 'silver'
  if (index === 2) return 'bronze'
  return 'default'
}

onMounted(() => {
  initRadarChart()
  initGapChart()
  
  window.addEventListener('resize', () => {
    radarChart?.resize()
    gapChart?.resize()
  })
})

watch(() => [props.operators, props.selectedMetrics, props.quarterlyData, activeMetric], () => {
  initRadarChart()
  initGapChart()
}, { deep: true })

onUnmounted(() => {
  radarChart?.dispose()
  gapChart?.dispose()
})
</script>

<style scoped>
.comparison-view {
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

/* 雷达图 */
.radar-container {
  display: flex;
  gap: 24px;
  align-items: center;
}

.radar-chart {
  flex: 1;
  height: 350px;
}

.radar-legend {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.legend-color {
  width: 16px;
  height: 3px;
  border-radius: 2px;
}

.legend-name {
  font-size: 13px;
  color: #94a3b8;
}

/* 排名 */
.ranking-tabs {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}

.ranking-tabs button {
  padding: 8px 16px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.5);
  color: #94a3b8;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.ranking-tabs button:hover {
  border-color: rgba(59, 130, 246, 0.3);
  color: #e2e8f0;
}

.ranking-tabs button.active {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-color: #3b82f6;
  color: white;
}

.ranking-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.ranking-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 12px 16px;
  background: rgba(15, 23, 42, 0.3);
  border-radius: 8px;
  transition: all 0.2s ease;
}

.ranking-item:hover {
  background: rgba(15, 23, 42, 0.5);
}

.ranking-item.top {
  background: rgba(234, 179, 8, 0.1);
  border: 1px solid rgba(234, 179, 8, 0.3);
}

.rank {
  width: 40px;
  display: flex;
  align-items: center;
  gap: 4px;
}

.rank-num {
  font-size: 16px;
  font-weight: 700;
  color: #94a3b8;
}

.rank-medal {
  font-size: 16px;
}

.operator-info {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 120px;
}

.flag {
  font-size: 16px;
}

.name {
  font-size: 14px;
  font-weight: 500;
  color: #f1f5f9;
}

.value-bar {
  flex: 1;
  height: 8px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 4px;
  overflow: hidden;
}

.bar-fill {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.bar-fill.gold {
  background: linear-gradient(90deg, #fbbf24, #f59e0b);
}

.bar-fill.silver {
  background: linear-gradient(90deg, #94a3b8, #64748b);
}

.bar-fill.bronze {
  background: linear-gradient(90deg, #f97316, #ea580c);
}

.bar-fill.default {
  background: linear-gradient(90deg, #3b82f6, #2563eb);
}

.value {
  font-size: 14px;
  font-weight: 600;
  color: #f1f5f9;
  min-width: 80px;
  text-align: right;
}

/* 差距图 */
.gap-chart {
  height: 250px;
}
</style>