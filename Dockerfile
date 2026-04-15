FROM python:3.12-slim

# Pin uv version via official image — prevents supply chain attack on the installer itself
COPY --from=ghcr.io/astral-sh/uv:0.11.6 /uv /usr/local/bin/uv

WORKDIR /app

# Copy only dependency files first for Docker layer caching
COPY pyproject.toml uv.lock ./

# --frozen: fail if uv.lock is out of sync with pyproject.toml
# --no-dev: exclude dev dependencies (pytest, httpx, etc.)
# --no-install-project: skip installing the project package itself
RUN uv sync --frozen --no-dev --no-install-project

# uv sync always creates .venv — add it to PATH so uvicorn is found at runtime
ENV PATH="/app/.venv/bin:$PATH"

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
