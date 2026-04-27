#!/usr/bin/env bash
# 收集代码统计信息（文件数、代码行数等）
# 用法: bash scripts/experiment/collect_stats.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "  代码统计: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 统计新增和修改的文件
echo ""
echo "--- Git 统计 ---"
NEW_FILES=$(git ls-files --others --exclude-standard | wc -l)
MODIFIED_FILES=$(git diff --name-only | wc -l)
DELETED_FILES=$(git diff --name-only --diff-filter=D | wc -l)

echo "新增文件: $NEW_FILES"
echo "修改文件: $MODIFIED_FILES"
echo "删除文件: $DELETED_FILES"

# 新增代码行数（不含空行）
if [ "$NEW_FILES" -gt 0 ]; then
    LINES_ADDED=$(git ls-files --others --exclude-standard | xargs cat 2>/dev/null | wc -l)
    echo "新增代码行数: $LINES_ADDED"
else
    LINES_ADDED=0
    echo "新增代码行数: 0"
fi

# 修改的代码行数（git diff 统计）
DIFF_ADDED=$(git diff --numstat | awk '{s+=$1} END {print s+0}')
DIFF_DELETED=$(git diff --numstat | awk '{s+=$2} END {print s+0}')
echo "修改区域新增: $DIFF_ADDED 行"
echo "修改区域删除: $DIFF_DELETED 行"

# 列出具体文件
if [ "$NEW_FILES" -gt 0 ]; then
    echo ""
    echo "--- 新增文件列表 ---"
    git ls-files --others --exclude-standard
fi

if [ "$MODIFIED_FILES" -gt 0 ]; then
    echo ""
    echo "--- 修改文件列表 ---"
    git diff --name-only
fi

# 覆盖率（如果有新测试文件的话）
echo ""
echo "--- 覆盖率 ---"
NEW_TEST_FILES=$(find tests/ -name "test_*.py" -newer scripts/experiment/ 2>/dev/null | wc -l || echo "0")
if [ "$NEW_TEST_FILES" -gt 0 ] || [ -n "$(find tests/ -name "test_*.py" -newer .git/HEAD 2>/dev/null)" ]; then
    COV_OUTPUT=$(python -m pytest --cov=app --cov-report=term-missing -q --no-cov-on-fail 2>&1 | tail -5) || true
    echo "$COV_OUTPUT"
else
    echo "未发现新测试文件，跳过覆盖率检查"
    COV_OUTPUT="N/A"
fi
