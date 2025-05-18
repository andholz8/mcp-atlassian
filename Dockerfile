# Dockerfile atualizado para Railway

# Etapa 1: build com dependências
FROM python:3.10-alpine AS builder

WORKDIR /app

COPY . .

# Instala dependências
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir .

# Etapa final: runtime
FROM python:3.10-alpine

WORKDIR /app

# Cria usuário não root
RUN adduser -D app
USER app

COPY --from=builder /usr/local /usr/local
COPY --chown=app:app . .

ENV PYTHONUNBUFFERED=1

# Porta padrão para streamable-http e SSE
EXPOSE 9000

# EntryPoint configurável via CMD
CMD ["mcp-atlassian", "--transport", "streamable-http", "--port", "9000", "-vv"]
