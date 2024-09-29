# Étape 1 : Utiliser PyGoat comme base pour installer les dépendances
FROM pygoat/pygoat:latest AS pygoat-base

# Étape 2 : Installer Python 3.11 sur l'image de base Python
FROM python:3.11-buster

# Définir le répertoire de travail
WORKDIR /app/pygoat

# Mettre à jour et installer les dépendances nécessaires
RUN apt-get update && \
    apt-get install --no-install-recommends -y dnsutils libpq-dev python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Définir des variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Installer pip et d'autres dépendances
RUN python -m pip install --no-cache-dir pip==22.0.4

# Copier le fichier requirements.txt depuis l'étape PyGoat
COPY --from=pygoat-base /app/pygoat/requirements.txt requirements.txt

# Vérifier si 'requests' est présent dans requirements.txt
RUN if ! grep -q "requests" requirements.txt; then \
      echo "requests==2.25.1" >> requirements.txt; \
    fi

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier les fichiers du projet
COPY . /app/

# Exposer le port 8000
EXPOSE 8000

# Vérifier si 'crispy_bootstrap4' est présent dans requirements.txt
RUN if ! grep -q "crispy_bootstrap4" requirements.txt; then \
      echo "crispy_bootstrap4==2024.1" >> requirements.txt; \
    fi

# Installer les dépendances restantes
RUN pip install --no-cache-dir -r requirements.txt

# Exécuter les migrations
RUN python3 /app/manage.py migrate

# Définir la commande pour exécuter l'application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.pygoat.wsgi:application"]
