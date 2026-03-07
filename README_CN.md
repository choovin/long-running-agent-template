# 长运行智能体系统模板

一个生产就绪的项目模板，用于构建能够跨多个上下文窗口有效工作的 AI 智能体系统。基于 Anthropic 关于长运行智能体有效框架的研究实现。

## 核心概念

本模板实现了双组件解决方案：

1. **初始化智能体（Initializer Agent）** - 在首次运行时设置完整环境
2. **编码智能体（Coding Agent）** - 在每个会话中增量推进工作，同时留下清晰的产物

## 背景问题

当 AI 智能体变得越来越强大时，开发者开始让它们承担跨越数小时甚至数天的复杂任务。然而，让智能体在多个上下文窗口之间保持一致的进度仍然是一个开放性问题。

长运行智能体的核心挑战在于：它们必须在离散的会话中工作，而每个新会话开始时都没有之前的记忆。这就像一个软件项目由轮班工作的工程师团队负责，但每位新工程师到达时都不知道上一班发生了什么。

## 解决方案

根据 Anthropic 的研究，我们采用以下方案：

| 问题 | 解决方案 |
|------|----------|
| 智能体过早宣布项目完成 | 使用结构化 JSON 特性列表，包含明确的测试步骤 |
| 环境遗留 bug 或未记录的进度 | Git 提交 + 进度文件更新 |
| 特性被过早标记为完成 | 严格的自验证协议 |
| 智能体浪费时间搞清楚如何运行应用 | `init.sh` 脚本自动设置环境 |

## 项目结构

```
.
├── .agent/                    # 智能体配置和状态
│   ├── config.yaml           # 智能体配置
│   ├── prompts/              # 智能体提示词
│   │   ├── initializer.md    # 初始化会话提示词
│   │   └── coding.md         # 编码会话提示词
│   └── state/                # 运行时状态（git 忽略）
│       ├── session.json      # 当前会话信息
│       └── checkpoints/      # 会话检查点
├── features/                  # 特性管理
│   ├── feature_list.json     # 完整的特性需求列表
│   └── feature_schema.json   # JSON 模式定义
├── progress/                  # 进度追踪
│   ├── claude-progress.md    # 人类可读的进度日志
│   └── session_logs/         # 详细会话日志
├── scripts/                   # 自动化脚本
│   ├── init.sh               # 环境初始化
│   ├── start_dev.sh          # 启动开发服务器
│   ├── test_e2e.sh           # 端到端测试
│   └── checkpoint.sh         # 创建会话检查点
├── tests/                     # 测试套件
│   ├── e2e/                  # 端到端测试
│   ├── unit/                 # 单元测试
│   └── integration/          # 集成测试
├── src/                       # 源代码
├── docs/                      # 文档
│   ├── architecture.md       # 系统架构
│   ├── agent-workflow.md     # 智能体工作流指南
│   └── troubleshooting.md    # 常见问题解答
├── CLAUDE.md                  # Claude Code 指令文件
└── README.md                  # 项目说明
```

## 快速开始

### 1. 初始化项目

```bash
# 运行初始化脚本
./scripts/init.sh
```

### 2. 开始开发

编码智能体会：
1. 读取 git 日志和进度文件了解当前状态
2. 读取特性列表并选择下一个优先特性
3. 启动开发服务器并验证基本功能
4. 增量实现特性
5. 运行端到端测试
6. 提交带有描述性消息的进度
7. 更新进度文件

## 核心组件详解

### 特性列表 (`features/feature_list.json`)

特性列表是整个系统的核心，采用 JSON 格式（比 Markdown 更抗意外修改）：

```json
{
  "project": "项目名称",
  "version": "1.0.0",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "high",
      "description": "特性描述",
      "steps": [
        "步骤 1: 导航到 X",
        "步骤 2: 执行 Y",
        "步骤 3: 验证 Z"
      ],
      "acceptance_criteria": [
        "验收标准 1",
        "验收标准 2"
      ],
      "dependencies": ["F000"],
      "passes": false,
      "last_tested": null,
      "notes": ""
    }
  ]
}
```

**关键规则：**
- 生成 50-200+ 个特性用于复杂项目
- 每个特性应该是原子的、可测试的
- 所有特性初始状态为 `"passes": false`
- 包含正常路径和错误处理场景

### 进度文件 (`progress/claude-progress.md`)

追踪跨会话的所有工作：

```markdown
# 进度日志

## 会话 2024-01-15-001
- 开始时间: 2024-01-15 10:00
- 持续时间: 2 小时
- 工作特性: F001, F002
- 状态: F001 完成, F002 进行中
- 提交: abc123, def456
- 备注: 基础认证功能正常

## 会话 2024-01-16-001
...
```

### 初始化脚本 (`scripts/init.sh`)

设置完整的开发环境：
- 检查依赖项
- 创建环境配置
- 安装包依赖
- 初始化数据库（如需要）
- 设置 git 仓库

## 智能体工作流

### 会话开始

每个会话都从以下步骤开始：

```bash
# 1. 确认工作目录
pwd

# 2. 检查最近的 git 历史
git log --oneline -20

# 3. 读取进度文件
cat progress/claude-progress.md

# 4. 检查当前状态
git status

# 5. 读取特性列表
cat features/feature_list.json | jq '.features[] | select(.passes == false)'
```

### 环境验证

```bash
# 启动开发服务器
./scripts/start_dev.sh

# 运行冒烟测试
./scripts/test_e2e.sh --smoke
```

**关键：** 如果冒烟测试失败，**必须先修复现有 bug**，然后再开始新特性。

### 特性选择

1. 读取特性列表
2. 识别最高优先级的未完成特性
3. 考虑依赖关系
4. 宣布选择："我将工作于 **F00X: [特性描述]**"

### 特性实现

增量工作：
1. **计划**：将特性分解为小的、可测试的步骤
2. **编码**：一次实现一个步骤
3. **测试**：每个步骤后运行相关测试
4. **提交**：为工作状态创建小型、专注的提交

### 特性验证（必需）

在将特性标记为"通过"之前，必须：

1. **运行单元测试**
   ```bash
   npm test
   ```

2. **运行端到端测试**
   ```bash
   npm run test:e2e
   ```

3. **手动浏览器验证**
   - 使用浏览器自动化工具（Playwright）
   - 截取截图
   - 验证特性按用户预期工作

4. **检查回归**
   - 确保其他特性仍然工作
   - 运行完整测试套件

### 会话结束

```bash
# 1. 提交所有更改
git add -A
git commit -m "feat: 实现 F00X - [特性描述]

- 实现了什么
- 添加的测试
- 其他备注

Co-Authored-By: Claude <noreply@anthropic.com>"

# 2. 更新进度文件

# 3. 验证干净状态
git status  # 应该是干净的
npm test    # 应该通过
```

## 关键规则

### 必须做 ✅

- ✅ 每次只工作于**一个特性**
- ✅ 在标记特性为通过之前进行**充分测试**
- ✅ 频繁提交并带有**描述性消息**
- ✅ 每个会话更新**进度文件**
- ✅ 保持代码库处于**干净状态**
- ✅ 使用**浏览器自动化**进行端到端验证
- ✅ 开始工作前读取 **git 历史**
- ✅ **先修复 bug**，再实现新特性

### 禁止做 ❌

- ❌ 尝试同时实现多个特性
- ❌ 没有验证就标记特性为通过
- ❌ 留下失败的测试或损坏的代码
- ❌ 跳过定向阶段
- ❌ 修改特性列表结构（只更新 `passes` 字段）
- ❌ 删除或跳过测试
- ❌ 忽略失败的冒烟测试

## 测试策略

### 单元测试

```bash
npm test                    # 运行所有单元测试
npm test -- --watch        # 监视模式
npm test -- path/to/test   # 运行特定测试
```

### 端到端测试

```bash
./scripts/test_e2e.sh              # 运行所有 E2E 测试
./scripts/test_e2e.sh --smoke      # 只运行冒烟测试
./scripts/test_e2e.sh --feature F001  # 测试特定特性
```

### 浏览器自动化模板

```javascript
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto('http://localhost:3000');

  // 测试你的特性
  await page.fill('[data-testid="input"]', 'test');
  await page.click('[data-testid="submit"]');

  // 验证结果
  await page.waitForSelector('.success');

  // 截取截图用于验证
  await page.screenshot({ path: '/tmp/feature-test.png' });

  await browser.close();
})();
```

## 故障模式与解决方案

| 问题 | 初始化智能体行为 | 编码智能体行为 |
|------|------------------|----------------|
| 智能体过早宣布胜利 | 设置特性列表文件：基于输入规范创建结构化 JSON 文件 | 会话开始时读取特性列表，选择单个特性开始工作 |
| 环境遗留 bug 或未记录的进度 | 编写初始 git 仓库和进度文件 | 会话开始时读取进度文件和 git 日志，运行基本测试 |
| 特性被过早标记完成 | 设置特性列表文件 | 自验证所有特性，仅在仔细测试后标记为"通过" |
| 智能体浪费时间搞清楚如何运行应用 | 编写可运行开发服务器的 `init.sh` 脚本 | 会话开始时读取 `init.sh` |

## 配置

### 智能体配置 (`.agent/config.yaml`)

```yaml
agent:
  name: "long-running-coder"
  model: "claude-opus-4-5"
  max_context_tokens: 200000

session:
  max_duration: "4h"
  checkpoint_interval: "30m"

features:
  max_per_session: 3
  require_tests: true

testing:
  e2e_required: true
  browser_automation: true
  screenshot_on_failure: true
```

## 与 Claude Code 集成

本模板包含 `CLAUDE.md` 文件，其中包含让 Claude Code 自动遵循长运行智能体工作流的指令。

当使用 Claude Code 处理此项目时，它会自动：
1. 开始时运行定向命令
2. 验证环境状态
3. 从特性列表中选择下一个特性
4. 增量实现并测试
5. 提交进度并更新文档

## 最佳实践

1. **增量进度** - 一次一个特性
2. **干净状态** - 始终提交可工作的代码
3. **文档化** - 每个会话更新进度
4. **测试** - 完成前验证
5. **恢复** - 使用 git 回滚不良更改

## 扩展系统

### 添加新特性类别

编辑 `features/feature_schema.json` 在枚举中添加新类别。

### 自定义测试

在 `scripts/` 中添加自定义测试脚本，并在 `.agent/config.yaml` 中引用。

### 多智能体架构

系统可以扩展为使用专门的智能体：
- **测试智能体**：专注于测试
- **QA 智能体**：审查代码质量
- **文档智能体**：维护文档

## 示例会话

```
[会话开始]
> pwd
/home/project

> git log --oneline -5
abc123 feat: 实现用户认证
def456 feat: 添加数据库模型
...

> cat progress/claude-progress.md
[显示 F003 是下一个特性]

> ./scripts/start_dev.sh
服务器运行在端口 3000

> ./scripts/test_e2e.sh --smoke
✓ 所有冒烟测试通过

> "我将工作于 F003: 用户可以创建新项目"

[增量实现特性...]

> npm test
✓ 所有测试通过

> npm run test:e2e
✓ E2E 测试通过

[更新 feature_list.json: F003.passes = true]

> git add -A && git commit -m "feat: 实现项目创建 (F003)"
[abc789]

[更新进度文件...]

> git status
nothing to commit, clean working directory

[会话结束]
```

## 参考资料

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Claude 4 Prompting Guide](https://docs.anthropic.com/en/docs/prompting-guide)

## 许可证

MIT

---

> "一个好的会话会让代码库比发现时更干净。"
>
> - 干净的代码可以工作
> - 测试通过
> - 进度已文档化
> - 下一个智能体确切知道从哪里开始