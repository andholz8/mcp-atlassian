# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.10-alpine AS uv

# Instalar dependências no diretório de trabalho
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Copia arquivos do projeto
COPY pyproject.toml .
COPY uv.lock .

# Gera o lockfile e instala dependências
RUN uv lock
RUN uv sync --frozen --no-install-project --no-dev --no-editable

# Adiciona o restante do projeto
COPY . .

# Instala o restante com dependências do código-fonte
RUN uv sync --frozen --no-dev --no-editable

# Remove arquivos desnecessários
RUN find /app/.venv -name '__pycache__' -type d -exec rm -rf {} + && \
    find /app/.venv -name '*.pyc' -delete && \
    find /app/.venv -name '*.pyo' -delete && \
    echo "Cleaned up .venv"

# Final stage
FROM python:3.10-alpine

# Create a non-root user 'app'
RUN adduser -D -h /home/app -s /bin/sh app
WORKDIR /app
USER app

COPY --from=uv --chown=app:app /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT ["mcp-atlassian"]

