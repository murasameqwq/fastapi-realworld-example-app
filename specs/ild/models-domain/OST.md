# OST - Operational Specification: Domain Models

## Public Interfaces

### RWModel
Base Pydantic model with camelCase alias, datetime encoding, and population by field name.

**Config**: `allow_population_by_field_name = True`, `json_encoders = {datetime: converter}`, `alias_generator = snake_to_camel`

### Article
Core article entity.

**Fields**: `slug`, `title`, `description`, `body`, `tags: List[str]`, `author: Profile`, `favorited: bool`, `favorites_count: int`
**Inherits**: IDModelMixin, DateTimeModelMixin, RWModel

### Comment
Comment entity on an article.

**Fields**: `body`, `author: Profile`
**Inherits**: IDModelMixin, DateTimeModelMixin, RWModel

### User
User account entity.

**Fields**: `username`, `email`, `bio: str = ""`, `image: Optional[str] = None`

### UserInDB
User with credential storage.

**Fields**: `salt`, `hashed_password`
**Methods**: `check_password(password) -> bool`, `change_password(password) -> None`

### Profile
Public-facing user profile.

**Fields**: `username`, `bio`, `image`, `following: bool = False`

## Dependencies

**Internal**: `app.models.common` (DateTimeModelMixin, IDModelMixin), `app.services.security`
**External**: pydantic (BaseModel, BaseConfig)

## Exception Handling

- No explicit exceptions; validation errors raised by pydantic for type mismatches

## Preconditions & Postconditions

**Preconditions**:
- Mixin fields (id, created_at, updated_at) are optional with defaults

**Postconditions**:
- All models serialize to camelCase JSON with Z-suffix datetimes
