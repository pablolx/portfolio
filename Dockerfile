# STAGE 1: BUILD (Compila dependências e prepara o ambiente)
# Usamos o python:3.11-slim-buster como base
FROM python:3.11-slim AS builder


# Define o frontend Debian como não-interativo para evitar prompts em ambientes CI
ENV DEBIAN_FRONTEND=noninteractive

# 1. ATUALIZAÇÃO E INSTALAÇÃO DE DEPENDÊNCIAS DE BUILD
# Executa o update em uma camada separada e faz a limpeza imediatamente após
RUN apt-get update \
    # Força a reconfiguração de quaisquer pacotes quebrados antes da instalação
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --fix-missing \
        build-essential \
        default-libmysqlclient-dev \
        gcc \
        pkg-config \
    # Limpeza para reduzir o tamanho da camada
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crie e defina o diretório de trabalho
WORKDIR /app

# Copie e instale dependências Python
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# ----------------------------------------------------------------------
# STAGE 2: RUNTIME (Ambiente de execução final, menor e mais seguro para o Cloud Run)
# ----------------------------------------------------------------------
FROM python:3.11-slim-buster AS runtime

# Cria um usuário não-root para segurança (boas práticas do Cloud Run)
RUN useradd --create-home appuser
USER appuser

# Configura variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# O Cloud Run injeta a porta em $PORT (geralmente 8080).
ENV PORT=8080
WORKDIR /home/appuser/app

# Copia apenas as dependências essenciais e o executável do Gunicorn do stage "builder"
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Copia o restante do código da sua aplicação
COPY --chown=appuser:appuser . /home/appuser/app/

# Colete arquivos estáticos
RUN python manage.py collectstatic --no-input

# O comando padrão para rodar a aplicação usando Gunicorn
# Bind 0.0.0.0:${PORT} garante que ele escute na porta que o Cloud Run injeta.
# Confirme se "Portfolio.wsgi:application" é o caminho correto para o seu WSGI.
CMD ["gunicorn", "portfolio2025.wsgi:application", "--bind", "0.0.0.0:${PORT}"]

