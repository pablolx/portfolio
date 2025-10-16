# Use uma imagem Python base Linux
FROM python:3.11-slim-buster # buster ou bullseye são boas opções para slim

# Defina variáveis de ambiente para Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Crie e defina o diretório de trabalho dentro do contêiner
WORKDIR /app

# Instale as dependências do sistema operacional para mysqlclient
# Inclua o pacote de desenvolvimento para MySQL e GCC (para compilar mysqlclient)
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    gcc \
    pkg-config \
    # Limpeza para reduzir o tamanho da imagem
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copie o arquivo de requisitos e instale dependências Python
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copie o restante do código da sua aplicação
COPY . /app/

# Colete arquivos estáticos (se você tiver)
# Isso deve ser feito ANTES do deploy se você não tiver um CDN
# RUN python manage.py collectstatic --no-input

# Exponha a porta que o Gunicorn vai ouvir
EXPOSE 8000

# Comando padrão para rodar a aplicação usando Gunicorn
CMD ["gunicorn", "Portfolio.wsgi:application", "--bind", "0.0.0.0:8000"]