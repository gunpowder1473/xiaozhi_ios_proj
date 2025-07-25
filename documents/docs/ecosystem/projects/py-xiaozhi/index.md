---
title: 小智Python端
description: 使用Python实现的小智语音客户端，旨在通过代码学习和在没有硬件条件下体验AI小智的语音功能
---

# 小智Python客户端

<div class="project-header">
  <div class="project-badges">
    <span class="badge platform">跨平台</span>
    <span class="badge language">Python</span>
    <span class="badge status">稳定版本</span>
  </div>
</div>

## 项目简介

py-xiaozhi 是一个使用 Python 实现的小智语音客户端，旨在通过代码学习和在没有硬件条件下体验 AI 小智的语音功能。支持语音输入与识别，实现智能人机交互，提供自然流畅的对话体验。

<div class="app-showcase">
  <div class="showcase-description">
    <p>py-xiaozhi 提供了跨平台的小智语音交互体验，不仅支持GUI界面，还提供命令行模式，适用于各种环境。通过简单易用的接口和丰富的功能，让用户能够方便地与AI进行语音和文字交流。</p>
  </div>
</div>

## 核心功能

<div class="features-grid">
  <div class="feature-card">
    <div class="feature-icon">🗣️</div>
    <h3>AI语音交互</h3>
    <p>支持语音输入与识别，实现智能人机交互，提供自然流畅的对话体验</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">👁️</div>
    <h3>视觉多模态</h3>
    <p>支持图像识别和处理，提供多模态交互能力，理解图像内容</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🏠</div>
    <h3>IoT 设备集成</h3>
    <p>支持智能家居设备控制，实现更多物联网功能，打造智能家居生态</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🎵</div>
    <h3>联网音乐播放</h3>
    <p>基于pygame实现的高性能音乐播放器，支持歌词显示和本地缓存</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🔊</div>
    <h3>语音唤醒</h3>
    <p>支持唤醒词激活交互，免去手动操作的烦恼（默认关闭需要手动开启）</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💬</div>
    <h3>自动对话模式</h3>
    <p>实现连续对话体验，提升用户交互流畅度</p>
  </div>
</div>

## 功能亮点

### 图形化界面与命令行模式

<div class="feature-highlight">
  <div class="highlight-content">
    <h3>多种运行模式</h3>
    <ul>
      <li>提供直观易用的 GUI，支持小智表情与文本显示</li>
      <li>支持 CLI 运行，适用于嵌入式设备或无 GUI 环境</li>
      <li>跨平台支持，兼容 Windows 10+、macOS 10.15+ 和 Linux 系统</li>
      <li>统一的音量控制接口，适应不同环境需求</li>
    </ul>
  </div>
</div>

### 安全稳定的连接

<div class="feature-highlight reverse">
  <div class="highlight-content">
    <h3>优化的连接体验</h3>
    <ul>
      <li>支持 WSS 协议，保障音频数据的安全性</li>
      <li>首次使用时，程序自动复制验证码并打开浏览器</li>
      <li>自动获取 MAC 地址，避免地址冲突</li>
      <li>断线重连功能，保证连接稳定性</li>
      <li>跨平台兼容性优化</li>
    </ul>
  </div>
</div>

## 系统要求

- **Python**: 3.8+
- **操作系统**: Windows 10+, macOS 10.15+, Linux
- **依赖**: PyAudio, PyQt5, pygame, websocket-client等

## 安装与使用

### 安装方法

1. 克隆项目仓库:
```bash
git clone https://github.com/huangjunsen0406/py-xiaozhi.git
```

2. 安装依赖:
```bash
pip install -r requirements.txt
```

3. 运行应用:
```bash
python main.py
```

## 配置说明

客户端支持多种配置选项:

- 语音输入/输出设备选择
- 音量控制
- 唤醒词设置
- 服务器连接设置
- GUI/CLI模式切换

## 相关链接

- [项目GitHub仓库](https://github.com/huangjunsen0406/py-xiaozhi)
- [问题反馈](https://github.com/huangjunsen0406/py-xiaozhi/issues)

<style>
.project-header {
  display: flex;
  align-items: center;
  margin-bottom: 2rem;
}

.project-badges {
  display: flex;
  gap: 0.5rem;
}

.badge {
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
}

.badge.platform {
  background-color: #e6f7ff;
  color: #0070f3;
}

.badge.language {
  background-color: #f0f0f0;
  color: #333;
}

.badge.status {
  background-color: #d4edda;
  color: #155724;
}

.app-showcase {
  margin: 2rem 0;
  padding: 1.5rem;
  background-color: var(--vp-c-bg-soft);
  border-radius: 8px;
}

.showcase-description {
  font-size: 1.1rem;
  line-height: 1.6;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

.feature-card {
  padding: 1.5rem;
  border-radius: 8px;
  background-color: var(--vp-c-bg-soft);
  transition: all 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.feature-icon {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.feature-card h3 {
  margin-bottom: 0.5rem;
  color: var(--vp-c-brand);
}

.feature-highlight {
  display: flex;
  margin: 3rem 0;
  gap: 2rem;
  align-items: center;
}

.feature-highlight.reverse {
  flex-direction: row-reverse;
}

.highlight-content {
  flex: 1;
}

.highlight-content h3 {
  color: var(--vp-c-brand);
  margin-bottom: 1rem;
}

.highlight-content ul {
  padding-left: 1.5rem;
}

.highlight-content li {
  margin-bottom: 0.5rem;
}

@media (max-width: 768px) {
  .feature-highlight {
    flex-direction: column;
  }
  
  .feature-highlight.reverse {
    flex-direction: column;
  }
  
  .features-grid {
    grid-template-columns: 1fr;
  }
}
</style> 