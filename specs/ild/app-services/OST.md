# OST - Operational Specification: Services

## Public Interfaces

### Security Module
Password hashing and verification utilities.

**Key Functions**:
- `generate_salt() -> str` - Generate bcrypt salt
- `verify_password(plain_password, hashed_password) -> bool` - Check password match
- `get_password_hash(password) -> str` - Hash password with bcrypt

### JWT Module
Token creation and parsing.

**Key Functions**:
- `create_access_token_for_user(user, secret_key) -> str` - Create JWT with 7-day expiry
- `get_username_from_token(token, secret_key) -> str` - Extract username from JWT
- Constants: `JWT_SUBJECT = "access"`, `ALGORITHM = "HS256"`, `ACCESS_TOKEN_EXPIRE_MINUTES = 10080`

### Articles Service
Article-specific utility functions.

**Key Functions**:
- `check_article_exists(articles_repo, slug) -> bool` - Check if article exists by slug
- `get_slug_for_article(title) -> str` - Generate URL-safe slug from title
- `check_user_can_modify_article(article, user) -> bool` - Check authorship

### Authentication Service
Registration validation helpers.

**Key Functions**:
- `check_username_is_taken(repo, username) -> bool`
- `check_email_is_taken(repo, email) -> bool`

### Comments Service
Comment permission check.

**Key Functions**:
- `check_user_can_modify_comment(comment, user) -> bool`

## Dependencies

**Internal**: `app.db.repositories.*`, `app.db.errors`, `app.models.domain.*`, `app.models.schemas.jwt`
**External**: bcrypt, passlib, PyJWT, python-slugify

## Exception Handling

- `ValueError` raised by `get_username_from_token` on malformed JWT or invalid payload
- `EntityDoesNotExist` used as negative existence check pattern

## Preconditions & Postconditions

**Preconditions**:
- Secret key must be provided for JWT operations
- Repository must be initialized for existence checks

**Postconditions**:
- Password hashing produces unique salt per call
- JWT tokens contain username and expiration
