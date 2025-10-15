# Dockerfile
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

COPY portfolio_project .

# Comando para rodar a aplicação usando Gunicorn (servidor de produção)
CMD gunicorn seu_projeto.wsgi:application --bind 0.0.0.0:$PORT
