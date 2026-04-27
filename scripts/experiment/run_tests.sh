#!/usr/bin/env bash
# 运行测试并收集结果
# 用法: bash scripts/experiment/run_tests.sh [feature_name]
# 如果传了 feature_name，会单独运行该 feature 的新测试文件

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

FEATURE="${1:-}"

echo "=========================================="
echo "  测试运行: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 运行全部测试
echo ""
echo "--- 全部测试 ---"
TEST_OUTPUT=$(python -m pytest --no-cov -x --tb=short 2>&1) || true
echo "$TEST_OUTPUT" | tail -10

# 解析通过/失败数
TOTAL=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= passed)' | head -1 || echo "0")
FAILED=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= failed)' | head -1 || echo "0")
ERRORS=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= error)' | head -1 || echo "0")

# 如果传了 feature，单独跑新测试
if [ -n "$FEATURE" ]; then
    TEST_FILE="tests/test_api/test_routes/test_${FEATURE}.py"
    if [ -f "$TEST_FILE" ]; then
        echo ""
        echo "--- 新功能测试 ($TEST_FILE) ---"
        NEW_OUTPUT=$(python -m pytest "$TEST_FILE" --no-cov -v --tb=short 2>&1) || true
        echo "$NEW_OUTPUT" | tail -15
        NEW_PASSED=$(echo "$NEW_OUTPUT" | grep -c "PASSED" || echo "0")
        NEW_FAILED=$(echo "$NEW_OUTPUT" | grep -c "FAILED" || echo "0")
    else
        echo ""
        echo "--- 新功能测试文件不存在: $TEST_FILE ---"
        NEW_PASSED=0
        NEW_FAILED=0
    fi
else
    NEW_PASSED="N/A"
    NEW_FAILED="N/A"
fi

# 输出结构化结果
echo ""
echo "--- 测试摘要 ---"
echo "全部测试通过: ${TOTAL:-0}"
echo "全部测试失败: ${FAILED:-0}"
echo "全部测试错误: ${ERRORS:-0}"
if [ -n "$FEATURE" ]; then
    echo "新测试通过: ${NEW_PASSED}"
    echo "新测试失败: ${NEW_FAILED}"
fi
