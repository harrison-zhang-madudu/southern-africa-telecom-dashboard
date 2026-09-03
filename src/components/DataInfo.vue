<template>
  <div class="data-info">
    <div class="info-header" @click="expanded = !expanded">
      <span class="info-icon">ℹ️</span>
      <span class="info-title">数据说明</span>
      <span class="expand-icon">{{ expanded ? '▲' : '▼' }}</span>
    </div>
    
    <div v-if="expanded" class="info-content">
      <div class="info-section">
        <h4>📊 数据周期</h4>
        <p>{{ metadata.dataPeriod.description }}</p>
        <p class="detail">数据覆盖：{{ metadata.dataPeriod.start }} 至 {{ metadata.dataPeriod.end }}</p>
      </div>
      
      <div class="info-section">
        <h4>💱 汇率信息</h4>
        <p class="detail" v-for="(rate, currency) in metadata.exchangeRates" :key="currency">
          {{ getCurrencyLabel(currency) }}：1 {{ currency.split('_')[0] }} = {{ rate.rate }} USD
          <span class="date">（{{ rate.date }}，{{ rate.source }}）</span>
        </p>
      </div>
      
      <div class="info-section">
        <h4>📅 财年说明</h4>
        <div class="fiscal-grid">
          <div v-for="(fy, operator) in metadata.fiscalYears" :key="operator" class="fiscal-item">
            <span class="operator-name">{{ operator }}</span>
            <span class="fiscal-detail">{{ fy.description }}</span>
          </div>
        </div>
      </div>
      
      <div class="info-section">
        <h4>🔄 更新时间</h4>
        <p class="update-time">{{ metadata.lastUpdatedSA }}</p>
        <p class="detail">看板版本：v{{ metadata.dashboardVersion }}</p>
      </div>
      
      <div class="info-section disclaimer">
        <h4>⚠️ 免责声明</h4>
        <p>{{ metadata.disclaimer }}</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DataInfo',
  props: {
    metadata: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      expanded: false
    }
  },
  methods: {
    getCurrencyLabel(currencyKey) {
      const labels = {
        'ZAR_USD': '南非兰特',
        'NGN_USD': '尼日利亚奈拉',
        'ZWL_USD': '津巴布韦元'
      }
      return labels[currencyKey] || currencyKey
    }
  }
}
</script>

<style scoped>
.data-info {
  background: rgba(30, 41, 59, 0.8);
  border-radius: 12px;
  padding: 16px;
  margin: 16px 0;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.info-header {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  user-select: none;
  padding: 8px 0;
}

.info-header:hover {
  opacity: 0.8;
}

.info-icon {
  font-size: 20px;
}

.info-title {
  font-size: 16px;
  font-weight: 600;
  color: #94a3b8;
  flex: 1;
}

.expand-icon {
  color: #64748b;
  font-size: 12px;
}

.info-content {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.info-section {
  margin-bottom: 20px;
}

.info-section:last-child {
  margin-bottom: 0;
}

.info-section h4 {
  font-size: 14px;
  color: #e2e8f0;
  margin: 0 0 8px 0;
  font-weight: 600;
}

.info-section p {
  font-size: 13px;
  color: #94a3b8;
  margin: 4px 0;
  line-height: 1.6;
}

.detail {
  font-size: 12px;
  color: #64748b;
}

.date {
  color: #475569;
}

.fiscal-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
}

.fiscal-item {
  background: rgba(15, 23, 42, 0.5);
  padding: 10px;
  border-radius: 8px;
}

.operator-name {
  display: block;
  font-weight: 600;
  color: #e2e8f0;
  font-size: 13px;
  margin-bottom: 4px;
}

.fiscal-detail {
  font-size: 11px;
  color: #64748b;
}

.update-time {
  font-weight: 600;
  color: #10b981 !important;
}

.disclaimer {
  background: rgba(234, 179, 8, 0.1);
  padding: 12px;
  border-radius: 8px;
  border-left: 3px solid #eab308;
}

.disclaimer h4 {
  color: #eab308;
}

.disclaimer p {
  font-size: 12px;
  color: #94a3b8;
}
</style>