#!/usr/bin/env bash
# 收集所有数据并保存为 JSON 结果文件
# 用法: bash scripts/experiment/collect_all.sh <run_id> <condition> <feature_name>
#   run_id: 如 "run-001"
#   condition: "psp" 或 "vibe"
#   feature_name: 如 "bookmarks"

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RESULTS_DIR="$PROJECT_ROOT/scripts/experiment/results"

RUN_ID="$1"
CONDITION="$2"
FEATURE="${3:-}"

echo "=========================================="
echo "  数据收集: $RUN_ID ($CONDITION)"
echo "=========================================="

# 1. 收集测试结果
TEST_OUTPUT=$(bash "$PROJECT_ROOT/scripts/experiment/run_tests.sh" "$FEATURE" 2>&1)
echo "$TEST_OUTPUT"

TOTAL_PASSED=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= passed)' | head -1 || echo "0")
TOTAL_FAILED=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= failed)' | head -1 || echo "0")
TOTAL_ERRORS=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= error)' | head -1 || echo "0")
ALL_TESTS_PASS="false"
if [ "$TOTAL_FAILED" = "0" ] && [ "$TOTAL_ERRORS" = "0" ] && [ "$TOTAL_PASSED" -gt 0 ]; then
    ALL_TESTS_PASS="true"
fi

if [ -n "$FEATURE" ]; then
    NEW_PASSED=$(echo "$TEST_OUTPUT" | grep -oP '新测试通过: \K\d+' || echo "0")
    NEW_FAILED=$(echo "$TEST_OUTPUT" | grep -oP '新测试失败: \K\d+' || echo "0")
    NEW_TESTS_TOTAL=$((NEW_PASSED + NEW_FAILED))
else
    NEW_PASSED=0
    NEW_FAILED=0
    NEW_TESTS_TOTAL=0
fi

# 2. 收集 lint 结果
LINT_OUTPUT=$(bash "$PROJECT_ROOT/scripts/experiment/run_lint.sh" 2>&1)

BLACK_PASS=$(echo "$LINT_OUTPUT" | grep -q "black:.*true" && echo "true" || echo "false")
ISORT_PASS=$(echo "$LINT_OUTPUT" | grep -q "isort:.*true" && echo "true" || echo "false")
FLAKE_PASS=$(echo "$LINT_OUTPUT" | grep -q "flake8:.*true" && echo "true" || echo "false")
MYPY_PASS=$(echo "$LINT_OUTPUT" | grep -q "mypy:.*true" && echo "true" || echo "false")
FLAKE_COUNT=$(echo "$LINT_OUTPUT" | grep -oP 'flake8:.*\(\K\d+' || echo "0")

# 3. 收集代码统计
STATS_OUTPUT=$(bash "$PROJECT_ROOT/scripts/experiment/collect_stats.sh" 2>&1)
echo "$STATS_OUTPUT"

NEW_FILES=$(echo "$STATS_OUTPUT" | grep -oP '新增文件: \K\d+' || echo "0")
MODIFIED_FILES=$(echo "$STATS_OUTPUT" | grep -oP '修改文件: \K\d+' || echo "0")
LINES_ADDED=$(echo "$STATS_OUTPUT" | grep -oP '新增代码行数: \K\d+' || echo "0")
DIFF_ADDED=$(echo "$STATS_OUTPUT" | grep -oP '修改区域新增: \K\d+' || echo "0")

# 4. 生成 JSON 结果
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
BASELINE_COMMIT=$(git rev-parse --short HEAD)

cat > "$RESULTS_DIR/${RUN_ID}.json" <<EOF
{
  "run_id": "$RUN_ID",
  "task": "$FEATURE",
  "condition": "$CONDITION",
  "timestamp": "$TIMESTAMP",
  "baseline_commit": "$BASELINE_COMMIT",

  "objective": {
    "all_tests_passing": $ALL_TESTS_PASS,
    "existing_tests_total": $((TOTAL_PASSED - NEW_TESTS_TOTAL)),
    "existing_tests_passed": "需手动验证",
    "new_tests_total": $NEW_TESTS_TOTAL,
    "new_tests_passed": $NEW_PASSED,
    "new_tests_failed": $NEW_FAILED,
    "input_tokens": "待填",
    "output_tokens": "待填",
    "total_tokens": "待填",
    "black_passed": $BLACK_PASS,
    "isort_passed": $ISORT_PASS,
    "flake8_passed": $BLACK_PASS,
    "flake8_errors": $FLAKE_COUNT,
    "mypy_passed": $MYPY_PASS,
    "coverage_percent": "待填"
  },

  "process": {
    "files_created": $NEW_FILES,
    "files_modified": $MODIFIED_FILES,
    "lines_added_source": $LINES_ADDED,
    "lines_in_diff": $DIFF_ADDED
  },

  "subjective_human": {
    "architectural_consistency": "待评",
    "readability": "待评",
    "completeness": "待评",
    "error_handling": "待评",
    "test_quality": "待评",
    "notes": ""
  },

  "subjective_llm": {
    "architectural_consistency": "待评",
    "readability": "待评",
    "completeness": "待评",
    "error_handling": "待评",
    "test_quality": "待评",
    "reasoning": ""
  }
}
EOF

echo ""
echo ">>> 结果已保存到: $RESULTS_DIR/${RUN_ID}.json"
echo ">>> 请手动填写: input_tokens, output_tokens, total_tokens, coverage_percent, subjective_* 字段"
