<template>
  <div class="metric-filter">
    <h3>
      <span class="icon">📊</span>
      指标筛选
    </h3>
    
    <div class="filter-actions">
      <button class="action-btn" @click="selectAll">
        全选
      </button>
      <button class="action-btn" @click="selectNone">
        清空
      </button>
    </div>
    
    <div class="metric-list">
      <label 
        v-for="metric in metrics" 
        :key="metric.id"
        class="metric-item"
        :class="{ selected: selectedMetrics.includes(metric.id) }"
      >
        <input 
          type="checkbox"
          :value="metric.id"
          v-model="selectedMetrics"
          class="checkbox"
        />
        
        <div class="metric-card">
          <span class="metric-icon">{{ metric.icon }}</span>
          <div class="metric-info">
            <span class="metric-name">{{ metric.name }}</span>
            <span class="metric-unit">单位: {{ metric.unit }}</span>
          </div>
          
          <div class="check-indicator">
            <svg v-if="selectedMetrics.includes(metric.id)" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
          </div>
        </div>
      </label>
    </div>
    
    <div class="selection-count">
      已选择 {{ selectedMetrics.length }} / {{ metrics.length }} 个指标
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  metrics: {
    type: Array,
    required: true
  },
  selectedMetrics: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:selectedMetrics'])

const selectedMetrics = computed({
  get: () => props.selectedMetrics,
  set: (val) => emit('update:selectedMetrics', val)
})

const selectAll = () => {
  selectedMetrics.value = props.metrics.map(m => m.id)
}

const selectNone = () => {
  selectedMetrics.value = []
}
</script>

<style scoped>
.metric-filter {
  margin-bottom: 24px;
}

h3 {
  font-size: 12px;
  font-weight: 600;
  color: #94a3b8;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon {
  font-size: 14px;
}

.filter-actions {
  display: flex;
  gap: 8px;
  margin-bottom: 12px;
}

.action-btn {
  flex: 1;
  padding: 6px 12px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 6px;
  background: rgba(30, 41, 59, 0.5);
  color: #94a3b8;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.action-btn:hover {
  background: rgba(59, 130, 246, 0.1);
  border-color: rgba(59, 130, 246, 0.3);
  color: #e2e8f0;
}

.metric-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.metric-item {
  cursor: pointer;
}

.checkbox {
  display: none;
}

.metric-card {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 8px;
  border: 1px solid rgba(148, 163, 184, 0.1);
  background: rgba(30, 41, 59, 0.3);
  transition: all 0.2s ease;
}

.metric-item:hover .metric-card {
  background: rgba(30, 41, 59, 0.5);
  border-color: rgba(148, 163, 184, 0.2);
}

.metric-item.selected .metric-card {
  background: rgba(59, 130, 246, 0.15);
  border-color: rgba(59, 130, 246, 0.4);
}

.metric-icon {
  font-size: 18px;
  width: 24px;
  text-align: center;
}

.metric-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.metric-name {
  font-size: 13px;
  font-weight: 500;
  color: #f1f5f9;
}

.metric-unit {
  font-size: 11px;
  color: #64748b;
}

.check-indicator {
  width: 18px;
  height: 18px;
  border-radius: 4px;
  border: 1.5px solid rgba(148, 163, 184, 0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.metric-item.selected .check-indicator {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.check-indicator svg {
  width: 12px;
  height: 12px;
}

.selection-count {
  margin-top: 12px;
  padding: 8px 12px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 6px;
  font-size: 12px;
  color: #94a3b8;
  text-align: center;
}
</style>