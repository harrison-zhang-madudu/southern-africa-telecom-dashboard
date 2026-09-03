<template>
  <header class="header">
    <div class="header-content">
      <div class="logo-section">
        <div class="logo">
          <span class="logo-icon">📊</span>
          <div class="logo-text">
            <h1>南部非洲电信运营商洞察看板</h1>
            <p class="subtitle">Southern Africa Telecom Operators Insight Dashboard</p>
          </div>
        </div>
      </div>
      
      <div class="header-info">
        <div class="info-item">
          <span class="label">更新时间</span>
          <span class="value">{{ lastUpdate }}</span>
        </div>
        
        <div class="info-item">
          <span class="label">数据来源</span>
          <span class="value">{{ dataSource }}</span>
        </div>
        
        <button class="refresh-btn" @click="$emit('refresh')" :disabled="refreshing">
          <span class="refresh-icon">🔄</span>
          <span class="refresh-text">AI 刷新</span>
        </button>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'Header',
  props: {
    lastUpdate: {
      type: String,
      default: '未更新'
    },
    dataSource: {
      type: String,
      default: '官方财报'
    },
    refreshing: {
      type: Boolean,
      default: false
    }
  },
  emits: ['refresh']
}
</script>

<style scoped>
.header {
  background: linear-gradient(135deg, rgba(30, 41, 59, 0.95) 0%, rgba(15, 23, 42, 0.95) 100%);
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  padding: 16px 24px;
  backdrop-filter: blur(10px);
  position: sticky;
  top: 0;
  z-index: 100;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1800px;
  margin: 0 auto;
}

.logo-section {
  display: flex;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  font-size: 32px;
}

.logo-text h1 {
  font-size: 20px;
  font-weight: 700;
  color: #f1f5f9;
  margin: 0;
  letter-spacing: -0.02em;
}

.subtitle {
  font-size: 12px;
  color: #64748b;
  margin: 2px 0 0 0;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 24px;
}

.info-item {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
}

.info-item .label {
  font-size: 11px;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.info-item .value {
  font-size: 14px;
  color: #e2e8f0;
  font-weight: 600;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}

.refresh-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(16, 185, 129, 0.4);
}

.refresh-btn:active {
  transform: translateY(0);
}

.refresh-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.refresh-icon {
  font-size: 16px;
}

.refresh-text {
  font-weight: 600;
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }
  
  .header-info {
    width: 100%;
    justify-content: space-between;
  }
  
  .logo-text h1 {
    font-size: 16px;
  }
}
</style>