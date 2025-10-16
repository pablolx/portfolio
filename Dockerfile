# ----------------------------------------------------------------------
# STAGE 1: BUILD (Compila dependências)
# ----------------------------------------------------------------------
FROM python:3.11-slim-buster AS builder

# Instala as ferramentas de build necessárias (gcc, libs do mysql, etc.)
RUN apt-get update && apt-get install -y --no-install-recommends \
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
# Instala mysqlclient e google-cloud-sql-connector
RUN pip install -r requirements.txt

# ----------------------------------------------------------------------
# STAGE 2: RUNTIME (Ambiente de execução final, menor e mais seguro)
# ----------------------------------------------------------------------
FROM python:3.11-slim-buster AS runtime

# Cria um usuário não-root para segurança (boas práticas do Cloud Run)
RUN useradd --create-home appuser
USER appuser

# Configura variáveis de ambiente
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
WORKDIR /home/appuser/app

# Copia apenas as dependências e o código necessários do stage "builder"
# Copia as dependências Python instaladas do stage anterior
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Copia o restante do código da sua aplicação (como appuser)
COPY --chown=appuser:appuser . /home/appuser/app/

# Colete arquivos estáticos
# O Cloud Run Jobs pode fazer isso se necessário, mas para o serviço principal:
# RUN python manage.py collectstatic --no-input

# Exponha a porta
EXPOSE 8000

# Comando padrão para rodar a aplicação usando Gunicorn
# Confirme se "Portfolio.wsgi:application" é o caminho correto para o seu WSGI
CMD ["gunicorn", "Portfolio.wsgi:application", "--bind", "0.0.0.0:8000"]
