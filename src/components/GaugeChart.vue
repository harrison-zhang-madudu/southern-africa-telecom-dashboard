<template>
  <div class="gauge-container">
    <div class="gauge-chart" ref="gaugeRef"></div>
    <div class="gauge-info">
      <span class="gauge-title">{{ title }}</span>
      <span class="gauge-value">{{ formattedValue }}</span>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import * as echarts from 'echarts'

export default {
  name: 'GaugeChart',
  props: {
    value: Number,
    title: String,
    unit: String,
    min: {
      type: Number,
      default: 0
    },
    max: {
      type: Number,
      default: 100
    },
    higherIsBetter: {
      type: Boolean,
      default: true
    }
  },
  setup(props) {
    const gaugeRef = ref(null)
    let chartInstance = null
    
    const formattedValue = computed(() => {
      if (props.unit === 'USD M') {
        return `$${props.value}M`
      }
      return `${props.value.toFixed(1)}${props.unit || ''}`
    })
    
    const getGaugeColor = () => {
      const percentage = (props.value - props.min) / (props.max - props.min)
      
      if (props.higherIsBetter) {
        if (percentage > 0.6) return '#00c896'
        if (percentage > 0.3) return '#ffc864'
        return '#ff6464'
      } else {
        if (percentage < 0.4) return '#00c896'
        if (percentage < 0.7) return '#ffc864'
        return '#ff6464'
      }
    }
    
    const initChart = () => {
      if (!gaugeRef.value) return
      
      chartInstance = echarts.init(gaugeRef.value)
      
      const option = {
        series: [{
          type: 'gauge',
          radius: '90%',
          startAngle: 200,
          endAngle: -20,
          min: props.min,
          max: props.max,
          splitNumber: 5,
          itemStyle: {
            color: getGaugeColor()
          },
          progress: {
            show: true,
            width: 12
          },
          pointer: {
            show: true,
            length: '60%',
            width: 5,
            itemStyle: {
              color: 'auto'
            }
          },
          axisLine: {
            lineStyle: {
              width: 12,
              color: [[1, 'rgba(255, 255, 255, 0.1)']]
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
          anchor: {
            show: false
          },
          title: {
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
      
      chartInstance.setOption(option)
    }
    
    onMounted(() => {
      initChart()
    })
    
    watch(() => props.value, () => {
      initChart()
    })
    
    return {
      gaugeRef,
      formattedValue
    }
  }
}
</script>

<style scoped>
.gauge-container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.gauge-chart {
  width: 120px;
  height: 120px;
}

.gauge-info {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 10px;
}

.gauge-title {
  font-size: 11px;
  color: #888;
  margin-bottom: 5px;
}

.gauge-value {
  font-size: 18px;
  font-weight: bold;
  color: #00d9ff;
}
</style>