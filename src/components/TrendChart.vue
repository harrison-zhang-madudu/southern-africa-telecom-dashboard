<template>
  <div class="trend-chart" ref="chartRef"></div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
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
    quarters.add(d.period)
  })
  
  const quarterList = Array.from(quarters).sort()
  const metricKey = getMetricKey(props.metricName)
  
  // 构建柱状图系列（主轴）
  const barSeries = props.operators.map((op, index) => {
    const opData = operatorData[op.id] || []
    const dataMap = {}
    opData.forEach(d => {
      dataMap[d.period] = d
    })
    
    return {
      name: op.name,
      type: 'bar',
      barWidth: '12%',
      data: quarterList.map(q => dataMap[q]?.[metricKey] || null),
      itemStyle: {
        color: colors[index % colors.length],
        borderRadius: [4, 4, 0, 0]
      },
      emphasis: {
        focus: 'series'
      }
    }
  })
  
  // 计算变化趋势（副轴）- 使用第一个运营商的数据
  const firstOpData = operatorData[props.operators[0]?.id] || []
  const firstOpDataMap = {}
  firstOpData.forEach(d => {
    firstOpDataMap[d.period] = d
  })
  
  // 计算环比变化率
  const trendData = quarterList.map((q, idx) => {
    const current = firstOpDataMap[q]?.[metricKey]
    if (idx === 0 || current == null) return 0
    const previous = firstOpDataMap[quarterList[idx - 1]]?.[metricKey]
    if (previous == null || previous === 0) return 0
    return ((current - previous) / Math.abs(previous) * 100).toFixed(1)
  })
  
  // 折线图系列（副轴）
  const lineSeries = {
    name: '环比变化率',
    type: 'line',
    yAxisIndex: 1,
    smooth: true,
    symbol: 'circle',
    symbolSize: 6,
    data: trendData,
    lineStyle: {
      width: 2,
      color: '#f59e0b',
      type: 'dashed'
    },
    itemStyle: {
      color: '#f59e0b'
    },
    emphasis: {
      focus: 'series'
    }
  }
  
  const option = {
    tooltip: {
      trigger: 'axis',
      backgroundColor: 'rgba(15, 23, 42, 0.9)',
      borderColor: 'rgba(148, 163, 184, 0.2)',
      textStyle: {
        color: '#e2e8f0'
      },
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params) => {
        if (!params || !params.length) return ''
        let html = `<div style="font-weight:600;margin-bottom:8px">${params[0].axisValue}</div>`
        params.forEach(p => {
          if (p.value != null && p.seriesName !== '环比变化率') {
            html += `<div style="display:flex;justify-content:space-between;gap:20px;margin:4px 0">
              <span>${p.marker} ${p.seriesName}</span>
              <span style="font-weight:600">${p.value.toFixed(2)}</span>
            </div>`
          }
        })
        // 显示变化率
        const trendParam = params.find(p => p.seriesName === '环比变化率')
        if (trendParam && trendParam.value != null) {
          html += `<div style="display:flex;justify-content:space-between;gap:20px;margin:4px 0;border-top:1px solid rgba(148,163,184,0.2);padding-top:4px">
            <span>${trendParam.marker} 环比变化</span>
            <span style="font-weight:600;color:${trendParam.value >= 0 ? '#10b981' : '#ef4444'}">${trendParam.value >= 0 ? '+' : ''}${trendParam.value}%</span>
          </div>`
        }
        return html
      }
    },
    legend: {
      data: [...props.operators.map(op => op.name), '环比变化率'],
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
      right: 60,
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
    yAxis: [
      {
        type: 'value',
        name: props.metricName,
        nameTextStyle: {
          color: '#94a3b8',
          fontSize: 11
        },
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
      {
        type: 'value',
        name: '变化率(%)',
        nameTextStyle: {
          color: '#94a3b8',
          fontSize: 11
        },
        axisLine: {
          show: false
        },
        splitLine: {
          show: false
        },
        axisLabel: {
          color: '#f59e0b',
          fontSize: 11,
          formatter: '{value}%'
        }
      }
    ],
    series: [...barSeries, lineSeries]
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