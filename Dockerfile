# Use imagem oficial do Python
FROM python:3.11-slim

# Define diretório de trabalho
WORKDIR /app

# Copia os arquivos do projeto
COPY . .

# Instala dependências
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Coleta arquivos estáticos
RUN python manage.py collectstatic --noinput

# Define variável de ambiente obrigatória
ENV PORT 8080

# Comando para iniciar o servidor
CMD exec gunicorn portfolio2025.wsgi:application --bind :$PORT --workers 1