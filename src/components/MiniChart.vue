<template>
  <div class="mini-chart" ref="chartRef"></div>
</template>

<script setup>
import { ref, onMounted, watch, onUnmounted } from 'vue'
import * as echarts from 'echarts'

const props = defineProps({
  data: {
    type: Array,
    default: () => []
  },
  color: {
    type: String,
    default: '#3b82f6'
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
    grid: {
      left: 0,
      right: 0,
      top: 5,
      bottom: 5
    },
    xAxis: {
      type: 'category',
      show: false,
      data: props.data.map((_, i) => i)
    },
    yAxis: {
      type: 'value',
      show: false
    },
    series: [{
      type: 'line',
      data: props.data,
      smooth: true,
      symbol: 'none',
      lineStyle: {
        width: 2,
        color: props.color
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: props.color + '40' },
          { offset: 1, color: props.color + '00' }
        ])
      }
    }]
  }
  
  chart.setOption(option)
}

onMounted(() => {
  initChart()
})

watch(() => [props.data, props.color], () => {
  initChart()
}, { deep: true })

onUnmounted(() => {
  if (chart) {
    chart.dispose()
  }
})
</script>

<style scoped>
.mini-chart {
  width: 100%;
  height: 100%;
}
</style>