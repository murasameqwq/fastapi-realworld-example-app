# 实验记录：PSP 工作流 vs Vibe Coding

## 实验 1：文章书签功能（Bookmarks）

### 功能讨论

**背景**：项目已有 favorites 功能（公开计数，表示用户喜欢某篇文章），需要新增 bookmarks 功能（私人收藏，不公开）。

**需求**：
- 用户可以 bookmark 任意文章
- 可以移除已 bookmark 的文章
- 可以查看自己的书签列表（`GET /api/articles/bookmarks`）
- bookmarks 是私人的，其他人看不到，也没有公开计数

**需要新增的内容**：

| 层级 | 文件 | 说明 |
|------|------|------|
| 数据库迁移 | `app/db/migrations/versions/` | 新建 `bookmarks` 表（id, user_id FK → users.id, article_id FK → articles.id, created_at） |
| SQL 查询 | `app/db/queries/sql/bookmarks.sql` | add, remove, check, get-for-user |
| 表格映射 | `app/db/queries/tables.py` | 添加 `Bookmarks` TypedTable |
| Repository | `app/db/repositories/bookmarks.py` | CRUD 操作 |
| 领域模型 | `app/models/domain/bookmarks.py` | Bookmark 模型 |
| API Schema | `app/models/schemas/bookmarks.py` | 请求/响应 schema |
| API 路由 | `app/api/routes/bookmarks.py` | POST/DELETE `/articles/{slug}/bookmark` + GET `/articles/bookmarks` |
| 路由注册 | `app/api/routes/api.py` | 引入 bookmarks router |
| 错误字符串 | `app/resources/strings.py` | 错误消息常量 |
| 测试 | `tests/test_api/test_routes/test_bookmarks.py` | 已在分支上预先写好 |

---

### PSP 流程 Prompt

在 `experiment-bookmarks` 分支上预写好测试用例和 ReverseKit 文档后，按顺序执行：

```
/dev.specify 添加文章书签功能：用户可以 bookmark 文章保存稍后阅读，需要支持添加/移除书签、查看个人书签列表。bookmarks 是私人的，不需要公开计数。
```

```
/dev.plan
```

```
/dev.tasks
```

```
/dev.implement
```

（可选）

```
/dev.integrate
```

---

### Vibe Coding Prompt

```
请为这个 FastAPI 项目实现"文章书签"功能。

功能需求：用户可以 bookmark 文章保存稍后阅读。
- 使用 bookmarks 表（user_id FK → users.id, article_id FK → articles.id, created_at）
- 实现 POST /api/articles/{slug}/bookmark 和 DELETE /api/articles/{slug}/bookmark
- 实现 GET /api/articles/bookmarks 返回当前用户的书签列表
- bookmarks 是私人的，不需要公开计数

规则：
1. 遵循项目现有代码模式和惯例
2. 所有现有测试必须继续通过
3. 测试用例已在 tests/test_api/test_routes/test_bookmarks.py 中预写好，实现时需要确保这些测试全部通过

项目结构参考：
- API 路由: app/api/routes/    依赖注入: app/api/dependencies/
- 数据访问: app/db/repositories/    SQL 查询: app/db/queries/sql/
- 领域模型: app/models/domain/    API Schema: app/models/schemas/
- 业务逻辑: app/services/    数据库表: app/db/queries/tables.py
- 迁移: app/db/migrations/    错误字符串: app/resources/strings.py

使用 pytest 测试。项目使用 asyncpg, aiosql, pypika。
```

---

### 运行记录

| 运行 | 方法 | 日期 | Token 消耗 | 测试通过率 | 备注 |
|------|------|------|-----------|-----------|------|
|      |      |      |           |           |      |

### 评审结果

| 维度 | PSP 评分 | Vibe 评分 |
|------|---------|----------|
| 架构一致性（人工） | | |
| 可读性（人工） | | |
| 完整性（人工） | | |
| 错误处理（人工） | | |
| 测试质量（人工） | | |
| 架构一致性（LLM） | | |
| 可读性（LLM） | | |
| 完整性（LLM） | | |
| 错误处理（LLM） | | |
| 测试质量（LLM） | | |
