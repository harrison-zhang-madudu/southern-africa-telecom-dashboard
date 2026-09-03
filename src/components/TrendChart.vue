<template>
  <div class="trend-chart" ref="chartRef"></div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted, computed } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  },
  metricName: {
    type: String,
    default: ''
  },
  operators: {
    type: Array,
    default: () => []
  }
})

const chartRef = ref(null)
let chart = null

// 颜色配置
const colors = [
  '#3b82f6', // 蓝色
  '#10b981', // 绿色
  '#f59e0b', // 橙色
  '#ef4444', // 红色
  '#8b5cf6', // 紫色
  '#06b6d4'  // 青色
]

const initChart = () => {
  if (!chartRef.value || !props.data.length) return
  
  if (chart) {
    chart.dispose()
  }
  
  chart = echarts.init(chartRef.value, null, {
    renderer: 'svg'
  })
  
  // 按运营商分组
  const operatorData = {}
  const quarters = new Set()
  
  props.data.forEach(d => {
    if (!operatorData[d.operatorId]) {
      operatorData[d.operatorId] = []
    }
    operatorData[d.operatorId].push(d)
    quarters.add(d.quarter)
  })
  
  const quarterList = Array.from(quarters).sort()
  
  // 构建系列
  const series = props.operators.map((op, index) => {
    const opData = operatorData[op.id] || []
    const dataMap = {}
    opData.forEach(d => {
      dataMap[d.quarter] = d
    })
    
    const metricKey = getMetricKey(props.metricName)
    
    return {
      name: op.name,
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 6,
      data: quarterList.map(q => dataMap[q]?.[metricKey] || null),
      lineStyle: {
        width: 2,
        color: colors[index % colors.length]
      },
      itemStyle: {
        color: colors[index % colors.length]
      },
      emphasis: {
        focus: 'series'
      }
    }
  })
  
  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(15, 23, 42, 0.9)',
      borderColor: 'rgba(148, 163, 184, 0.2)',
      textStyle: {
        color: '#e2e8f0'
      },
      formatter: (params) => {
        if (!params || !params.length) return ''
        let html = `<div style="font-weight:600;margin-bottom:8px">${params[0].axisValue}</div>`
        params.forEach(p => {
          if (p.value != null) {
            html += `<div style="display:flex;justify-content:space-between;gap:20px;margin:4px 0">
              <span>${p.marker} ${p.seriesName}</span>
              <span style="font-weight:600">${p.value.toFixed(2)}</span>
            </div>`
          }
        })
        return html
      }
    },
    legend: {
      data: props.operators.map(op => op.name),
      top: 0,
      textStyle: {
        color: '#94a3b8',
        fontSize: 12
      },
      itemWidth: 20,
      itemHeight: 10
    },
    grid: {
      left: 60,
      right: 20,
      top: 40,
      bottom: 40
    },
    xAxis: {
      type: 'category',
      data: quarterList,
      axisLine: {
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.2)'
        }
      },
      axisLabel: {
        color: '#94a3b8',
        fontSize: 11
      }
    },
    yAxis: {
      type: 'value',
      axisLine: {
        show: false
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.1)'
        }
      },
      axisLabel: {
        color: '#94a3b8',
        fontSize: 11
      }
    },
    series
  }
  
  chart.setOption(option, true)
}

const getMetricKey = (name) => {
  const keyMap = {
    '营业收入': 'revenue',
    'EBITDA利润率': 'ebitdaMargin',
    '订户增长率': 'subscriberGrowth',
    'ARPU': 'arpu',
    '资本开支比': 'capexRatio',
    '负债率': 'debtRatio',
    '自由现金流': 'fcf',
    '流失率': 'churnRate'
  }
  return keyMap[name] || name
}

onMounted(() => {
  initChart()
  
  // 响应式
  window.addEventListener('resize', () => {
    chart?.resize()
  })
})

watch(() => [props.data, props.metricName, props.operators], () => {
  initChart()
}, { deep: true })

onUnmounted(() => {
  if (chart) {
    chart.dispose()
  }
  window.removeEventListener('resize', () => {
    chart?.resize()
  })
})
</script>

<style scoped>
.trend-chart {
  width: 100%;
  height: 100%;
}
</style>