# Étape 1 : Utiliser PyGoat comme base pour installer les dépendances
FROM pygoat/pygoat:latest AS pygoat-base

# Étape 2 : Installer Python 3.11 sur l'image de base Python
FROM python:3.11-slim

# Définir le répertoire de travail
WORKDIR /app/pygoat

# Définir des variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Installer les dépendances nécessaires, y compris gcc et libpq-dev
RUN apt-get update && \
    apt-get install -y libsqlite3-dev libpq-dev gcc && \
    python -m pip install --no-cache-dir pip==22.0.4

# Copier le fichier requirements.txt depuis l'étape PyGoat
COPY --from=pygoat-base /app/pygoat/requirements.txt requirements.txt

# Vérifier les dépendances et les ajouter si nécessaire
RUN if ! grep -q "crispy_bootstrap4" requirements.txt; then \
      echo "crispy_bootstrap4==2024.1" >> requirements.txt; \
    fi && \
    if ! grep -q "requests" requirements.txt; then \
      echo "requests==2.25.1" >> requirements.txt; \
    fi && \
    if ! grep -q "PyJWT" requirements.txt; then \
      echo "PyJWT==2.9.0" >> requirements.txt; \
    fi && \
    if ! grep -q "cryptography" requirements.txt; then \
      echo "cryptography==43.0.1" >> requirements.txt; \
    fi && \
    if ! grep -q "argon2" requirements.txt; then \
      echo "argon2-cffi==21.3.0" >> requirements.txt; \
    fi && \
    if ! grep -q "Pillow" requirements.txt; then \
      echo "Pillow" >> requirements.txt; \
    fi && \
    if ! grep -q "psycopg2-binary" requirements.txt; then \
      echo "psycopg2-binary" >> requirements.txt; \
    fi

# Installer les dépendances restantes
RUN pip install --no-cache-dir -r requirements.txt

# Copier les fichiers du projet
COPY . /app/pygoat  # Assurez-vous que tous les fichiers nécessaires sont copiés ici

# Exposer le port 8000
EXPOSE 8000

# Exécuter les migrations
RUN python3 manage.py migrate  # Assurez-vous que ce chemin est correct

# Définir la commande pour exécuter l'application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi:application"]
