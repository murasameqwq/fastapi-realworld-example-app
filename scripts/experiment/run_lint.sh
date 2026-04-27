#!/usr/bin/env bash
# 运行 lint 检查并收集结果
# 用法: bash scripts/experiment/run_lint.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "  Lint 检查: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# Black
echo ""
echo "--- black (格式化检查) ---"
BLACK_OUTPUT=$(python -m black --check app/ tests/ 2>&1) || true
echo "$BLACK_OUTPUT" | tail -5
BLACK_PASS=$(echo "$BLACK_OUTPUT" | grep -q "would be left unchanged" && echo "true" || echo "false")

# isort
echo ""
echo "--- isort (import 排序检查) ---"
ISORT_OUTPUT=$(python -m isort --check-only --diff app/ tests/ 2>&1) || true
echo "$ISORT_OUTPUT" | tail -5
ISORT_PASS=$(echo "$ISORT_OUTPUT" | grep -q "would be left unchanged" && echo "true" || echo "false")

# flake8
echo ""
echo "--- flake8 (风格检查) ---"
FLAKE_OUTPUT=$(python -m flake8 app/ tests/ 2>&1) || true
if [ -z "$FLAKE_OUTPUT" ]; then
    echo "flake8: 无错误"
    FLAKE_PASS="true"
    FLAKE_COUNT=0
else
    echo "$FLAKE_OUTPUT" | tail -10
    FLAKE_PASS="false"
    FLAKE_COUNT=$(echo "$FLAKE_OUTPUT" | wc -l)
fi

# mypy
echo ""
echo "--- mypy (类型检查) ---"
MYPY_OUTPUT=$(python -m mypy app/ 2>&1) || true
echo "$MYPY_OUTPUT" | tail -10
MYPY_PASS=$(echo "$MYPY_OUTPUT" | grep -q "Success: no issues found" && echo "true" || echo "false")

echo ""
echo "--- Lint 摘要 ---"
echo "black:  $BLACK_PASS"
echo "isort:  $ISORT_PASS"
echo "flake8: $FLAKE_PASS ($FLAKE_COUNT 个错误)"
echo "mypy:   $MYPY_PASS"
