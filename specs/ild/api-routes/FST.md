# FST - Functional Specification: API Routes

## Core Capabilities

- **User Authentication**: Login with credentials, register new accounts with validation
- **User Management**: Retrieve and update current user profile
- **Profile Lookup**: View other users' public profiles with follow status
- **Follow System**: Follow/unfollow other users with self-follow prevention
- **Comment Management**: CRUD for article comments with author-only deletion
- **Tag Listing**: Return all available tags

## Inputs & Outputs

**Input**: JSON request bodies (UserInCreate, UserInLogin, UserInUpdate, CommentInCreate), path params (username, slug, comment_id)
**Output**: Wrapped response models (UserInResponse, ProfileInResponse, CommentInResponse, ListOfCommentsInResponse, TagsInList)
**Transformation**: Request body → validation → repository call → JWT generation (for auth) → response wrapper

## Side Effects

- **Modifies external state**: User registration, profile updates, comment creation/deletion, follow operations
- **Performs I/O**: Database reads/writes, JWT token generation

## Responsibilities

✅ Expose RESTful API endpoints matching RealWorld spec
✅ Validate request bodies via Pydantic schemas
✅ Inject repositories and current user via FastAPI DI
✅ Generate JWT tokens on login and user retrieval
❌ NOT responsible for business logic (delegated to services)
❌ NOT responsible for database queries (delegated to repositories)
❌ NOT responsibility for auth header parsing (delegated to dependencies)
