<template>
  <div class="investor-links">
    <h4>📄 财报与投资者关系</h4>
    
    <div class="links-grid">
      <a 
        :href="ir.mainUrl" 
        target="_blank" 
        rel="noopener noreferrer"
        class="link-item main"
      >
        <span class="link-icon">🏢</span>
        <span class="link-text">投资者关系主页</span>
        <span class="link-arrow">→</span>
      </a>
      
      <a 
        :href="ir.annualReportsUrl" 
        target="_blank" 
        rel="noopener noreferrer"
        class="link-item reports"
      >
        <span class="link-icon">📊</span>
        <span class="link-text">年报下载</span>
        <span class="link-arrow">→</span>
      </a>
      
      <a 
        v-if="ir.latestReportUrl"
        :href="ir.latestReportUrl" 
        target="_blank" 
        rel="noopener noreferrer"
        class="link-item latest"
      >
        <span class="link-icon">🆕</span>
        <span class="link-text">{{ ir.latestReportType }}</span>
        <span class="link-date">{{ ir.latestReportDate }}</span>
        <span class="link-arrow">→</span>
      </a>
    </div>
    
    <div class="fiscal-info" v-if="fiscalYear">
      <span class="fiscal-label">财年信息：</span>
      <span class="fiscal-value">当前财年 {{ fiscalYear.currentFY }}，最新季度 {{ fiscalYear.latestQuarter }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InvestorLinks',
  props: {
    investorRelations: {
      type: Object,
      required: true
    },
    fiscalYear: {
      type: Object,
      default: null
    }
  },
  computed: {
    ir() {
      return this.investorRelations
    }
  }
}
</script>

<style scoped>
.investor-links {
  background: rgba(30, 41, 59, 0.8);
  border-radius: 12px;
  padding: 16px;
  margin: 16px 0;
}

.investor-links h4 {
  font-size: 16px;
  color: #e2e8f0;
  margin: 0 0 12px 0;
}

.links-grid {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.link-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: linear-gradient(135deg, rgba(15, 23, 42, 0.6) 0%, rgba(30, 41, 59, 0.6) 100%);
  border-radius: 8px;
  text-decoration: none;
  color: #e2e8f0;
  transition: all 0.2s;
  border: 1px solid rgba(255, 255, 255, 0.05);
}

.link-item:hover {
  background: linear-gradient(135deg, rgba(59, 130, 246, 0.2) 0%, rgba(30, 64, 175, 0.2) 100%);
  border-color: rgba(59, 130, 246, 0.3);
  transform: translateX(4px);
}

.link-icon {
  font-size: 18px;
}

.link-text {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.link-date {
  font-size: 11px;
  color: #64748b;
}

.link-arrow {
  color: #3b82f6;
  font-weight: 600;
  transition: transform 0.2s;
}

.link-item:hover .link-arrow {
  transform: translateX(4px);
}

.link-item.latest {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.15) 0%, rgba(6, 95, 70, 0.15) 100%);
  border-color: rgba(16, 185, 129, 0.2);
}

.link-item.latest:hover {
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.25) 0%, rgba(6, 95, 70, 0.25) 100%);
  border-color: rgba(16, 185, 129, 0.4);
}

.fiscal-info {
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  font-size: 12px;
}

.fiscal-label {
  color: #64748b;
}

.fiscal-value {
  color: #94a3b8;
}
</style>