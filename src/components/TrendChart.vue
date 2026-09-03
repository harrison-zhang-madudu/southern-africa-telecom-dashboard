<template>
  <div class="chart-container" ref="chartRef"></div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts'

export default {
  name: 'TrendChart',
  props: {
    data: Array,
    operators: Array,
    title: String,
    unit: String
  },
  setup(props) {
    const chartRef = ref(null)
    let chartInstance = null
    
    const initChart = () => {
      if (!chartRef.value) return
      
      chartInstance = echarts.init(chartRef.value)
      
      const periods = props.data.map(d => d.period)
      const series = props.operators.map(operator => ({
        name: operator.name,
        type: 'line',
        smooth: true,
        symbol: 'circle',
        symbolSize: 8,
        data: props.data.map(d => d[operator.id]),
        lineStyle: {
          width: 3
        }
      }))
      
      const option = {
        tooltip: {
          trigger: 'axis',
          backgroundColor: 'rgba(26, 26, 46, 0.9)',
          borderColor: 'rgba(255, 255, 255, 0.2)',
          textStyle: {
            color: '#e0e0e0'
          },
          formatter: (params) => {
            let result = `<strong>${params[0].axisValue}</strong><br/>`
            params.forEach(param => {
              if (param.value !== null) {
                result += `${param.marker} ${param.seriesName}: <strong>${param.value.toFixed(1)}${props.unit}</strong><br/>`
              }
            })
            return result
          }
        },
        legend: {
          data: props.operators.map(op => op.name),
          bottom: 0,
          textStyle: {
            color: '#888',
            fontSize: 11
          },
          itemWidth: 15,
          itemHeight: 8
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '15%',
          top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: periods,
          axisLine: {
            lineStyle: {
              color: 'rgba(255, 255, 255, 0.2)'
            }
          },
          axisLabel: {
            color: '#888',
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
              color: 'rgba(255, 255, 255, 0.1)'
            }
          },
          axisLabel: {
            color: '#888',
            fontSize: 11,
            formatter: `{value}${props.unit}`
          }
        },
        series: series,
        color: ['#00d9ff', '#00c896', '#ff9f43', '#ff6464', '#a855f7', '#3b82f6']
      }
      
      chartInstance.setOption(option)
    }
    
    onMounted(() => {
      initChart()
      
      window.addEventListener('resize', () => {
        chartInstance?.resize()
      })
    })
    
    watch(() => props.data, () => {
      initChart()
    }, { deep: true })
    
    return {
      chartRef
    }
  }
}
</script>

<style scoped>
.chart-container {
  width: 100%;
  height: 300px;
}
</style>