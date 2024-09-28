FROM python:3.11-buster

# set work directory
WORKDIR /app

# Update and install dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y dnsutils libpq-dev python3-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install pip and other dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Expose port and run migrations
EXPOSE 8000
RUN python3 /app/manage.py migrate

# Set command to run the application
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
