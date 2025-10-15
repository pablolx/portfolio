ENV PORT=8080
# Usa imagem base leve com Python
FROM python:3.11-slim

# Evita criação de arquivos .pyc e ativa logs imediatos
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Define diretório de trabalho
WORKDIR /app

# Instala dependências
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copia todo o projeto
COPY . .

# Inicia o servidor Gunicorn apontando para o módulo correto
CMD gunicorn portfolio2025.wsgi:application --bind 0.0.0.0:$PORT