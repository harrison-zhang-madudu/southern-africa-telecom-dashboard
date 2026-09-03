<template>
  <header class="dashboard-header">
    <div class="header-left">
      <div class="logo">
        <span class="logo-icon">📊</span>
        <div class="logo-text">
          <h1>南部非洲运营商洞察看板</h1>
          <span class="subtitle">Southern Africa Telecom Insights</span>
        </div>
      </div>
    </div>
    
    <div class="header-center">
      <div class="stats-quick">
        <div class="stat-item">
          <span class="stat-value">6</span>
          <span class="stat-label">运营商</span>
        </div>
        <div class="divider"></div>
        <div class="stat-item">
          <span class="stat-value">8</span>
          <span class="stat-label">核心指标</span>
        </div>
        <div class="divider"></div>
        <div class="stat-item">
          <span class="stat-value">4</span>
          <span class="stat-label">季度数据</span>
        </div>
      </div>
    </div>
    
    <div class="header-right">
      <div class="update-info">
        <span class="update-label">数据更新</span>
        <span class="update-time">{{ lastUpdate }}</span>
      </div>
      
      <div class="source-info">
        <span class="source-label">数据来源</span>
        <a :href="dataSource" target="_blank" class="source-link">
          官方财报
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
            <polyline points="15 3 21 3 21 9"></polyline>
            <line x1="10" y1="14" x2="21" y2="3"></line>
          </svg>
        </a>
      </div>
    </div>
  </header>
</template>

<script setup>
defineProps({
  lastUpdate: {
    type: String,
    default: '2026-09-03'
  },
  dataSource: {
    type: String,
    default: '#'
  }
})
</script>

<style scoped>
.dashboard-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px 24px;
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.95) 0%, rgba(30, 41, 59, 0.95) 100%);
  border-bottom: 1px solid rgba(148, 163, 184, 0.1);
  backdrop-filter: blur(10px);
}

.header-left {
  flex: 1;
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
  font-size: 18px;
  font-weight: 700;
  color: #f1f5f9;
  margin: 0;
  letter-spacing: -0.02em;
}

.subtitle {
  font-size: 11px;
  color: #64748b;
  letter-spacing: 0.02em;
}

.header-center {
  flex: 1;
  display: flex;
  justify-content: center;
}

.stats-quick {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 8px 20px;
  background: rgba(30, 41, 59, 0.5);
  border-radius: 8px;
  border: 1px solid rgba(148, 163, 184, 0.1);
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 2px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: #60a5fa;
}

.stat-label {
  font-size: 10px;
  color: #64748b;
}

.divider {
  width: 1px;
  height: 24px;
  background: rgba(148, 163, 184, 0.2);
}

.header-right {
  flex: 1;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 24px;
}

.update-info, .source-info {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 2px;
}

.update-label, .source-label {
  font-size: 10px;
  color: #64748b;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.update-time {
  font-size: 13px;
  font-weight: 500;
  color: #f1f5f9;
}

.source-link {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 13px;
  color: #60a5fa;
  text-decoration: none;
  transition: color 0.2s ease;
}

.source-link:hover {
  color: #93c5fd;
}

.source-link svg {
  width: 12px;
  height: 12px;
}

@media (max-width: 1024px) {
  .dashboard-header {
    flex-direction: column;
    gap: 16px;
  }
  
  .header-left, .header-center, .header-right {
    flex: none;
    width: 100%;
    justify-content: center;
  }
  
  .header-right {
    justify-content: center;
    gap: 32px;
  }
}
</style>