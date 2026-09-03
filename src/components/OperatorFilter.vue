<template>
  <div class="operator-filter">
    <h3 class="filter-title">
      <span class="icon">🏢</span>
      运营商选择
    </h3>
    
    <div class="filter-content">
      <button 
        :class="['filter-item', 'all-btn', { active: !selectedOperator }]"
        @click="$emit('select', null)"
      >
        全部运营商
      </button>
      
      <div class="operator-list">
        <button
          v-for="operator in operators"
          :key="operator.id"
          :class="['filter-item', 'operator-btn', { active: selectedOperator === operator.id }]"
          @click="$emit('select', operator.id)"
        >
          <span class="operator-flag">{{ operator.logo }}</span>
          <span class="operator-name">{{ operator.name }}</span>
          <span class="operator-country">{{ operator.country }}</span>
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'OperatorFilter',
  props: {
    operators: Array,
    selectedOperator: String
  },
  emits: ['select']
}
</script>

<style scoped>
.operator-filter {
  background: rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 15px;
  margin-bottom: 15px;
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

.filter-content {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.filter-item {
  padding: 10px 12px;
  border: none;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.05);
  color: #e0e0e0;
  cursor: pointer;
  transition: all 0.3s ease;
  text-align: left;
}

.filter-item:hover {
  background: rgba(255, 255, 255, 0.1);
}

.filter-item.active {
  background: linear-gradient(135deg, #00d9ff 0%, #00b4d8 100%);
  color: #1a1a2e;
  box-shadow: 0 2px 10px rgba(0, 217, 255, 0.3);
}

.all-btn {
  font-weight: 500;
  text-align: center;
}

.operator-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.operator-btn {
  display: flex;
  align-items: center;
  gap: 10px;
}

.operator-flag {
  font-size: 20px;
}

.operator-name {
  flex: 1;
  font-weight: 500;
}

.operator-country {
  font-size: 11px;
  opacity: 0.7;
}
</style>