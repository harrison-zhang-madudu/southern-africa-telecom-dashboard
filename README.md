# 南部非洲运营商财报洞察看板

Southern Africa Telecom Business Insight Dashboard

## 项目简介

这是一个基于 Vue3 + Vite + ECharts 构建的交互式财报分析看板，用于展示南部非洲区域主要运营商的财务指标分析和根因分析。

## 功能特性

### 核心功能
- ✅ **运营商筛选**：支持按运营商查看数据（MTN、Vodacom、Airtel、Econet、Telkom、Cell C）
- ✅ **指标筛选**：支持多指标组合筛选（收入增长、EBITDA利润率、ARPU等）
- ✅ **动态图表**：折线趋势图、仪表盘、雷达图
- ✅ **根因分析下钻**：点击指标查看详细根因分析
- ✅ **运营商对比**：雷达图对比、指标排名、对比表格

### 数据展示
- 预警与机会提示
- 核心指标仪表盘
- 季度趋势图表
- 根因分析（主要驱动因素、次要因素、风险与机会）

## 技术栈

- **前端框架**：Vue 3.4
- **构建工具**：Vite 5.0
- **图表库**：ECharts 5.5
- **样式**：原生 CSS（支持响应式）

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 本地开发

```bash
npm run dev
```

浏览器自动打开 http://localhost:5173

### 3. 构建生产版本

```bash
npm run build
```

构建产物在 `dist` 目录

### 4. 预览生产版本

```bash
npm run preview
```

## 部署到 GitHub Pages

### 方法一：手动部署

1. 创建 GitHub 仓库
2. 推送代码：
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/你的仓库名.git
git push -u origin main
```

3. 在 GitHub 仓库设置中启用 Pages：
   - Settings → Pages → Source → 选择 `main` 分支
   - 选择 `/dist` 目录（需要先构建并推送）

### 方法二：使用 GitHub Actions 自动部署

项目已包含 `.github/workflows/deploy.yml` 配置，推送代码后会自动构建部署。

## 项目结构

```
southern-africa-telecom-dashboard/
├── src/
│   ├── components/          # Vue组件
│   │   ├── Header.vue           # 头部
│   │   ├── OperatorFilter.vue   # 运营商筛选
│   │   ├── MetricFilter.vue     # 指标筛选
│   │   ├── OverviewDashboard.vue # 总览仪表盘
│   │   ├── ComparisonView.vue   # 运营商对比
│   │   ├── OperatorDetail.vue   # 运营商详情
│   │   ├── TrendChart.vue       # 趋势图表
│   │   ├── GaugeChart.vue       # 仪表盘图表
│   │   └── SingleTrendChart.vue # 单指标趋势图
│   ├── data/
│   │   └── telecom-data.json    # 数据文件
│   ├── App.vue              # 主应用组件
│   └── main.js              # 入口文件
├── public/
│   └── favicon.svg          # 网站图标
├── index.html               # HTML入口
├── package.json             # 依赖配置
└── vite.config.js           # Vite配置
```

## 数据更新

数据存储在 `src/data/telecom-data.json`，更新数据后：

1. 本地开发环境会自动热更新
2. 生产环境需要重新构建：`npm run build`

## 运营商覆盖

| 运营商 | 国家 | 区域 |
|-------|------|------|
| MTN Group | 南非 | Southern Africa |
| Vodacom Group | 南非 | Southern Africa |
| Airtel Africa | 尼日利亚 | West Africa |
| Econet Global | 津巴布韦 | Southern Africa |
| Telkom SA | 南非 | Southern Africa |
| Cell C | 南非 | Southern Africa |

## 指标体系

| 类别 | 指标 | 说明 |
|-----|------|------|
| 增长性 | 收入增长率 | 季度收入同比增长 |
| 增长性 | 订户增长率 | 订户数季度同比增长 |
| 盈利能力 | EBITDA利润率 | EBITDA占收入比例 |
| 运营效率 | ARPU | 每用户平均收入 |
| 运营效率 | 流失率 | 用户月度流失率 |
| 投资 | 资本开支比 | 资本开支占收入比例 |
| 财务健康 | 负债率 | 总负债/总资产 |
| 财务健康 | 自由现金流 | 经营现金流减资本开支 |

## 后续扩展

- [ ] 接入真实财报数据源（PDF解析）
- [ ] 添加更多运营商
- [ ] 实现数据自动刷新
- [ ] 添加用户权限控制
- [ ] 移动端适配优化

## 版本信息

- 版本：v1.0
- 更新时间：2026-09-03
- 数据来源：各运营商官方财报

## 联系方式

如有问题或建议，请联系项目维护人。
