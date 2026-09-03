<template>
  <div class="single-trend-chart" ref="chartRef"></div>
</template>

<script>
import { ref, onMounted, watch } from 'vue'
import * as echarts from 'echarts'

export default {
  name: 'SingleTrendChart',
  props: {
    data: Array,
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
      const values = props.data.map(d => d.value)
      
      const option = {
        tooltip: {
          trigger: 'axis',
          backgroundColor: 'rgba(26, 26, 46, 0.9)',
          borderColor: 'rgba(255, 255, 255, 0.2)',
          textStyle: {
            color: '#e0e0e0'
          },
          formatter: (params) => {
            return `<strong>${params[0].axisValue}</strong><br/>
                    ${params[0].marker} ${props.title}: <strong>${params[0].value.toFixed(1)}${props.unit}</strong>`
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          top: '10%',
          containLabel: true
        },
        xAxis: {
          type: 'category',
          data: periods,
          boundaryGap: false,
          axisLine: {
            lineStyle: {
              color: 'rgba(255, 255, 255, 0.2)'
            }
          },
          axisLabel: {
            color: '#888',
            fontSize: 10
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
            fontSize: 10,
            formatter: `{value}${props.unit}`
          }
        },
        series: [{
          name: props.title,
          type: 'line',
          smooth: true,
          symbol: 'circle',
          symbolSize: 8,
          data: values,
          lineStyle: {
            width: 3,
            color: '#00d9ff'
          },
          areaStyle: {
            color: {
              type: 'linear',
              x: 0,
              y: 0,
              x2: 0,
              y2: 1,
              colorStops: [
                { offset: 0, color: 'rgba(0, 217, 255, 0.3)' },
                { offset: 1, color: 'rgba(0, 217, 255, 0.05)' }
              ]
            }
          },
          itemStyle: {
            color: '#00d9ff',
            borderColor: '#fff',
            borderWidth: 2
          }
        }]
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
.single-trend-chart {
  width: 100%;
  height: 200px;
}
</style>