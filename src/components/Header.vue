<template>
  <header class="header">
    <div class="header-left">
      <div class="logo">
        <span class="logo-icon">🌍</span>
        <div class="logo-text">
          <h1>南部非洲运营商财报洞察看板</h1>
          <p class="subtitle">Southern Africa Telecom Business Insight Dashboard</p>
        </div>
      </div>
    </div>
    
    <div class="header-right">
      <div class="update-info">
        <span class="label">数据版本：</span>
        <span class="value">{{ version }}</span>
        <span class="separator">|</span>
        <span class="label">更新时间：</span>
        <span class="value">{{ lastUpdate }}</span>
      </div>
      
      <button class="refresh-btn" @click="$emit('refresh')">
        <span class="icon">🔄</span>
        <span>AI 刷新</span>
      </button>
      
      <div class="actions">
        <button class="action-btn" title="复制链接">📋</button>
        <button class="action-btn" title="深色模式">🌙</button>
        <button class="action-btn" title="设置">⚙</button>
      </div>
    </div>
  </header>
</template>

<script>
export default {
  name: 'Header',
  props: {
    lastUpdate: String,
    version: String
  },
  emits: ['refresh']
}
</script>

<style scoped>
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 25px;
  background: rgba(0, 0, 0, 0.4);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
}

.header-left {
  display: flex;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 15px;
}

.logo-icon {
  font-size: 36px;
}

.logo-text h1 {
  font-size: 20px;
  font-weight: 600;
  color: #fff;
  margin-bottom: 2px;
}

.logo-text .subtitle {
  font-size: 11px;
  color: #888;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.update-info {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 13px;
  padding: 8px 15px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 20px;
}

.update-info .label {
  color: #888;
}

.update-info .value {
  color: #00d9ff;
  font-weight: 500;
}

.update-info .separator {
  color: #555;
  margin: 0 5px;
}

.refresh-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  border: none;
  border-radius: 20px;
  background: linear-gradient(135deg, #00d9ff 0%, #00b4d8 100%);
  color: #1a1a2e;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.refresh-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(0, 217, 255, 0.4);
}

.refresh-btn .icon {
  font-size: 16px;
}

.actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
  color: #e0e0e0;
  cursor: pointer;
  font-size: 16px;
  transition: all 0.3s ease;
}

.action-btn:hover {
  background: rgba(255, 255, 255, 0.2);
  transform: scale(1.1);
}

@media (max-width: 1024px) {
  .header {
    flex-direction: column;
    gap: 15px;
  }
  
  .header-right {
    flex-wrap: wrap;
    justify-content: center;
  }
}

@media (max-width: 768px) {
  .logo-text h1 {
    font-size: 16px;
  }
  
  .update-info {
    font-size: 11px;
    padding: 6px 10px;
  }
}
</style>