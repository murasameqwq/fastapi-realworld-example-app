# FST - Functional Specification: Conduit (RealWorld API)

## System Purpose

Conduit is a full-featured blogging platform backend (Medium clone) implementing the RealWorld API specification. It provides a complete REST API for content creation, social interaction, and user management. The system serves as a reference implementation demonstrating FastAPI best practices with clean architecture patterns.

**Target Users**:
- **API Consumers**: Frontend applications (web, mobile) that consume the REST API
- **Developers**: Engineers studying FastAPI architecture, async patterns, and layered design
- **RealWorld Evaluators**: Teams comparing framework implementations against the RealWorld benchmark

**Value Proposition**: A production-quality, well-architected backend that handles all RealWorld API endpoints with async I/O, typed models, and clear separation of concerns.

## System Capabilities

1. **User Account Management**: Registration, login, profile retrieval and update with JWT-based authentication
2. **Content Publishing**: Article creation, editing, deletion with automatic URL-safe slug generation and tag association
3. **Social Discovery**: User profile viewing, follow/unfollow relationships, article feed from followed authors
4. **Engagement**: Article commenting, article favoriting with count tracking
5. **Content Discovery**: Article listing with filtering by tag, author, or favorited status, with pagination

## Use Cases

### UC1: User Registration and Authentication
1. Client sends POST to `/api/users` with username, email, password
2. System validates input, checks uniqueness, creates user with hashed password
3. System issues JWT token; client stores token for subsequent requests
4. Client authenticates via POST to `/api/users/login` with email/password
5. System verifies password, issues new JWT token

### UC2: Article Publishing
1. Authenticated user sends POST to `/api/articles` with title, description, body, tags
2. System generates URL-safe slug from title, checks for duplicates
3. System creates article, auto-creates missing tags, links article to tags
4. System returns article with author profile, tag list, and metadata
5. Other users retrieve the article via GET `/api/articles/{slug}`

### UC3: Social Feed
1. Authenticated user follows other users via POST `/api/profiles/{username}/follow`
2. System records follow relationship in database
3. User retrieves personalized feed via GET `/api/articles/feed`
4. System returns articles from followed authors, paginated

### UC4: Content Discovery
1. Client sends GET to `/api/articles` with optional filters (tag, author, favorited)
2. System builds dynamic SQL query with specified filters
3. System returns paginated articles with author profiles, tags, and favorite counts
4. Client can retrieve all available tags via GET `/api/tags`

### UC5: Engagement
1. Authenticated user favorites an article via POST `/api/articles/{slug}/favorite`
2. System records favorite, increments count, returns updated article
3. User adds comments to articles via POST `/api/articles/{slug}/comments`
4. Comments are associated with the article and author profile

## Functional Requirements

| ID | Requirement |
|----|-------------|
| FR1 | The system SHALL allow users to register accounts with unique username and email |
| FR2 | The system SHALL authenticate users via JWT tokens with 7-day expiry |
| FR3 | The system SHALL allow authenticated users to create, update, and delete articles |
| FR4 | The system SHALL allow users to follow and unfollow other users |
| FR5 | The system SHALL return articles filterable by tag, author, and favorited status with pagination |

## Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR1 | All API responses SHALL follow the RealWorld JSON format with camelCase field names |
| NFR2 | Passwords SHALL be hashed with bcrypt using per-user salts |
| NFR3 | The system SHALL handle concurrent requests via async I/O |
| NFR4 | All database operations SHALL use parameterized queries to prevent SQL injection |
| NFR5 | The system SHALL support environment-specific configuration (dev/prod/test) |

## System Boundaries

**In Scope**:
- User registration, authentication, and profile management
- Article CRUD with tagging and slug-based URLs
- Comment creation and deletion on articles
- User follow/unfollow relationships
- Article favoriting with count tracking
- Tag listing for discovery
- Personalized feed from followed authors

**Out of Scope**:
- Frontend UI or web application (API-only backend)
- Email notification or password recovery
- Rich text editing or media upload
- Search engine or full-text search
- Rate limiting or abuse prevention
- Analytics or traffic reporting
- Multi-tenant or workspace isolation

## Success Criteria

- All RealWorld API endpoints implemented and passing the official test suite
- Clean architecture with clear layer boundaries (Presentation → Domain → Infrastructure)
- 100% test coverage threshold enforced via pytest configuration
- Zero known security vulnerabilities in dependencies
- Async I/O throughout with no blocking operations in request handlers
