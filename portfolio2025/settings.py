# settings.py

import os
from pathlib import Path
import dj_database_url


# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent


# Quick-start development settings - unsuitable for production
# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-+m@g_z##k(l=2!@#v&ky%h_m^3_xm*x9i*=xl^*o)7%umicb1e')

# SECURITY WARNING: don't run with debug turned on in production!
# Use 'True' apenas em desenvolvimento. O Cloud Run injetará 'False' via env_vars.
DEBUG = os.environ.get('DEBUG', 'True') == 'True'

# Use '*' em dev. Em produção (Cloud Run), ele usará o domínio injetado automaticamente.
ALLOWED_HOSTS = ['*']


# Application definition

INSTALLED_APPS = [
    "apps.website",
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'portfolio2025.urls'

TEMPLATES = [
    {
        # Removendo a entrada DIRS duplicada
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / "templates"],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },]


WSGI_APPLICATION = 'portfolio2025.wsgi.application'


# Database
# ------------------------------------------------------------------
# 1. Configuração do Google Cloud SQL (Prioridade em Produção)
# ------------------------------------------------------------------

# Estas variáveis serão injetadas pelo Cloud Run (Secrets do GitHub)
DB_NAME = os.environ.get('DB_NAME')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
CLOUD_SQL_CONNECTION_NAME = os.environ.get('CLOUD_SQL_CONNECTION_NAME')

# Verifica se todas as credenciais de produção estão presentes
if all([CLOUD_SQL_CONNECTION_NAME, DB_NAME, DB_USER, DB_PASSWORD]):

    # Se estivermos em produção e com credenciais completas, use Cloud SQL Connector.
    print("Configurando Cloud SQL: Conexão segura via CloudSQLMySQLConnector.")

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': DB_NAME,
            'USER': DB_USER,
            'PASSWORD': DB_PASSWORD,

            # HOST e PORTA são placeholders, o conector usa um socket interno.
            'HOST': '127.0.0.1',
            'PORT': '3306',
            'OPTIONS': {
                'connector': 'google.cloud.sql.connector.django.connector.CloudSQLMySQLConnector',
                'cloudsql_instance': CLOUD_SQL_CONNECTION_NAME,  # Usa o nome de conexão real
                'charset': 'utf8mb4',
                'init_command': "SET default_storage_engine=InnoDB, sql_mode='STRICT_TRANS_TABLES'",
            }
        }
    }
    # Recomendado em produção: Trust the X-Forwarded-Proto header
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

else:
    # ------------------------------------------------------------------
    # 2. Configuração de Desenvolvimento (SQLite ou DATABASE_URL)
    # ------------------------------------------------------------------
    print("Configurando Banco de Dados Local (SQLite ou DATABASE_URL).")

    DATABASES = {
        'default': dj_database_url.config(
            # Fallback para DATABASE_URL ou SQLite
            default='sqlite:///{}'.format(os.path.join(BASE_DIR, 'db.sqlite3')),
            conn_max_age=600
        )
    }

# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATIC_URL = '/static/'
STATICFILES_DIRS = [
    BASE_DIR / "static",
]
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
