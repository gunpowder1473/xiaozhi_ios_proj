---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "Android-XIAOZHI"
  tagline: android-xiaozhi 是一个基于Flutter的跨平台小智客户端，支持iOS、Android、Web等多平台
  actions:
    - theme: brand
      text: 开始使用
      link: /guide/00_文档目录
    - theme: alt
      text: 查看源码
      link: https://github.com/TOM88812/xiaozhi-android-client

features:
  - title: 跨平台支持
    details: 使用Flutter开发，一套代码支持iOS、Android、Web、Windows、macOS和Linux等多平台
  - title: 多AI模型集成
    details: 支持小智AI服务、Dify、OpenAI等多种AI服务，可随时切换不同模型
  - title: 丰富交互方式
    details: 支持实时语音对话、文字消息、图片消息，以及通话中手动打断功能
  - title: 语音优化技术
    details: 实现安卓设备AEC+NS回音消除，提升语音交互质量
  - title: 精美界面设计
    details: 轻度拟物化设计、流畅动画效果、自适应UI布局，提供更好的视觉体验
  - title: 灵活配置选项
    details: 支持多种AI服务配置管理，可添加多个小智到聊天列表
  - title: 实时语音识别
    details: 快速响应的语音识别系统，提供实时语音转文本功能
  - title: 多种服务提供商
    details: 支持官方小智服务、Dify、OpenAI等多个AI服务提供商
  - title: 持续对话模式
    details: 支持连续对话，保持交互的上下文连贯性
  - title: 本地优化
    details: 针对移动端优化的性能体验，减少电量消耗
  - title: 图文交互
    details: 支持图片和文本混合对话，提供多模态交互体验
  - title: 设备自动注册
    details: 支持OTA方式自动注册设备，简化配置过程
---

<div class="developers-section">
  <h2>👨‍💻 开发者</h2>
  <p>感谢以下开发者对 android-xiaozhi 作出的贡献</p>
  
  <div class="contributors-wrapper">
    <a href="https://github.com/TOM88812/xiaozhi-android-client/graphs/contributors" class="contributors-link">
      <img src="https://contrib.rocks/image?repo=TOM88812/xiaozhi-android-client&max=20&columns=10" alt="contributors" class="contributors-image"/>
    </a>
  </div>
  
  <div class="developers-actions">
    <a href="/android-xiaozhi/contributors" class="dev-button">查看特别贡献者</a>
    <a href="/android-xiaozhi/contributing" class="dev-button outline">如何参与贡献</a>
  </div>

  <div class="join-message">
    <h3>加入贡献者行列</h3>
    <p>我们欢迎更多的开发者参与到项目中来！查看<a href="/android-xiaozhi/contributing">贡献指南</a>了解如何参与贡献。</p>
  </div>

</div>

<style>
.developers-section {
  text-align: center;
  max-width: 960px;
  margin: 4rem auto 0;
  padding: 2rem;
  border-top: 1px solid var(--vp-c-divider);
}

.developers-section h2 {
  margin-bottom: 0.5rem;
  color: var(--vp-c-brand);
}

.contributors-wrapper {
  margin: 2rem auto;
  max-width: 600px;
  position: relative;
  overflow: hidden;
  border-radius: 10px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.contributors-wrapper:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.contributors-link {
  display: block;
  text-decoration: none;
  background-color: var(--vp-c-bg-soft);
}

.contributors-image {
  width: 100%;
  height: auto;
  display: block;
  transition: all 0.3s ease;
  max-height: 100px;
}

.developers-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-top: 1.5rem;
}

.developers-actions a {
  text-decoration: none;
}

.dev-button {
  display: inline-block;
  border-radius: 20px;
  padding: 0.5rem 1.5rem;
  font-weight: 500;
  transition: all 0.2s ease;
  text-decoration: none;
}

.dev-button:not(.outline) {
  background-color: var(--vp-c-brand);
  color: white;
}

.dev-button.outline {
  border: 1px solid var(--vp-c-brand);
  color: var(--vp-c-brand);
}

.dev-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

@media (max-width: 640px) {
  .developers-actions {
    flex-direction: column;
  }
  
  .contributors-wrapper {
    margin: 1.5rem auto;
  }
}

.join-message {
  text-align: center;
  margin-top: 2rem;
  padding: 2rem;
  border-top: 1px solid var(--vp-c-divider);
}

.join-message h3 {
  margin-bottom: 1rem;
}
</style>

