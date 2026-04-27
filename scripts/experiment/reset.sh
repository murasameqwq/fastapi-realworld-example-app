#!/usr/bin/env bash
# 重置代码到基线提交，清理所有未跟踪文件
# 用法: bash scripts/experiment/reset.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo ">>> 重置到基线提交..."
git checkout master
git reset --hard HEAD
git clean -fd

echo ">>> 清理 __pycache__ 和 .pytest_cache..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
rm -rf htmlcov/ .coverage coverage.xml

echo ">>> 验证基线测试通过..."
python -m pytest --no-cov -q 2>&1 | tail -5

echo ">>> 基线提交哈希: $(git rev-parse --short HEAD)"
echo ">>> 重置完成，可以开始实验。"
