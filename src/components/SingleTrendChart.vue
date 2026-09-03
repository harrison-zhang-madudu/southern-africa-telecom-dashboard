<template>
  <div class="single-trend-chart" ref="chartRef"></div>
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
  metricUnit: {
    type: String,
    default: ''
  }
})

const chartRef = ref(null)
let chart = null

const initChart = () => {
  if (!chartRef.value || !props.data.length) return
  
  if (chart) {
    chart.dispose()
  }
  
  chart = echarts.init(chartRef.value, null, {
    renderer: 'svg'
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
        const p = params[0]
        return `
          <div style="font-weight:600;margin-bottom:4px">${p.axisValue}</div>
          <div style="color:#60a5fa">${props.metricName}: <strong>${p.value.toFixed(2)} ${props.metricUnit}</strong></div>
        `
      }
    },
    grid: {
      left: 60,
      right: 20,
      top: 20,
      bottom: 40
    },
    xAxis: {
      type: 'category',
      data: props.data.map(d => d.quarter),
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
      name: props.metricUnit,
      nameTextStyle: {
        color: '#64748b',
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
    series: [{
      type: 'line',
      data: props.data.map(d => d.value),
      smooth: true,
      symbol: 'circle',
      symbolSize: 8,
      lineStyle: {
        width: 3,
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
          { offset: 0, color: '#3b82f6' },
          { offset: 1, color: '#60a5fa' }
        ])
      },
      itemStyle: {
        color: '#3b82f6',
        borderWidth: 2,
        borderColor: '#1e3a8a'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(59, 130, 246, 0.3)' },
          { offset: 1, color: 'rgba(59, 130, 246, 0.05)' }
        ])
      },
      emphasis: {
        itemStyle: {
          color: '#60a5fa',
          borderWidth: 3
        }
      }
    }]
  }
  
  chart.setOption(option, true)
}

onMounted(() => {
  initChart()
  
  window.addEventListener('resize', () => {
    chart?.resize()
  })
})

watch(() => [props.data, props.metricName, props.metricUnit], () => {
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
.single-trend-chart {
  width: 100%;
  height: 100%;
}
</style>