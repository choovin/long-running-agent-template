#!/bin/bash
# 安装 long-running-agent 技能到 Claude Code

set -e

SKILL_NAME="long-running-agent"
SKILL_DIR="$HOME/.claude/skills/$SKILL_NAME"

echo "📦 安装 long-running-agent 技能..."

# 创建技能目录
mkdir -p "$SKILL_DIR"

# 确定脚本所在目录（技能源目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 复制技能文件
echo "  → 复制 SKILL.md"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/"

echo "  → 复制 scripts/"
mkdir -p "$SKILL_DIR/scripts"
cp "$SCRIPT_DIR/scripts/dev-agent.py" "$SKILL_DIR/scripts/"
chmod +x "$SKILL_DIR/scripts/dev-agent.py"

echo "  → 复制 templates/"
mkdir -p "$SKILL_DIR/templates"
cp "$SCRIPT_DIR/templates/AGENTS.md" "$SKILL_DIR/templates/"

# 验证安装
echo ""
echo "✅ 安装完成！"
echo ""
echo "安装位置: $SKILL_DIR"
echo ""
echo "文件列表:"
ls -la "$SKILL_DIR"
echo ""
echo "使用方法："
echo "  在 Claude Code 中说：'帮我用长运行智能体模式开发一个应用'"
echo ""