<template>
  <div class="metric-filter">
    <h3 class="filter-title">
      <span class="icon">📊</span>
      指标筛选
    </h3>
    
    <div class="filter-content">
      <div class="metric-categories">
        <div v-for="category in categories" :key="category.id" class="category-group">
          <h4 class="category-title">{{ category.name }}</h4>
          <div class="metric-list">
            <button
              v-for="metric in getMetricsByCategory(category.id)"
              :key="metric.id"
              :class="['metric-btn', { active: selectedMetrics.includes(metric.id) }]"
              @click="toggleMetric(metric.id)"
            >
              <span class="check-icon">{{ selectedMetrics.includes(metric.id) ? '✓' : '' }}</span>
              <span class="metric-name">{{ metric.name }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'MetricFilter',
  props: {
    metrics: Array,
    selectedMetrics: Array
  },
  emits: ['select'],
  setup(props, { emit }) {
    const categories = [
      { id: 'growth', name: '增长性' },
      { id: 'profitability', name: '盈利能力' },
      { id: 'efficiency', name: '运营效率' },
      { id: 'investment', name: '投资' },
      { id: 'financial_health', name: '财务健康' }
    ]
    
    const getMetricsByCategory = (categoryId) => {
      return props.metrics.filter(m => m.category === categoryId)
    }
    
    const toggleMetric = (metricId) => {
      let newSelection
      if (props.selectedMetrics.includes(metricId)) {
        newSelection = props.selectedMetrics.filter(id => id !== metricId)
      } else {
        newSelection = [...props.selectedMetrics, metricId]
      }
      emit('select', newSelection)
    }
    
    return {
      categories,
      getMetricsByCategory,
      toggleMetric
    }
  }
}
</script>

<style scoped>
.metric-filter {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 15px;
}

.filter-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 12px;
  padding-bottom: 10px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.filter-title .icon {
  font-size: 18px;
}

.category-group {
  margin-bottom: 15px;
}

.category-group:last-child {
  margin-bottom: 0;
}

.category-title {
  font-size: 11px;
  color: #888;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 8px;
}

.metric-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.metric-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 10px;
  border: none;
  border-radius: 6px;
  background: rgba(255, 255, 255, 0.03);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s ease;
  text-align: left;
}

.metric-btn:hover {
  background: rgba(255, 255, 255, 0.08);
}

.metric-btn.active {
  background: rgba(0, 217, 255, 0.15);
  color: #00d9ff;
}

.check-icon {
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  background: rgba(255, 255, 255, 0.1);
  font-size: 10px;
  font-weight: bold;
}

.metric-btn.active .check-icon {
  background: #00d9ff;
  color: #1a1a2e;
}

.metric-name {
  flex: 1;
}
</style>