<template>
  <div class="metric-filter">
    <!-- 可折叠的标题 -->
    <div class="filter-header" @click="isCollapsed = !isCollapsed">
      <h3>
        <span class="icon">📊</span>
        指标筛选
        <span class="collapse-icon">{{ isCollapsed ? '▶' : '▼' }}</span>
      </h3>
      <div class="header-summary" v-if="isCollapsed">
        <span class="selected-badge">{{ selectedMetrics.length }}个已选</span>
      </div>
    </div>
    
    <!-- 可折叠的内容 -->
    <div class="filter-content" :class="{ collapsed: isCollapsed }">
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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

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

// 折叠状态
const isCollapsed = ref(false)

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
  margin-bottom: 16px;
  border-radius: 12px;
  background: rgba(15, 23, 42, 0.4);
  border: 1px solid rgba(99, 102, 241, 0.1);
  overflow: hidden;
}

/* 可折叠标题 */
.filter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  cursor: pointer;
  transition: all 0.2s;
  user-select: none;
}

.filter-header:hover {
  background: rgba(99, 102, 241, 0.05);
}

h3 {
  font-size: 13px;
  font-weight: 600;
  color: #e2e8f0;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 8px;
}

.icon {
  font-size: 15px;
}

.collapse-icon {
  font-size: 10px;
  color: #94a3b8;
  margin-left: auto;
  transition: transform 0.2s;
}

.header-summary {
  display: flex;
  align-items: center;
  gap: 8px;
}

.selected-badge {
  padding: 4px 10px;
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.2) 0%, rgba(139, 92, 246, 0.2) 100%);
  border-radius: 12px;
  font-size: 11px;
  font-weight: 600;
  color: #a5b4fc;
}

/* 可折叠内容 */
.filter-content {
  padding: 0 16px 16px 16px;
  max-height: 350px;
  overflow-y: auto;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.filter-content.collapsed {
  max-height: 0;
  padding-top: 0;
  padding-bottom: 0;
  opacity: 0;
}

/* 滚动条样式 */
.filter-content::-webkit-scrollbar {
  width: 6px;
}

.filter-content::-webkit-scrollbar-track {
  background: rgba(30, 41, 59, 0.3);
  border-radius: 3px;
}

.filter-content::-webkit-scrollbar-thumb {
  background: rgba(99, 102, 241, 0.4);
  border-radius: 3px;
}

.filter-content::-webkit-scrollbar-thumb:hover {
  background: rgba(99, 102, 241, 0.6);
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