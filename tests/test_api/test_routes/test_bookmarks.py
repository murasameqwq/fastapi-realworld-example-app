import pytest
from asyncpg.pool import Pool
from fastapi import FastAPI
from httpx import AsyncClient
from starlette import status

from app.db.repositories.articles import ArticlesRepository
from app.db.repositories.users import UsersRepository
from app.models.domain.articles import Article
from app.models.domain.users import UserInDB
from app.models.schemas.articles import ArticleInResponse, ListOfArticlesInResponse

pytestmark = pytest.mark.asyncio


async def test_user_can_not_bookmark_not_existing_article(
    app: FastAPI,
    authorized_client: AsyncClient,
) -> None:
    response = await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug="wrong-slug"),
    )
    assert response.status_code == status.HTTP_404_NOT_FOUND


async def test_user_can_bookmark_article(
    app: FastAPI,
    authorized_client: AsyncClient,
    test_article: Article,
) -> None:
    response = await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug=test_article.slug),
    )
    assert response.status_code == status.HTTP_200_OK

    bookmarks_response = await authorized_client.get(
        app.url_path_for("articles:list-user-bookmarks"),
    )
    bookmarks = ListOfArticlesInResponse(**bookmarks_response.json())
    assert bookmarks.articles_count == 1
    assert bookmarks.articles[0].slug == test_article.slug


async def test_user_can_not_bookmark_article_twice(
    app: FastAPI,
    authorized_client: AsyncClient,
    test_article: Article,
) -> None:
    await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug=test_article.slug),
    )

    response = await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug=test_article.slug),
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


async def test_user_can_remove_bookmark(
    app: FastAPI,
    authorized_client: AsyncClient,
    test_article: Article,
) -> None:
    await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug=test_article.slug),
    )

    response = await authorized_client.delete(
        app.url_path_for("articles:unbookmark-article", slug=test_article.slug),
    )
    assert response.status_code == status.HTTP_200_OK

    bookmarks_response = await authorized_client.get(
        app.url_path_for("articles:list-user-bookmarks"),
    )
    bookmarks = ListOfArticlesInResponse(**bookmarks_response.json())
    assert bookmarks.articles_count == 0


async def test_user_can_not_remove_non_existing_bookmark(
    app: FastAPI,
    authorized_client: AsyncClient,
    test_article: Article,
) -> None:
    response = await authorized_client.delete(
        app.url_path_for("articles:unbookmark-article", slug=test_article.slug),
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


async def test_bookmarks_are_private(
    app: FastAPI,
    authorized_client: AsyncClient,
    pool: Pool,
    test_article: Article,
) -> None:
    """User A's bookmarks should not include User B's bookmarks."""
    # Bookmark the article with authorized_client (User A)
    await authorized_client.post(
        app.url_path_for("articles:bookmark-article", slug=test_article.slug),
    )

    # Create User B
    async with pool.acquire() as connection:
        users_repo = UsersRepository(connection)
        user_b = await users_repo.create_user(
            username="user_b", email="user_b@email.com", password="password"
        )

    # Login as User B
    login_response = await authorized_client.post(
        app.url_path_for("users:login"),
        json={"user": {"email": "user_b@email.com", "password": "password"}},
    )
    token = login_response.json()["user"]["token"]
    client_b_headers = {
        "Authorization": f"Token {token}",
        "Content-Type": "application/json",
    }

    # User B should have zero bookmarks
    bookmarks_response = await authorized_client.get(
        app.url_path_for("articles:list-user-bookmarks"),
        headers=client_b_headers,
    )
    bookmarks = ListOfArticlesInResponse(**bookmarks_response.json())
    assert bookmarks.articles_count == 0


async def test_user_bookmarks_with_limit_and_offset(
    app: FastAPI,
    authorized_client: AsyncClient,
    test_user: UserInDB,
    pool: Pool,
) -> None:
    """Test pagination of bookmarks list."""
    async with pool.acquire() as connection:
        articles_repo = ArticlesRepository(connection)

        for i in range(5):
            await articles_repo.create_article(
                slug=f"bookmark-test-slug-{i}",
                title=f"Test {i}",
                description="tmp",
                body="tmp",
                author=test_user,
            )

            await authorized_client.post(
                app.url_path_for("articles:bookmark-article", slug=f"bookmark-test-slug-{i}"),
            )

    # Get all bookmarks
    full_response = await authorized_client.get(
        app.url_path_for("articles:list-user-bookmarks"),
    )
    full_bookmarks = ListOfArticlesInResponse(**full_response.json())
    assert full_bookmarks.articles_count == 5

    # Get bookmarks with limit and offset
    paginated_response = await authorized_client.get(
        app.url_path_for("articles:list-user-bookmarks"),
        params={"limit": 2, "offset": 3},
    )
    paginated_bookmarks = ListOfArticlesInResponse(**paginated_response.json())
    assert paginated_bookmarks.articles_count == 2
    assert paginated_bookmarks.articles == full_bookmarks.articles[3:]
