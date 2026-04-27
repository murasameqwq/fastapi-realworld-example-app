# 实验指南：PSP 工作流 vs Vibe Coding 对比实验

## 实验目标

对比 **PSP 规范驱动工作流（你的 skills）** 与 **纯 Vibe Coding** 在小规模功能开发上的效果差异。

## 实验任务：文章书签功能（Bookmarks）

**需求**：用户可以"收藏"（bookmark）文章以保存稍后阅读。与现有 favorites 的区别：
- bookmarks 是私人的（不像 favorites 有公开计数）
- 需要一个新的 `/api/articles/bookmarks` 端点，返回当前用户的书签列表

---

## 前置准备：生成 ReverseKit 文档（仅做一次）

```bash
# 1. 重置到干净的代码库
bash scripts/experiment/reset.sh

# 2. 在 Claude Code 中依次执行：
/reversekit-scan
# 等待完成后继续：
/reversekit-ild
# 等待完成
```

生成的文档存放在 `specs/` 目录下。**注意：生成完后不要提交，因为实验过程中会 `git reset`，需要用 `git stash` 保存这些文档，或者把 `specs/` 目录备份到项目外。**

推荐做法：
```bash
# 生成完 ReverseKit 后，把 docs 备份到项目外
cp -r specs /home/murasame/research/code2pspspec/experiment_data/bookmarks_baseline_specs/
```

每次实验开始前把 specs 复制回来：
```bash
cp -r /home/murasame/research/code2pspspec/experiment_data/bookmarks_baseline_specs/specs .
```

### 确认环境正常

```bash
bash scripts/experiment/reset.sh
cp -r /path/to/backup/specs .  # 恢复 ReverseKit 文档
# 应该看到所有测试通过
```

---

## 实验步骤

### 第一轮：PSP 工作流（实验组）

```bash
# 1. 重置代码到基线
bash scripts/experiment/reset.sh

# 2. 恢复 ReverseKit 文档（如果 reset 清除了）
cp -r /path/to/backup/specs .
```

然后在 **同一个 Claude Code 会话** 中，**依次**执行以下 skill 命令（每个完成后才能执行下一个）：

#### Step 1: 生成 Feature Spec

```
/dev.specify 添加文章书签功能：用户可以 bookmark 文章保存稍后阅读，需要支持添加/移除书签、查看个人书签列表。bookmarks 是私人的，不需要公开计数。
```

等待 skill 完成（它会创建 branch、生成 `specs/new-features/bookmarks/spec.md`、填写模板、做验证）。

#### Step 2: 生成实现计划

```
/dev.plan
```

等待 skill 完成（它会读取 spec.md + ReverseKit 文档，生成 `plan.md`）。

#### Step 3: 生成任务列表

```
/dev.tasks
```

等待 skill 完成（它会读取 spec.md + plan.md，生成 `tasks.md`）。

#### Step 4: 执行实现

```
/dev.implement
```

等待 skill 完成（它会按 tasks.md 逐步实现代码，包括测试）。

#### Step 5: 集成文档（可选）

```
/dev.integrate
```

这一步主要是更新 PSP 文档，可以跳过，不影响代码结果。

#### Step 6: 收集数据

实验完成后，在 Claude Code **外**（终端里）执行：

```bash
# 跑数据收集脚本
bash scripts/experiment/collect_all.sh run-001 psp bookmarks

# 记录 token 消耗（从 Claude Code 会话末尾的 usage 统计中复制）

# 保存代码用于后续评审
git stash push -m "PSP-bookmarks" -- .
```

### 第二轮：Vibe Coding（对照组）

```bash
# 1. 重置代码到基线
bash scripts/experiment/reset.sh

# 2. 恢复 ReverseKit 文档（保持一致性，对照组也可以看到）
cp -r /path/to/backup/specs .
```

然后在 Claude Code 中直接给出功能描述（不使用任何 skill）：

```
请为这个 FastAPI 项目实现"文章书签"功能。

功能需求：用户可以 bookmark 文章保存稍后阅读。
- 创建 bookmarks 表（user_id FK → users.id, article_id FK → articles.id, created_at）
- 实现 POST /api/articles/{slug}/bookmark 和 DELETE /api/articles/{slug}/bookmark
- 实现 GET /api/articles/bookmarks 返回当前用户的书签列表
- bookmarks 是私人的，不需要公开计数

规则：
1. 先写测试: tests/test_api/test_routes/test_bookmarks.py
2. 然后实现功能，遵循项目现有代码模式
3. 所有现有测试必须继续通过
4. 新功能测试需要覆盖 happy path 和至少 2 个错误场景

项目结构参考：
- API 路由: app/api/routes/    依赖注入: app/api/dependencies/
- 数据访问: app/db/repositories/    SQL 查询: app/db/queries/sql/
- 领域模型: app/models/domain/    API Schema: app/models/schemas/
- 业务逻辑: app/services/    数据库表: app/db/queries/tables.py
- 迁移: app/db/migrations/    错误字符串: app/resources/strings.py

使用 pytest 测试。项目使用 asyncpg, aiosql, pypika。
```

等待 Claude 自主完成全部工作后：

```bash
# 收集数据
bash scripts/experiment/collect_all.sh run-002 vibe bookmarks

# 记录 token 消耗

# 保存代码
git stash push -m "Vibe-bookmarks" -- .
```

---

## 评分阶段

### 人工评审

对比两个实现，按 1-5 分填写 `scripts/experiment/results/` 中对应 JSON 的 `subjective_human` 字段。

### LLM 评审

使用 `scripts/experiment/llm_judge_prompt.txt` 模板，将两个实现的代码填入，用第三方 LLM 独立评分。

---

## 快速参考

| 操作 | 命令 |
|------|------|
| 重置代码 | `bash scripts/experiment/reset.sh` |
| 跑测试 | `bash scripts/experiment/run_tests.sh bookmarks` |
| 跑 lint | `bash scripts/experiment/run_lint.sh` |
| 收集全部数据 | `bash scripts/experiment/collect_all.sh run-001 psp bookmarks` |
| 查看结果 | `cat scripts/experiment/results/run-001.json` |
