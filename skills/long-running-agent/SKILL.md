---
name: long-running-agent
description: 长运行智能体开发系统，支持跨无限上下文窗口构建完整软件项目。当用户想要自主构建大型项目、运行长运行编码智能体、设置自动开发循环、逐个功能实现复杂应用，或提到 "长运行智能体"、"自主编码"、"自动开发"、"infinite dev"、"autopilot" 时使用此技能。也适用于用户项目中有 feature_list.json 或 claude-progress.md，或想要将大项目拆分为增量功能的情况。
version: 1.0.0
license: MIT
---

# 长运行智能体：跨上下文窗口的自主开发系统

基于 Anthropic [长运行智能体有效框架研究](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) 构建，支持跨无限上下文窗口开发完整软件项目。

## 架构

```
状态持久化（跨所有上下文窗口）：
  • features/feature_list.json — 功能清单，只改 passes 字段
  • progress/claude-progress.md — 结构化进度笔记
  • Git history — 代码变更记录

执行方式（用户二选一）：
  • 模式 A (交互式) — Claude 直接实现，/clear 清上下文
  • 模式 B (自动模式) — dev-agent.py run 启动 claude -p 子进程循环
```

## 自动设置

当此技能被触发时，Claude 必须自动将所需文件复制到项目目录：

1. 从本技能的 `scripts/` 目录复制 `dev-agent.py` 到项目的 `scripts/` 目录
2. 从本技能的 `templates/` 目录复制 `AGENTS.md` 到项目的 `templates/` 目录
3. 创建 `features/` 和 `progress/` 目录
4. 然后根据项目状态进入初始化模式或编码智能体模式

Claude 应动态解析技能路径（技能位于此 SKILL.md 所在的目录）。

## 初始化模式 — feature_list.json 不存在

Claude 自动执行以下步骤：

1. 读取项目规格（spec.md、app_spec.txt、README 或询问用户）
2. 生成 `features/feature_list.json`（20-200 个功能，按优先级排序）
3. 创建 `scripts/init.sh`（幂等环境设置脚本）
4. 初始化 git 仓库，首次提交
5. 搭建项目结构
6. 创建 `progress/claude-progress.md`
7. 询问用户：模式 A 还是模式 B？然后启动编码智能体模式

## 编码智能体模式 A：交互式

Claude 在当前会话内逐个实现功能，完成后用 `/clear` 清理上下文。

```
Claude 读 templates/AGENTS.md
  → scripts/init.sh → dev-agent.py status → dev-agent.py next
  → 实现功能 → lint → build → 浏览器测试
  → dev-agent.py complete → git commit → dev-agent.py log
  → 做了 2+ 个或上下文长了：
    "✅ 本轮完成 [N] 个功能（[passing]/[total]）。输入 /clear 后发送 go ahead 继续。"
  → 用户 /clear → go ahead
  → Claude 重新读 templates/AGENTS.md → 继续
```

| 优势 | 劣势 |
|------|------|
| 能看到每一步操作 | 需要偶尔 /clear + go ahead |
| MCP / Playwright 正常工作 | |
| 不需要 --dangerously-skip-permissions | |

## 编码智能体模式 B：自动模式

Claude 运行 `python3 scripts/dev-agent.py run`，脚本为每个功能启动独立 `claude -p` 子进程。

```
dev-agent.py run
  ├─ 读 feature_list.json → 找到 F003
  ├─ 启动 claude -p 子进程 → 实现 → 测试 → commit → 退出
  ├─ 读 feature_list.json → 找到 F004
  ├─ 启动 claude -p 子进程 → 实现 → 测试 → commit → 退出
  └─ 全部完成或达到限制 → 输出报告
```

| 优势 | 劣势 |
|------|------|
| 完全无人值守 | 需要 --dangerously-skip-permissions |
| 每个功能天然干净上下文 | MCP 可能不可用 |
| 不会上下文溢出 | 看不到实现过程 |

### 自动模式参数

| 参数 | 默认值 | 描述 |
|------|--------|------|
| `--model <name>` | CLI 默认模型 | 覆盖模型 |
| `--max-features N` | 0（不限） | 最多做 N 个功能 |
| `--max-turns N` | 150 | 每个功能最大工具调用轮数 |
| `--timeout N` | 1800 (30min) | 每个功能超时秒数 |
| `--delay N` | 3 | 功能之间间隔秒数 |

## dev-agent.py 命令

| 命令 | 描述 |
|------|------|
| `python3 scripts/dev-agent.py run` | 自动模式：每个功能一个 claude -p 子进程 |
| `python3 scripts/dev-agent.py run --parallel N` | 并行模式：同时跑 N 个功能（worktree 隔离）|
| `python3 scripts/dev-agent.py status` | 显示进度（passing/total/skipped + 最近笔记）|
| `python3 scripts/dev-agent.py next` | 显示下一个要做的功能（尊重优先级和依赖）|
| `python3 scripts/dev-agent.py find-parallel` | 显示可并行开发的独立功能列表 |
| `python3 scripts/dev-agent.py complete <id>` | 标记功能为通过 |
| `python3 scripts/dev-agent.py skip <id> [reason]` | 标记功能为跳过（记录原因）|
| `python3 scripts/dev-agent.py regression` | 随机选 1-2 个已通过功能做回归检查 |
| `python3 scripts/dev-agent.py log` | 追加进度到 claude-progress.md（支持结构化格式）|

## Feature List 格式

```json
{
  "project": "项目名称",
  "version": "1.0.0",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "critical",
      "description": "用户可以打开新聊天并发送消息",
      "steps": [
        "导航到主界面",
        "点击'新聊天'按钮",
        "在输入框输入消息",
        "按 Enter 或点击发送",
        "验证 AI 响应出现"
      ],
      "acceptance_criteria": [
        "消息成功发送",
        "AI 响应在 5 秒内出现"
      ],
      "dependencies": [],
      "passes": false
    }
  ]
}
```

规则：
- `priority`: critical > high > medium > low
- `category`: functional / ui / api / database / security / performance / accessibility / integration / error_handling / configuration
- `dependencies`: 依赖的功能 ID 列表，依赖未通过则跳过
- `passes`: `false` → `true`（通过）/ `"skipped"`（跳过）
- **永远不要**删除、修改描述、修改步骤、合并或重排功能

## 测试策略

### Web 应用
- Playwright MCP: `browser_navigate`, `browser_snapshot`, `browser_click`, `browser_type`, `browser_take_screenshot`
- 通过真实 UI 测试，不只是 curl 或单元测试
- 标记通过前运行 `npm run lint` 和 `npm run build`

### 非 Web 项目
- 对应测试框架：`pytest` / `jest` / `go test` / `cargo test`
- 标记通过前运行 linter（ruff/flake8/eslint）
- 写集成测试，从用户视角验证

### 通用
- 新功能开始前回归检查已通过的功能
- 发现回归先修，再做新功能
- **修复所有错误后再继续** — 不跳过失败的测试
- 只有 lint + build + 端到端验证全部通过才能标记 passes: true

## 团队模式（并行开发）

### 触发时机

在每完成一个功能后，检查是否适合开启并行：

```bash
python3 scripts/dev-agent.py find-parallel --count 3
```

如果满足以下条件，**主动询问用户**是否启用团队模式：
- 剩余未完成功能 >= 6
- 可并行的独立功能 >= 2
- 本次会话尚未询问过（避免反复打扰）

提示语：
> "检测到 N 个可并行开发的独立功能（剩余 M 个），是否启用团队模式并行开发？"

### 模式 A 下的团队模式

在当前 Claude 会话内使用 Agent tool + worktree 并行开发：

1. 运行 `python3 scripts/dev-agent.py find-parallel --count 3` 找到独立功能
2. 对每个功能用 Agent tool 启动 subagent（设置 `isolation: "worktree"`）
3. 各 subagent 在隔离 worktree 中实现 → 测试 → 提交
4. 合并分支，`python3 scripts/dev-agent.py complete <id>`
5. 清理 worktree

### 模式 B 下的团队模式

使用 `dev-agent.py run --parallel N`，脚本自动处理 worktree 创建/合并/清理：

```bash
python3 scripts/dev-agent.py run --parallel 3          # 同时跑 3 个功能
python3 scripts/dev-agent.py run --parallel 2 --max-features 6  # 并行 2，最多 6 个
```

并行执行流程：
1. `find_next_features(N)` 找到 N 个独立功能
2. 为每个功能创建 git worktree（`.worktrees/feature-<id>`）
3. 同时启动 N 个 `claude -p` 子进程（各在自己的 worktree 中）
4. 等待全部完成
5. 逐个合并回主分支（`git merge --no-ff`）
6. 清理 worktree + 删除分支
7. 重新加载 feature_list.json，继续下一批

合并冲突处理：保留主分支，skip 冲突的功能，记录原因。

适用于：50+ 功能待完成、功能之间独立、用户要求加速。