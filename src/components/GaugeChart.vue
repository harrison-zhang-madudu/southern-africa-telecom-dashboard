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
  
  const percent = (props.value / props.max) * 100
  
  const option = {
    series: [{
      type: 'gauge',
      startAngle: 200,
      endAngle: -20,
      min: 0,
      max: props.max,
      radius: '100%',
      center: ['50%', '70%'],
      splitNumber: 4,
      axisLine: {
        lineStyle: {
          width: 8,
          color: [
            [0.3, '#ef4444'],
            [0.7, '#f59e0b'],
            [1, props.color]
          ]
        }
      },
      pointer: {
        icon: 'path://M12,2L15,8L12,14L9,8L12,2Z',
        length: '60%',
        width: 6,
        offsetCenter: [0, '-10%'],
        itemStyle: {
          color: props.color
        }
      },
      axisTick: {
        show: false
      },
      splitLine: {
        show: false
      },
      axisLabel: {
        show: false
      },
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
}

.chart {
  width: 100%;
  height: 120px;
}

.info {
  text-align: center;
  margin-top: 8px;
}

.title {
  font-size: 11px;
  color: #94a3b8;
  margin-bottom: 4px;
}

.value {
  font-size: 20px;
  font-weight: 700;
  color: #f1f5f9;
}

.unit {
  font-size: 12px;
  color: #64748b;
  margin-left: 2px;
}
</style>