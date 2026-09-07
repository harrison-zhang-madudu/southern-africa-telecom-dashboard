<template>
  <div class="comparison-view">
    <!-- 年份筛选器（单选） -->
    <div class="year-filter-inline">
      <span class="filter-label">📅 数据年份：</span>
      <div class="year-chips">
        <button 
          v-for="year in availableYears" 
          :key="year"
          :class="{ active: selectedYear === year }"
          @click="emit('update:selectedYear', year)"
          class="year-chip"
        >
          {{ year }}
        </button>
      </div>
    </div>
    
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
    
    <!-- 四大财务能力雷达图 -->
    <section class="financial-radar-section">
      <h2>
        <span class="icon">📊</span>
        四大财务能力分析
      </h2>
      
      <div class="financial-radar-controls">
        <label class="operator-select-label">选择运营商：</label>
        <select v-model="selectedFinancialOperator" class="operator-select">
          <option value="all">全部运营商</option>
          <option v-for="op in operators" :key="op.id" :value="op.id">
            {{ op.name }}
          </option>
        </select>
      </div>
      
      <div class="financial-radar-container">
        <div class="financial-radar-chart" ref="financialRadarRef"></div>
        
        <div class="financial-radar-legend">
          <div class="legend-title">四大财务能力说明</div>
          <div class="legend-item">
            <span class="legend-icon">💰</span>
            <span class="legend-text">盈利能力：EBITDA利润率、ARPU</span>
          </div>
          <div class="legend-item">
            <span class="legend-icon">🏦</span>
            <span class="legend-text">偿债能力：负债率(反向)、现金流</span>
          </div>
          <div class="legend-item">
            <span class="legend-icon">⚙️</span>
            <span class="legend-text">营运能力：资本开支比、流失率(反向)</span>
          </div>
          <div class="legend-item">
            <span class="legend-icon">📈</span>
            <span class="legend-text">发展能力：订户增长率、营收增长</span>
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
  quarterlyData: Array,
  selectedYear: Number,
  availableYears: Array
})

const emit = defineEmits(['update:selectedYear'])

const radarRef = ref(null)
const gapRef = ref(null)
const financialRadarRef = ref(null)
const activeMetric = ref(props.selectedMetrics[0] || 'revenue')
const selectedFinancialOperator = ref('all')
let radarChart = null
let gapChart = null
let financialRadarChart = null

const colors = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#06b6d4']

// 排名数据
const rankingData = computed(() => {
  const data = props.operators.map(op => {
    const latestData = props.quarterlyData
      .filter(d => d.operatorId === op.id)
      .sort((a, b) => b.period.localeCompare(a.period))[0]
    
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

// 动态指标配置 - 响应props.selectedMetrics变化
const metricConfigs = computed(() => {
  const allConfigs = {
    revenue: { key: 'revenue', name: '营收规模', max: 10 },
    ebitdaMargin: { key: 'ebitdaMargin', name: 'EBITDA利润率', max: 50 },
    subscriberGrowth: { key: 'subscriberGrowth', name: '订户增长', max: 20 },
    arpu: { key: 'arpu', name: 'ARPU', max: 15 },
    capexRatio: { key: 'capexRatio', name: '资本开支', max: 30 },
    debtRatio: { key: 'debtRatio', name: '财务稳健', max: 100, inverse: true },
    fcf: { key: 'fcf', name: '现金流', max: 3 },
    churnRate: { key: 'churnRate', name: '流失率', max: 10, inverse: true }
  }
  
  // 只使用选中的指标
  return props.selectedMetrics
    .filter(m => allConfigs[m])
    .map(m => allConfigs[m])
})

// 初始化雷达图
const initRadarChart = () => {
  if (!radarRef.value) return
  
  if (radarChart) {
    radarChart.dispose()
  }
  
  radarChart = echarts.init(radarRef.value, null, { renderer: 'svg' })
  
  // 构建数据 - 使用动态metricConfigs
  const series = props.operators.map((op, index) => {
    const latestData = props.quarterlyData
      .filter(d => d.operatorId === op.id)
      .sort((a, b) => b.period.localeCompare(a.period))[0]
    
    return {
      name: op.name,
      value: metricConfigs.value.map(config => {
        let val = latestData?.[config.key] || 0
        // 反向指标处理（负债率、流失率）
        if (config.inverse) {
          val = Math.max(0, config.max - val)
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
      indicator: metricConfigs.value.map(c => ({ name: c.name, max: c.max })),
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

// 四大财务能力计算
const calculateFinancialCapabilities = (operatorId) => {
  const latestData = props.quarterlyData
    .filter(d => d.operatorId === operatorId)
    .sort((a, b) => b.period.localeCompare(a.period))[0]
  
  if (!latestData) return null
  
  // 盈利能力 (0-100): EBITDA利润率(权重60%) + ARPU标准化(权重40%)
  const profitability = Math.min(100, 
    (latestData.ebitdaMargin || 0) * 0.6 * 2 + 
    Math.min(50, (latestData.arpu || 0) * 10) * 0.4
  )
  
  // 偿债能力 (0-100): (100-负债率*10)(权重50%) + 现金流标准化(权重50%)
  const solvency = Math.min(100, Math.max(0,
    (100 - (latestData.debtRatio || 0) * 10) * 0.5 +
    Math.min(50, (latestData.fcf || 0) * 20) * 0.5
  ))
  
  // 营运能力 (0-100): 资本开支比(权重50%) + (100-流失率*10)(权重50%)
  const operation = Math.min(100,
    Math.min(50, (latestData.capexRatio || 0) * 2) * 0.5 +
    Math.max(0, 100 - (latestData.churnRate || 0) * 10) * 0.5
  )
  
  // 发展能力 (0-100): 订户增长率(权重60%) + 假设的营收增长率(权重40%)
  const growth = Math.min(100,
    Math.min(50, (latestData.subscriberGrowth || 0) * 3) * 0.6 +
    Math.min(50, (latestData.subscriberGrowth || 0) * 2) * 0.4
  )
  
  return {
    profitability: profitability.toFixed(1),
    solvency: solvency.toFixed(1),
    operation: operation.toFixed(1),
    growth: growth.toFixed(1)
  }
}

// 初始化四大财务能力雷达图
const initFinancialRadarChart = () => {
  if (!financialRadarRef.value) return
  
  if (financialRadarChart) {
    financialRadarChart.dispose()
  }
  
  financialRadarChart = echarts.init(financialRadarRef.value, null, { renderer: 'svg' })
  
  const indicator = [
    { name: '盈利能力', max: 100 },
    { name: '偿债能力', max: 100 },
    { name: '营运能力', max: 100 },
    { name: '发展能力', max: 100 }
  ]
  
  let series = []
  
  if (selectedFinancialOperator.value === 'all') {
    // 显示所有运营商
    series = props.operators.map((op, index) => {
      const capabilities = calculateFinancialCapabilities(op.id)
      return {
        name: op.name,
        value: capabilities ? [
          parseFloat(capabilities.profitability),
          parseFloat(capabilities.solvency),
          parseFloat(capabilities.operation),
          parseFloat(capabilities.growth)
        ] : [0, 0, 0, 0],
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
  } else {
    // 显示单个运营商
    const op = props.operators.find(o => o.id === selectedFinancialOperator.value)
    const opIndex = props.operators.findIndex(o => o.id === selectedFinancialOperator.value)
    if (op) {
      const capabilities = calculateFinancialCapabilities(op.id)
      series = [{
        name: op.name,
        value: capabilities ? [
          parseFloat(capabilities.profitability),
          parseFloat(capabilities.solvency),
          parseFloat(capabilities.operation),
          parseFloat(capabilities.growth)
        ] : [0, 0, 0, 0],
        lineStyle: {
          color: colors[opIndex % colors.length],
          width: 3
        },
        areaStyle: {
          color: colors[opIndex % colors.length] + '50'
        },
        itemStyle: {
          color: colors[opIndex % colors.length]
        }
      }]
    }
  }
  
  const option = {
    title: {
      text: selectedFinancialOperator.value === 'all' ? '运营商对比' : '财务能力分析',
      left: 'center',
      top: 0,
      textStyle: {
        color: '#94a3b8',
        fontSize: 14
      }
    },
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(15, 23, 42, 0.9)',
      borderColor: 'rgba(148, 163, 184, 0.2)',
      textStyle: { color: '#e2e8f0' },
      formatter: (params) => {
        const names = ['盈利能力', '偿债能力', '营运能力', '发展能力']
        let result = `<strong>${params.name}</strong><br/>`
        params.value.forEach((val, idx) => {
          result += `${names[idx]}: ${val.toFixed(1)}<br/>`
        })
        return result
      }
    },
    legend: selectedFinancialOperator.value === 'all' ? {
      show: true,
      bottom: 0,
      textStyle: { color: '#94a3b8', fontSize: 11 },
      itemWidth: 15,
      itemHeight: 10
    } : { show: false },
    radar: {
      indicator: indicator,
      shape: 'polygon',
      splitNumber: 4,
      center: ['50%', '55%'],
      radius: '65%',
      axisName: {
        color: '#e2e8f0',
        fontSize: 13,
        fontWeight: 'bold'
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.15)'
        }
      },
      splitArea: {
        areaStyle: {
          color: ['rgba(59, 130, 246, 0.05)', 'rgba(59, 130, 246, 0.1)']
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
  
  financialRadarChart.setOption(option, true)
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
  initFinancialRadarChart()
  
  window.addEventListener('resize', () => {
    radarChart?.resize()
    gapChart?.resize()
    financialRadarChart?.resize()
  })
})

watch(() => [props.operators, props.selectedMetrics, props.quarterlyData, activeMetric], () => {
  initRadarChart()
  initGapChart()
  initFinancialRadarChart()
}, { deep: true })

watch(selectedFinancialOperator, () => {
  initFinancialRadarChart()
})

onUnmounted(() => {
  radarChart?.dispose()
  gapChart?.dispose()
  financialRadarChart?.dispose()
})
</script>

<style scoped>
.comparison-view {
  display: flex;
  flex-direction: column;
  gap: 24px;
}

/* 年份筛选器 */
.year-filter-inline {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 8px;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.filter-label {
  font-size: 13px;
  color: #94a3b8;
  font-weight: 500;
}

.year-chips {
  display: flex;
  gap: 6px;
}

.year-chip {
  padding: 6px 14px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.5);
  color: #cbd5e1;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s;
}

.year-chip:hover {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.3);
}

.year-chip.active {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
  border-color: #3b82f6;
  color: white;
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

/* 四大财务能力雷达图 */
.financial-radar-section {
  background: rgba(30, 41, 59, 0.5);
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.1);
  padding: 20px;
}

.financial-radar-controls {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}

.operator-select-label {
  font-size: 13px;
  color: #94a3b8;
  font-weight: 500;
}

.operator-select {
  padding: 8px 16px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.8);
  color: #e2e8f0;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s;
  min-width: 180px;
}

.operator-select:hover {
  border-color: rgba(59, 130, 246, 0.4);
}

.operator-select:focus {
  outline: none;
  border-color: #3b82f6;
}

.financial-radar-container {
  display: flex;
  gap: 24px;
  align-items: flex-start;
}

.financial-radar-chart {
  flex: 1;
  height: 380px;
  min-height: 350px;
}

.financial-radar-legend {
  width: 240px;
  padding: 16px;
  background: rgba(15, 23, 42, 0.4);
  border-radius: 8px;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.legend-title {
  font-size: 13px;
  font-weight: 600;
  color: #e2e8f0;
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
}

.financial-radar-legend .legend-item {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 10px;
}

.legend-icon {
  font-size: 14px;
  flex-shrink: 0;
}

.legend-text {
  font-size: 11px;
  color: #94a3b8;
  line-height: 1.4;
}
</style>