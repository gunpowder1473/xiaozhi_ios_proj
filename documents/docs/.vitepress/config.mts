import { defineConfig } from 'vitepress'
import { getGuideSideBarItems } from './guide'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ANDROID-XIAOZHI",
  description: "android-xiaozhi 是一个基于Flutter的跨平台小智客户端，支持iOS、Android、Web等多平台",
  base: '/xiaozhi-android-client/',
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: '主页', link: '/' },
      { text: '指南', link: '/guide/00_文档目录' },
      { text: '相关生态', link: '/ecosystem/' },
      { text: '贡献指南', link: '/contributing' },
      { text: '特殊贡献者', link: '/contributors' },
      { text: '赞助', link: '/sponsors/' }
    ],

    sidebar: {
      '/guide/': [
        {
          text: '指南',
          // 默认展开
          collapsed: false,
          items: getGuideSideBarItems(),
        }
      ],
      '/ecosystem/': [
        {
          text: '生态系统概览',
          link: '/ecosystem/'
        },
        {
          text: '相关项目',
          collapsed: false,
          items: [
            { text: '小智Python端', link: '/ecosystem/projects/py-xiaozhi/' },
            { text: 'xiaozhi-esp32-server', link: '/ecosystem/projects/xiaozhi-esp32-server/' }
          ]
        },
        // {
        //   text: '资源和支持',
        //   collapsed: true,
        //   items: [
        //     { text: '官方扩展和插件', link: '/ecosystem/resources/official-extensions/' },
        //     { text: '社区贡献', link: '/ecosystem/resources/community-contributions/' },
        //     { text: '兼容设备', link: '/ecosystem/resources/compatible-devices/' }
        //   ]
        // }
      ],
      // 赞助页面不显示侧边栏
      '/sponsors/': [],
      // 贡献指南页面不显示侧边栏
      '/contributing': [],
      // 贡献者名单页面不显示侧边栏
      '/contributors': [],
      // 系统架构页面不显示侧边栏
      '/architecture/': []
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/TOM88812/xiaozhi-android-client' }
    ]
  }
})
