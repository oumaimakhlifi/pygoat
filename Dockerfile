# Étape 1 : Utiliser PyGoat comme base pour installer les dépendances
FROM pygoat/pygoat:latest AS pygoat-base

# Étape 2 : Installer Python 3.11 sur l'image de base Python
FROM python:3.11-buster

# Définir le répertoire de travail
WORKDIR /app/pygoat

# Définir des variables d'environnement
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Installer pip et d'autres dépendances
RUN python -m pip install --no-cache-dir pip==22.0.4

# Copier le fichier requirements.txt depuis l'étape PyGoat
COPY --from=pygoat-base /app/pygoat/requirements.txt requirements.txt

# Vérifier si 'crispy_bootstrap4' est présent dans requirements.txt
RUN if ! grep -q "crispy_bootstrap4" requirements.txt; then \
      echo "crispy_bootstrap4==2024.1" >> requirements.txt; \
    fi

# Vérifier si 'requests' est présent dans requirements.txt
RUN if ! grep -q "requests" requirements.txt; then \
      echo "requests==2.25.1" >> requirements.txt; \
    fi

# Vérifier si 'PyJWT' est présent dans requirements.txt
RUN if ! grep -q "PyJWT" requirements.txt; then \
      echo "PyJWT==2.9.0" >> requirements.txt; \
    fi

# Vérifier si 'cryptography' est présent dans requirements.txt
RUN if ! grep -q "cryptography" requirements.txt; then \
      echo "cryptography==43.0.1" >> requirements.txt; \
    fi

# Vérifier si 'sqlite3' est présent dans requirements.txt
RUN if ! grep -q "sqlite3" requirements.txt; then \
      echo "sqlite3==3.46.1" >> requirements.txt; \
    fi

# Installer les dépendances restantes
RUN pip install --no-cache-dir -r requirements.txt

# Copier les fichiers du projet
COPY . /app/

# Exposer le port 8000
EXPOSE 8000

# Exécuter les migrations
RUN python3 /app/manage.py migrate

# Définir la commande pour exécuter l'application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.pygoat.wsgi:application"]
