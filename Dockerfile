FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN python manage.py collectstatic --noinput
ENV PORT 8080
CMD exec gunicorn portfolio2025.wsgi:application --bind :$PORT --workers 1
