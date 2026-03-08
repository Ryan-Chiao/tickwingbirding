#!/bin/bash
# Tickwing — GitHub 推送脚本
# 执行前请先在 GitHub 创建空仓库（不要勾选 Initialize this repository）
# 用法：bash doc/operations/push_to_github.sh <your-github-username>

set -e  # 任意命令失败即退出

GITHUB_USERNAME="${1}"

if [ -z "$GITHUB_USERNAME" ]; then
  echo "❌ 用法: bash doc/operations/push_to_github.sh <your-github-username>"
  echo "   例如: bash doc/operations/push_to_github.sh johndoe"
  exit 1
fi

REPO_NAME="tickwingbirding"
REMOTE_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo ""
echo "=========================================="
echo "  Tickwing — 推送到 GitHub"
echo "  仓库: ${REMOTE_URL}"
echo "=========================================="
echo ""

# 1. 检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "✅ 当前分支: ${CURRENT_BRANCH}"

# 2. 检查是否有未提交的变更
if [ -n "$(git status --porcelain)" ]; then
  echo "⚠️  检测到未提交的变更，请先提交后再推送："
  git status --short
  exit 1
fi

# 3. 添加 remote（如已存在则跳过）
if git remote get-url origin &>/dev/null; then
  echo "ℹ️  remote 'origin' 已存在: $(git remote get-url origin)"
  echo "   如需修改，请先执行: git remote set-url origin ${REMOTE_URL}"
else
  git remote add origin "${REMOTE_URL}"
  echo "✅ 已添加 remote origin: ${REMOTE_URL}"
fi

# 4. 推送 main 分支
echo ""
echo "📤 推送 main 分支..."
git push -u origin main
echo "✅ main 分支推送成功"

# 5. 推送 develop 分支
echo ""
echo "📤 推送 develop 分支..."
git push -u origin develop
echo "✅ develop 分支推送成功"

echo ""
echo "=========================================="
echo "  🎉 推送完成！"
echo ""
echo "  请在浏览器打开："
echo "  https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo ""
echo "  下一步：按照 DevOps 指引配置分支保护规则"
echo "  doc/operations/P0_DevOps_ExecutionReport.md"
echo "=========================================="
