# OST - Operational Specification: API Routes

## Public Interfaces

### API Router (`api.py`)
Main route aggregator that mounts all sub-routers.

**Structure**:
- `router: APIRouter` - Central router mounting all sub-routers
- Includes: authentication (`/users`), users (`/user`), profiles (`/profiles`), articles, comments (`/articles/{slug}/comments`), tags (`/tags`)

### Authentication Router (`authentication.py`)
User login and registration endpoints.

**Routes**:
- `POST /api/users/login` → `UserInResponse` - Login with email/password
- `POST /api/users` → `UserInResponse` (201) - Register new user

### Users Router (`users.py`)
Current user management endpoints.

**Routes**:
- `GET /api/user` → `UserInResponse` - Get current authenticated user
- `PUT /api/user` → `UserInResponse` - Update current user profile

### Profiles Router (`profiles.py`)
User profile and follow endpoints.

**Routes**:
- `GET /api/profiles/{username}` → `ProfileInResponse` - Get user profile
- `POST /api/profiles/{username}/follow` → `ProfileInResponse` - Follow user
- `DELETE /api/profiles/{username}/follow` → `ProfileInResponse` - Unfollow user

### Comments Router (`comments.py`)
Article comment endpoints.

**Routes**:
- `GET /api/articles/{slug}/comments` → `ListOfCommentsInResponse` - List comments
- `POST /api/articles/{slug}/comments` → `CommentInResponse` (201) - Add comment
- `DELETE /api/articles/{slug}/comments/{comment_id}` → 204 - Delete comment

### Tags Router (`tags.py`)
Tag listing endpoint.

**Routes**:
- `GET /api/tags` → `TagsInList` - Get all tags

## Dependencies

**Internal**: `app.api.dependencies.*`, `app.db.repositories.*`, `app.models.schemas.*`, `app.services.*`, `app.core.settings`, `app.core.config`, `app.resources.strings`
**External**: FastAPI (APIRouter, Body, Depends, HTTPException)

## Exception Handling

- `HTTPException 400` - Invalid login input, duplicate username/email, self-follow, already favorited
- `HTTPException 403` - Wrong token prefix, user not author
- `HTTPException 404` - Entity not found (handled in dependency layer)

## Preconditions & Postconditions

**Preconditions**:
- All routes mounted under `/api` prefix configured in settings

**Postconditions**:
- Successful responses return wrapped objects: `{user: {...}}`, `{profile: {...}}`
- Write operations return 201 or 204 status codes
