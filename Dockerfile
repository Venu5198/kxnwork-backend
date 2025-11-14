FROM python:3.11-slim

WORKDIR /app
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app /app

ENV PORT=8080
EXPOSE 8080

CMD ["gunicorn", "-c", "gunicorn_conf.py", "main:app"]

