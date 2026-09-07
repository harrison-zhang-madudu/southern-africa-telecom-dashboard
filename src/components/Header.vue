<template>
  <header class="header">
    <div class="header-content">
      <div class="left-section">
        <!-- 侧边栏折叠按钮 -->
        <button class="collapse-btn" @click="$emit('toggleSidebar')">
          <span class="collapse-icon">{{ sidebarCollapsed ? '☰' : '✕' }}</span>
        </button>
        
        <div class="logo">
          <span class="logo-icon">📡</span>
          <div class="logo-text">
            <h1>南部非洲电信运营商洞察看板</h1>
            <p class="subtitle">Southern Africa Telecom Operators Insight Dashboard</p>
          </div>
        </div>
      </div>
      
      <!-- 视图切换 -->
      <div class="view-switcher">
        <button 
          :class="['view-btn', { active: currentView === 'overview' }]"
          @click="$emit('update:currentView', 'overview')"
        >
          <span class="view-icon">📊</span>
          <span class="view-text">总览</span>
        </button>
        <button 
          :class="['view-btn', { active: currentView === 'comparison' }]"
          @click="$emit('update:currentView', 'comparison')"
        >
          <span class="view-icon">⚖️</span>
          <span class="view-text">对比</span>
        </button>
        <button 
          :class="['view-btn', { active: currentView === 'detail' }]"
          @click="$emit('update:currentView', 'detail')"
        >
          <span class="view-icon">🔍</span>
          <span class="view-text">详情</span>
        </button>
      </div>
      
      <div class="header-info">
        <div class="info-item">
          <span class="label">更新时间</span>
          <span class="value">{{ lastUpdate }}</span>
        </div>
        
        <div class="info-item design-info">
          <span class="label">设计团队</span>
          <span class="value">南部非洲地区部售前财经团队</span>
          <span class="contact">接口人：张致超 00958183</span>
        </div>
        
        <button class="refresh-btn" @click="$emit('refresh')" :disabled="refreshing">
          <span class="refresh-icon" :class="{ spinning: refreshing }">🔄</span>
          <span class="refresh-text">{{ refreshing ? '刷新中...' : 'AI 刷新' }}</span>
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
    },
    currentView: {
      type: String,
      default: 'overview'
    },
    sidebarCollapsed: {
      type: Boolean,
      default: false
    }
  },
  emits: ['refresh', 'update:currentView', 'toggleSidebar']
}
</script>

<style scoped>
.header {
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.98) 0%, rgba(30, 41, 59, 0.95) 100%);
  border-bottom: 1px solid rgba(99, 102, 241, 0.2);
  padding: 12px 24px;
  backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  max-width: 1920px;
  margin: 0 auto;
  gap: 24px;
}

.left-section {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  width: 40px;
  height: 40px;
  border: 1px solid rgba(148, 163, 184, 0.2);
  border-radius: 10px;
  background: rgba(30, 41, 59, 0.6);
  color: #e2e8f0;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.collapse-btn:hover {
  background: rgba(99, 102, 241, 0.2);
  border-color: rgba(99, 102, 241, 0.5);
  transform: scale(1.05);
}

.collapse-icon {
  transition: transform 0.3s;
}

.logo {
  display: flex;
  align-items: center;
  gap: 12px;
}

.logo-icon {
  font-size: 28px;
  filter: drop-shadow(0 0 8px rgba(99, 102, 241, 0.5));
}

.logo-text h1 {
  font-size: 18px;
  font-weight: 700;
  background: linear-gradient(135deg, #f1f5f9 0%, #a5b4fc 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
  letter-spacing: -0.02em;
}

.subtitle {
  font-size: 11px;
  color: #64748b;
  margin: 2px 0 0 0;
  letter-spacing: 0.02em;
}

/* 视图切换 */
.view-switcher {
  display: flex;
  gap: 4px;
  background: rgba(15, 23, 42, 0.6);
  padding: 4px;
  border-radius: 12px;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.view-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border: none;
  border-radius: 8px;
  background: transparent;
  color: #94a3b8;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.view-btn:hover {
  background: rgba(99, 102, 241, 0.1);
  color: #e2e8f0;
}

.view-btn.active {
  background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%);
  color: white;
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
}

.view-icon {
  font-size: 14px;
}

.view-text {
  font-weight: 600;
}

.header-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.info-item {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
}

.info-item .label {
  font-size: 10px;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  font-weight: 600;
}

.info-item .value {
  font-size: 13px;
  color: #e2e8f0;
  font-weight: 600;
}

.design-info .contact {
  font-size: 10px;
  color: #94a3b8;
  margin-top: 1px;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  border: none;
  border-radius: 10px;
  color: white;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 4px 16px rgba(16, 185, 129, 0.4);
}

.refresh-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(16, 185, 129, 0.5);
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
  display: inline-block;
}

.refresh-icon.spinning {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

.refresh-text {
  font-weight: 600;
}

@media (max-width: 1200px) {
  .view-switcher {
    display: none;
  }
  
  .design-info {
    display: none;
  }
}

@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 12px;
  }
  
  .left-section {
    justify-content: space-between;
  }
  
  .header-info {
    justify-content: space-between;
  }
  
  .logo-text h1 {
    font-size: 14px;
  }
}
</style>