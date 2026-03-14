# 长运行智能体系统

[English](README.md) | 中文

一个生产就绪的项目模板和 Claude Code 技能，用于构建能够跨多个上下文窗口有效工作的 AI 智能体系统。基于 Anthropic 关于长运行智能体有效框架的研究实现。

## 安装为 Claude Code 技能

### 方法一：手动安装

1. **克隆或下载本项目**
   ```bash
   git clone <your-repo-url>
   cd long-running-agent-template
   ```

2. **复制技能到 Claude Code 配置目录**
   ```bash
   # 创建技能目录（如果不存在）
   mkdir -p ~/.claude/skills

   # 复制技能文件夹
   cp -r skills/long-running-agent ~/.claude/skills/
   ```

3. **验证安装**
   ```bash
   ls ~/.claude/skills/long-running-agent/
   # 应该看到: SKILL.md  scripts/  templates/
   ```

4. **重启 Claude Code 或开始新会话**

### 方法二：使用符号链接（推荐用于开发）

```bash
# 创建技能目录
mkdir -p ~/.claude/skills

# 创建符号链接
ln -s $(pwd)/skills/long-running-agent ~/.claude/skills/long-running-agent
```

### 验证技能已加载

在 Claude Code 中发送以下消息：

```
帮我演示长运行智能体技能
```

如果技能正确安装，Claude 会自动加载并使用此技能。

---

## 功能特性

- **项目模板**：完整的项目结构，包含功能管理、进度追踪和测试基础设施
- **CLI 自动化**：`dev-agent.py` 工具用于命令行管理工作流
- **双执行模式**：
  - **模式 A（交互式）**：Claude 直接实现功能，更好的可见性，MCP 工具可用
  - **模式 B（自动模式）**：完全自主执行，支持并行开发
- **团队模式**：使用 git worktree 隔离的并行开发
- **YAML 配置**：通过 `.agent/config.yaml` 灵活配置智能体
- **完整测试框架**：单元测试、E2E 测试和浏览器自动化

## 快速开始

### 方式一：作为技能使用（推荐）

安装技能后，只需在 Claude Code 中说：

```
我想开发一个待办事项应用，帮我用长运行智能体模式构建
```

或者：

```
用自动开发模式帮我实现这个项目的所有功能
```

Claude 会自动：
1. 将必要的文件复制到你的项目
2. 生成功能列表（feature_list.json）
3. 创建进度追踪文件
4. 询问你选择哪种模式（交互式/自动）
5. 开始逐个实现功能

### 方式二：作为模板使用

如果你想从头开始一个新项目：

```bash
# 复制模板
cp -r long-running-agent-template my-project
cd my-project

# 初始化
./scripts/init.sh
```

然后启动 Claude Code：

```
开始开发这个项目
```

---

## 使用指南

### 模式 A：交互式（推荐新手）

```bash
# 1. 检查状态
python3 scripts/dev-agent.py status

# 2. 获取下一个功能
python3 scripts/dev-agent.py next

# 3. 实现、测试后标记完成
python3 scripts/dev-agent.py complete F001

# 4. 记录进度
python3 scripts/dev-agent.py log --feature-id F001 --done "- 实现了登录表单" --testing "- E2E 测试通过"
```

### 模式 B：自动模式

```bash
# 启动自主开发循环
python3 scripts/dev-agent.py run

# 带参数运行
python3 scripts/dev-agent.py run --max-features 10    # 最多 10 个功能
python3 scripts/dev-agent.py run --parallel 3         # 并行 3 个
python3 scripts/dev-agent.py run --timeout 3600       # 每个功能 1 小时
```

### 团队模式（并行开发）

```bash
# 检查可并行的功能
python3 scripts/dev-agent.py find-parallel

# 并行运行
python3 scripts/dev-agent.py run --parallel 3
```

---

## CLI 命令参考

| 命令 | 描述 |
|------|------|
| `python3 scripts/dev-agent.py status` | 显示进度摘要 |
| `python3 scripts/dev-agent.py next` | 获取下一个待实现功能 |
| `python3 scripts/dev-agent.py find-parallel` | 显示可并行开发的功能 |
| `python3 scripts/dev-agent.py complete <id>` | 标记功能为通过 |
| `python3 scripts/dev-agent.py skip <id> "原因"` | 跳过功能 |
| `python3 scripts/dev-agent.py regression` | 选择功能进行回归测试 |
| `python3 scripts/dev-agent.py log ...` | 记录结构化进度 |
| `python3 scripts/dev-agent.py run` | 启动自主循环 |
| `python3 scripts/dev-agent.py run --parallel N` | 并行执行 |

---

## 项目结构

```
.
├── .agent/                    # 智能体配置和状态
│   ├── config.yaml           # 智能体配置
│   └── prompts/              # 智能体提示词
├── features/                  # 功能管理
│   ├── feature_list.json     # 完整的功能需求列表
│   └── feature_schema.json   # JSON 模式定义
├── progress/                  # 进度追踪
│   └── claude-progress.md    # 人类可读的进度日志
├── scripts/                   # 自动化脚本
│   ├── dev-agent.py          # CLI 工作流管理工具
│   ├── init.sh               # 环境初始化
│   ├── start_dev.sh          # 启动开发服务器
│   └── test_e2e.sh           # 端到端测试
├── templates/                 # 工作流模板
│   └── AGENTS.md             # 智能体工作流模板
├── skills/                    # Claude Code 技能定义
│   └── long-running-agent/   # 本技能
│       ├── SKILL.md          # 技能主文件
│       ├── scripts/          # 技能脚本
│       └── templates/        # 技能模板
├── tests/                     # 测试套件
│   ├── e2e/                  # 端到端测试
│   ├── unit/                 # 单元测试
│   └── integration/          # 集成测试
├── src/                       # 源代码
├── docs/                      # 文档
├── CLAUDE.md                  # Claude Code 指令文件
└── README.md                  # 项目说明
```

---

## 功能列表格式

```json
{
  "project": "项目名称",
  "version": "1.0.0",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "critical",
      "description": "用户可以登录系统",
      "steps": [
        "导航到登录页面",
        "输入邮箱和密码",
        "点击登录按钮",
        "验证跳转到首页"
      ],
      "acceptance_criteria": [
        "有效凭证成功登录",
        "无效凭证显示错误"
      ],
      "dependencies": [],
      "passes": false,
      "last_tested": null,
      "skip_reason": null
    }
  ]
}
```

---

## 配置文件

编辑 `.agent/config.yaml` 自定义行为：

```yaml
agent:
  model: "claude-opus-4-5"
  max_context_tokens: 200000

execution:
  mode: "interactive"  # interactive | autopilot
  max_turns_per_feature: 150
  timeout_per_feature: 1800

team_mode:
  enabled: false
  max_parallel: 3

testing:
  e2e_required: true
  browser_automation: true
```

---

## 关键规则

### 必须做

- 每次只工作于**一个功能**
- 在标记功能为通过之前进行**充分测试**
- 频繁提交并带有**描述性消息**
- 每个会话更新**进度文件**
- 保持代码库处于**干净状态**
- 使用**浏览器自动化**进行端到端验证
- 开始工作前读取 **git 历史**
- **先修复 bug**，再实现新功能

### 禁止做

- 尝试同时实现多个功能
- 没有验证就标记功能为通过
- 留下失败的测试或损坏的代码
- 跳过定向阶段
- 修改功能列表结构（只更新 `passes` 字段）
- 删除或跳过测试
- 忽略失败的冒烟测试

---

## 故障模式与解决方案

| 问题 | 解决方案 |
|------|----------|
| 智能体过早宣布胜利 | 使用结构化 JSON 功能列表，包含明确的测试步骤 |
| 环境遗留 bug 或未记录的进度 | Git 提交 + 进度文件更新 |
| 功能被过早标记为完成 | 严格的自验证协议 |
| 智能体浪费时间搞清楚如何运行应用 | `init.sh` 脚本自动设置环境 |

---

## 示例会话

```
═══════════════════════════════════════════════════════════════════
会话开始 - 模式 A（交互式）
═══════════════════════════════════════════════════════════════════

[Claude] 我将开始了解当前状态。

$ python3 scripts/dev-agent.py status
项目: 我的待办应用
进度: 4/25 通过 (16.0%)
剩余: 21

$ python3 scripts/dev-agent.py next
下一个功能: F005 (优先级 critical)
描述: 用户可以登录系统
类别: functional

步骤:
  1. 导航到 /login
  2. 输入注册邮箱
  3. 输入正确密码
  4. 点击登录按钮
  5. 验证跳转到首页

[Claude] 我将实现 F005: 用户登录功能。

[... 实现过程 ...]

$ npm test
✓ 所有单元测试通过

$ npm run test:e2e
✓ E2E 测试通过

[Claude] 功能 F005 完成。

$ python3 scripts/dev-agent.py complete F005
✓ 功能 F005 标记为通过 (5/25)

$ git add -A && git commit -m "feat: 实现用户登录 (F005)"
[xyz789]

$ python3 scripts/dev-agent.py log --feature-id F005 --done "- 添加登录表单、验证、API 端点" --testing "- 单元测试、E2E 测试、浏览器验证" --notes "- 会话令牌 24 小时后过期"
已记录到 progress/claude-progress.md

═══════════════════════════════════════════════════════════════════
会话结束
═══════════════════════════════════════════════════════════════════

摘要:
- 功能: F005 (完成)
- 提交: xyz789
- 测试: 全部通过
- 进度: 5/25
- 下一个: F006 (用户登出)
```

---

## 与 Claude Code 集成

本模板包含 `CLAUDE.md` 文件，其中包含让 Claude Code 自动遵循长运行智能体工作流的指令。

当使用 Claude Code 处理此项目时，它会自动：
1. 开始时运行定向命令
2. 验证环境状态
3. 从功能列表中选择下一个功能
4. 增量实现并测试
5. 提交进度并更新文档

---

## 参考资料

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Claude 4 Prompting Guide](https://docs.anthropic.com/en/docs/prompting-guide)

---

## 许可证

MIT

---

> "一个好的会话会让代码库比发现时更干净。"
>
> - 干净的代码可以工作
> - 测试通过
> - 进度已文档化
> - 下一个智能体确切知道从哪里开始