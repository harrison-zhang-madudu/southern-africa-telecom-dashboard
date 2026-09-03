<template>
  <div class="macro-news">
    <div class="section-header">
      <h3>🌍 宏观概览与新闻</h3>
      <div class="country-tabs">
        <button 
          v-for="country in countries" 
          :key="country.countryCode"
          :class="['tab', { active: selectedCountry === country.countryCode }]"
          @click="selectedCountry = country.countryCode"
        >
          {{ country.flag }} {{ country.country }}
        </button>
      </div>
    </div>
    
    <div class="macro-content">
      <!-- 宏观经济数据 -->
      <div class="macro-data" v-if="currentCountry">
        <h4>📊 经济指标</h4>
        <div class="indicators">
          <div class="indicator">
            <span class="label">GDP</span>
            <span class="value">{{ currentCountry.gdp.value }} {{ currentCountry.gdp.unit }}</span>
            <span class="sub">增长率: {{ currentCountry.gdp.growth }}%</span>
          </div>
          <div class="indicator">
            <span class="label">通胀率</span>
            <span :class="['value', getTrendClass(currentCountry.inflation.trend)]">
              {{ currentCountry.inflation.value }}%
            </span>
            <span class="sub">{{ getTrendLabel(currentCountry.inflation.trend) }}</span>
          </div>
          <div class="indicator">
            <span class="label">利率</span>
            <span class="value">{{ currentCountry.interestRate.value }}%</span>
            <span class="sub">{{ getTrendLabel(currentCountry.interestRate.trend) }}</span>
          </div>
          <div class="indicator">
            <span class="label">外汇储备</span>
            <span class="value">{{ currentCountry.fxReserves.value }} {{ currentCountry.fxReserves.unit }}</span>
            <span :class="['sub', currentCountry.fxReserves.change3M >= 0 ? 'positive' : 'negative']">
              3个月变化: {{ currentCountry.fxReserves.change3M >= 0 ? '+' : '' }}{{ currentCountry.fxReserves.change3M }}B
            </span>
          </div>
          <div class="indicator">
            <span class="label">失业率</span>
            <span class="value">{{ currentCountry.unemployment.value }}%</span>
            <span class="sub">{{ getTrendLabel(currentCountry.unemployment.trend) }}</span>
          </div>
          <div class="indicator">
            <span class="label">汇率 vs USD</span>
            <span class="value">{{ currentCountry.exchangeRateVsUSD }}</span>
            <span class="sub">1 {{ currentCountry.currency }} = {{ currentCountry.exchangeRateVsUSD }} USD</span>
          </div>
        </div>
      </div>
      
      <!-- 新闻列表 -->
      <div class="news-list">
        <h4>📰 相关新闻</h4>
        <div class="news-items">
          <div 
            v-for="news in filteredNews" 
            :key="news.date + news.title"
            :class="['news-item', `impact-${news.impact}`]"
          >
            <div class="news-header">
              <span class="news-date">{{ news.date }}</span>
              <span :class="['news-category', `cat-${news.category}`]">{{ news.category }}</span>
              <span :class="['impact-badge', news.impact]">{{ getImpactLabel(news.impact) }}</span>
            </div>
            <h5 class="news-title">{{ news.title }}</h5>
            <p class="news-summary">{{ news.summary }}</p>
            <div class="news-footer">
              <span class="news-source">来源: {{ news.source }}</span>
              <span class="news-relevance" v-if="news.relevance.length">
                相关: {{ news.relevance.join(', ') }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MacroNews',
  props: {
    macroData: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      selectedCountry: 'ZA'
    }
  },
  computed: {
    countries() {
      return this.macroData.countries || []
    },
    currentCountry() {
      return this.countries.find(c => c.countryCode === this.selectedCountry)
    },
    filteredNews() {
      const currentCountryName = this.currentCountry?.country
      return (this.macroData.news || [])
        .filter(n => n.country === currentCountryName)
        .slice(0, 5)
    }
  },
  methods: {
    getTrendClass(trend) {
      const classes = {
        'stable': '',
        'improving': 'positive',
        'declining': 'negative',
        'high': 'negative'
      }
      return classes[trend] || ''
    },
    getTrendLabel(trend) {
      const labels = {
        'stable': '稳定',
        'improving': '改善中',
        'declining': '下降中',
        'high': '偏高'
      }
      return labels[trend] || trend
    },
    getImpactLabel(impact) {
      const labels = {
        'positive': '利好',
        'negative': '利空',
        'neutral': '中性'
      }
      return labels[impact] || impact
    }
  }
}
</script>

<style scoped>
.macro-news {
  background: rgba(30, 41, 59, 0.8);
  border-radius: 16px;
  padding: 20px;
  margin: 20px 0;
}

.section-header {
  margin-bottom: 20px;
}

.section-header h3 {
  font-size: 20px;
  color: #e2e8f0;
  margin: 0 0 16px 0;
}

.country-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.tab {
  background: rgba(15, 23, 42, 0.6);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: #94a3b8;
  padding: 8px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  transition: all 0.2s;
}

.tab:hover {
  background: rgba(15, 23, 42, 0.8);
  color: #e2e8f0;
}

.tab.active {
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  color: white;
  border-color: #3b82f6;
}

.macro-content {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

@media (max-width: 1024px) {
  .macro-content {
    grid-template-columns: 1fr;
  }
}

.macro-data h4,
.news-list h4 {
  font-size: 16px;
  color: #e2e8f0;
  margin: 0 0 16px 0;
}

.indicators {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.indicator {
  background: rgba(15, 23, 42, 0.5);
  padding: 12px;
  border-radius: 8px;
}

.indicator .label {
  display: block;
  font-size: 11px;
  color: #64748b;
  margin-bottom: 4px;
}

.indicator .value {
  display: block;
  font-size: 16px;
  font-weight: 600;
  color: #e2e8f0;
}

.indicator .value.positive {
  color: #10b981;
}

.indicator .value.negative {
  color: #ef4444;
}

.indicator .sub {
  display: block;
  font-size: 11px;
  color: #475569;
  margin-top: 4px;
}

.indicator .sub.positive {
  color: #10b981;
}

.indicator .sub.negative {
  color: #ef4444;
}

.news-items {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.news-item {
  background: rgba(15, 23, 42, 0.5);
  padding: 14px;
  border-radius: 8px;
  border-left: 3px solid #64748b;
}

.news-item.impact-positive {
  border-left-color: #10b981;
}

.news-item.impact-negative {
  border-left-color: #ef4444;
}

.news-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.news-date {
  font-size: 11px;
  color: #475569;
}

.news-category {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
  background: rgba(100, 116, 139, 0.2);
  color: #94a3b8;
}

.impact-badge {
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 4px;
  font-weight: 600;
}

.impact-badge.positive {
  background: rgba(16, 185, 129, 0.2);
  color: #10b981;
}

.impact-badge.negative {
  background: rgba(239, 68, 68, 0.2);
  color: #ef4444;
}

.impact-badge.neutral {
  background: rgba(100, 116, 139, 0.2);
  color: #94a3b8;
}

.news-title {
  font-size: 14px;
  color: #e2e8f0;
  margin: 0 0 6px 0;
  font-weight: 600;
}

.news-summary {
  font-size: 12px;
  color: #94a3b8;
  margin: 0 0 8px 0;
  line-height: 1.5;
}

.news-footer {
  display: flex;
  justify-content: space-between;
  font-size: 10px;
  color: #475569;
}
</style>