<template>
  <div class="stock-info">
    <div class="stock-header">
      <div class="stock-title">
        <span class="stock-symbol">{{ stock.symbol }}</span>
        <span class="stock-exchange">{{ stock.exchange }}</span>
      </div>
      <div class="stock-price">
        <span class="price">{{ formatPrice(stock.currentPrice) }}</span>
        <span class="currency">{{ stock.currency }}</span>
        <span :class="['change', stock.change1D >= 0 ? 'positive' : 'negative']">
          {{ stock.change1D >= 0 ? '+' : '' }}{{ stock.change1D.toFixed(2) }} 
          ({{ stock.change1D >= 0 ? '+' : '' }}{{ stock.change1DPercent.toFixed(2) }}%)
        </span>
      </div>
    </div>
    
    <div class="stock-details">
      <div class="detail-item">
        <span class="label">1周</span>
        <span :class="['value', stock.change1W >= 0 ? 'positive' : 'negative']">
          {{ stock.change1W >= 0 ? '+' : '' }}{{ stock.change1WPercent.toFixed(2) }}%
        </span>
      </div>
      <div class="detail-item">
        <span class="label">1月</span>
        <span :class="['value', stock.change1M >= 0 ? 'positive' : 'negative']">
          {{ stock.change1M >= 0 ? '+' : '' }}{{ stock.change1MPercent.toFixed(2) }}%
        </span>
      </div>
      <div class="detail-item">
        <span class="label">1年</span>
        <span :class="['value', stock.change1Y >= 0 ? 'positive' : 'negative']">
          {{ stock.change1Y >= 0 ? '+' : '' }}{{ stock.change1YPercent.toFixed(2) }}%
        </span>
      </div>
      <div class="detail-item">
        <span class="label">市值</span>
        <span class="value">{{ stock.marketCap }} {{ stock.marketCapCurrency }}</span>
      </div>
    </div>
    
    <div class="stock-footer">
      <span class="update-time">更新于：{{ stock.lastUpdated }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'StockInfo',
  props: {
    stock: {
      type: Object,
      required: true
    }
  },
  methods: {
    formatPrice(price) {
      if (price >= 1000) {
        return price.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
      }
      return price.toFixed(2)
    }
  }
}
</script>

<style scoped>
.stock-info {
  background: linear-gradient(135deg, rgba(30, 41, 59, 0.9) 0%, rgba(15, 23, 42, 0.9) 100%);
  border-radius: 12px;
  padding: 16px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.stock-header {
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.stock-title {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 8px;
}

.stock-symbol {
  font-size: 18px;
  font-weight: 700;
  color: #e2e8f0;
}

.stock-exchange {
  font-size: 12px;
  color: #64748b;
  background: rgba(100, 116, 139, 0.2);
  padding: 2px 8px;
  border-radius: 4px;
}

.stock-price {
  display: flex;
  align-items: baseline;
  gap: 8px;
  flex-wrap: wrap;
}

.price {
  font-size: 28px;
  font-weight: 700;
  color: #f1f5f9;
}

.currency {
  font-size: 14px;
  color: #94a3b8;
}

.change {
  font-size: 14px;
  font-weight: 600;
  padding: 4px 8px;
  border-radius: 6px;
}

.change.positive {
  color: #10b981;
  background: rgba(16, 185, 129, 0.1);
}

.change.negative {
  color: #ef4444;
  background: rgba(239, 68, 68, 0.1);
}

.stock-details {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-bottom: 12px;
}

.detail-item {
  text-align: center;
  padding: 8px;
  background: rgba(15, 23, 42, 0.5);
  border-radius: 8px;
}

.detail-item .label {
  display: block;
  font-size: 11px;
  color: #64748b;
  margin-bottom: 4px;
}

.detail-item .value {
  font-size: 13px;
  font-weight: 600;
  color: #e2e8f0;
}

.detail-item .value.positive {
  color: #10b981;
}

.detail-item .value.negative {
  color: #ef4444;
}

.stock-footer {
  text-align: right;
}

.update-time {
  font-size: 11px;
  color: #475569;
}

@media (max-width: 768px) {
  .stock-details {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>