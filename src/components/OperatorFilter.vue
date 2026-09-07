<template>
  <div class="operator-filter">
    <!-- 可折叠的标题 -->
    <div class="filter-header" @click="isCollapsed = !isCollapsed">
      <h3>
        <span class="icon">🏢</span>
        运营商筛选
        <span class="collapse-icon">{{ isCollapsed ? '▶' : '▼' }}</span>
      </h3>
      <div class="header-summary" v-if="isCollapsed">
        <span class="selected-badge">{{ selectedOperators.length }}家已选</span>
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
      
      <div class="operator-list">
        <label 
          v-for="operator in operators" 
          :key="operator.id"
          class="operator-item"
          :class="{ 
            selected: selectedOperators.includes(operator.id),
            [operator.country.toLowerCase().replace(/\s/g, '-')]: true
          }"
        >
          <input 
            type="checkbox"
            :value="operator.id"
            v-model="selectedOperators"
            class="checkbox"
          />
          
          <div class="operator-card">
            <div class="operator-header">
              <span class="operator-flag">{{ getFlag(operator.country) }}</span>
              <span class="operator-name">{{ operator.name }}</span>
              <!-- 官网链接 -->
              <a 
                v-if="operator.website"
                :href="operator.website"
                target="_blank"
                class="website-link"
                title="访问官网"
                @click.stop
              >
                🔗
              </a>
            </div>
            <div class="operator-meta">
              <span class="country">{{ operator.country }}</span>
              <span class="subscribers">{{ formatNumber(operator.subscribers) }}用户</span>
            </div>
            
            <!-- 状态指示器 -->
            <div class="status-indicator" :class="operator.status">
              <span class="status-dot"></span>
              <span class="status-text">{{ getStatusText(operator.status) }}</span>
            </div>
          </div>
        </label>
      </div>
      
      <div class="selection-count">
        已选择 {{ selectedOperators.length }} / {{ operators.length }} 家运营商
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const props = defineProps({
  operators: {
    type: Array,
    required: true
  },
  selectedOperators: {
    type: Array,
    required: true
  }
})

const emit = defineEmits(['update:selectedOperators'])

// 折叠状态
const isCollapsed = ref(false)

// 双向绑定
const selectedOperators = computed({
  get: () => props.selectedOperators,
  set: (val) => emit('update:selectedOperators', val)
})

// 国旗映射
const getFlag = (country) => {
  const flags = {
    'South Africa': '🇿🇦',
    'Nigeria': '🇳🇬',
    'Zimbabwe': '🇿🇼',
    'Kenya': '🇰🇪',
    'Ghana': '🇧🇭',
    'Tanzania': '🇹🇿'
  }
  return flags[country] || '🌍'
}

// 状态文本
const getStatusText = (status) => {
  const texts = {
    'growth': '增长中',
    'stable': '稳定',
    'decline': '下滑'
  }
  return texts[status] || '未知'
}

// 格式化数字
const formatNumber = (num) => {
  if (num >= 100) {
    return (num / 1000).toFixed(1) + '亿'
  }
  return num + 'M'
}

// 全选
const selectAll = () => {
  selectedOperators.value = props.operators.map(op => op.id)
}

// 清空
const selectNone = () => {
  selectedOperators.value = []
}
</script>

<style scoped>
.operator-filter {
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
  max-height: 400px;
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

.operator-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.operator-item {
  cursor: pointer;
}

.checkbox {
  display: none;
}

.operator-card {
  padding: 12px;
  border-radius: 8px;
  border: 1px solid rgba(148, 163, 184, 0.1);
  background: rgba(30, 41, 59, 0.3);
  transition: all 0.2s ease;
}

.operator-item:hover .operator-card {
  background: rgba(30, 41, 59, 0.5);
  border-color: rgba(148, 163, 184, 0.2);
}

.operator-item.selected .operator-card {
  background: rgba(59, 130, 246, 0.15);
  border-color: rgba(59, 130, 246, 0.4);
  box-shadow: 0 0 0 1px rgba(59, 130, 246, 0.2);
}

.operator-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 6px;
}

.operator-flag {
  font-size: 16px;
}

.operator-name {
  font-size: 14px;
  font-weight: 600;
  color: #f1f5f9;
}

.website-link {
  margin-left: auto;
  text-decoration: none;
  font-size: 14px;
  opacity: 0.6;
  transition: opacity 0.2s;
  padding: 2px 4px;
  border-radius: 4px;
}

.website-link:hover {
  opacity: 1;
  background: rgba(59, 130, 246, 0.2);
}

.operator-meta {
  display: flex;
  justify-content: space-between;
  font-size: 11px;
  color: #64748b;
  margin-bottom: 8px;
}

.status-indicator {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  padding: 4px 8px;
  border-radius: 12px;
  width: fit-content;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
}

.status-indicator.growth {
  background: rgba(34, 197, 94, 0.15);
  color: #4ade80;
}

.status-indicator.growth .status-dot {
  background: #4ade80;
}

.status-indicator.stable {
  background: rgba(59, 130, 246, 0.15);
  color: #60a5fa;
}

.status-indicator.stable .status-dot {
  background: #60a5fa;
}

.status-indicator.decline {
  background: rgba(239, 68, 68, 0.15);
  color: #f87171;
}

.status-indicator.decline .status-dot {
  background: #f87171;
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