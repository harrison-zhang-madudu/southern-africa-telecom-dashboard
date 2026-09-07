<template>
  <div class="gauge-chart">
    <div class="chart" ref="chartRef"></div>
    <div class="info">
      <div class="title">{{ title }}</div>
      <div class="value">{{ displayValue }}<span class="unit">{{ unit }}</span></div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  value: {
    type: Number,
    default: 0
  },
  max: {
    type: Number,
    default: 100
  },
  title: {
    type: String,
    default: ''
  },
  unit: {
    type: String,
    default: ''
  },
  color: {
    type: String,
    default: '#3b82f6'
  }
})

const chartRef = ref(null)
let chart = null

const displayValue = computed(() => {
  return props.value.toFixed(1)
})

const initChart = () => {
  if (!chartRef.value) return
  
  if (chart) {
    chart.dispose()
  }
  
  chart = echarts.init(chartRef.value, null, {
    renderer: 'svg'
  })
  
  const percent = props.value / props.max
  
  // 根据数值确定颜色
  let currentColor = props.color
  if (percent < 0.3) {
    currentColor = '#ef4444'
  } else if (percent < 0.7) {
    currentColor = '#f59e0b'
  }
  
  const option = {
    series: [{
      type: 'gauge',
      startAngle: 200,
      endAngle: -20,
      min: 0,
      max: props.max,
      radius: '95%',
      center: ['50%', '65%'],
      splitNumber: 5,
      // 进度条样式
      progress: {
        show: true,
        width: 12,
        itemStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 1,
            y2: 0,
            colorStops: [
              { offset: 0, color: currentColor },
              { offset: 1, color: currentColor }
            ]
          },
          shadowColor: currentColor,
          shadowBlur: 8
        }
      },
      // 背景轨道
      axisLine: {
        lineStyle: {
          width: 12,
          color: [
            [1, 'rgba(148, 163, 184, 0.15)']
          ]
        }
      },
      // 指针样式 - 颜色与进度条一致
      pointer: {
        show: true,
        length: '55%',
        width: 5,
        offsetCenter: [0, '-15%'],
        itemStyle: {
          color: currentColor,
          shadowColor: currentColor,
          shadowBlur: 6
        }
      },
      // 刻度线
      axisTick: {
        show: true,
        distance: -18,
        length: 4,
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.4)',
          width: 1
        }
      },
      // 分割线
      splitLine: {
        show: true,
        distance: -22,
        length: 8,
        lineStyle: {
          color: 'rgba(148, 163, 184, 0.6)',
          width: 2
        }
      },
      // 刻度标签
      axisLabel: {
        show: false
      },
      // 中心数值
      detail: {
        show: false
      },
      data: [{
        value: props.value
      }]
    }]
  }
  
  chart.setOption(option, true)
}

onMounted(() => {
  initChart()
})

watch(() => [props.value, props.max, props.color], () => {
  initChart()
})

onUnmounted(() => {
  if (chart) {
    chart.dispose()
  }
})
</script>

<style scoped>
.gauge-chart {
  display: flex;
  flex-direction: column;
  align-items: center;
  height: 100%;
  padding: 8px;
}

.chart {
  width: 100%;
  height: 100px;
  min-height: 80px;
}

.info {
  text-align: center;
  margin-top: 4px;
}

.title {
  font-size: 11px;
  color: #94a3b8;
  margin-bottom: 2px;
  white-space: nowrap;
}

.value {
  font-size: 18px;
  font-weight: 700;
  color: #f1f5f9;
  font-family: 'SF Pro Display', -apple-system, sans-serif;
}

.unit {
  font-size: 11px;
  color: #64748b;
  margin-left: 2px;
  font-weight: 400;
}
</style>