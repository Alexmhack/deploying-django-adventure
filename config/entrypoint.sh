APP_PORT = ${PORT:-8000}

cd /app/

/opt/venv/bin/gunicorn --worker-tmp-dir /dev/shm backend.asgi:application -k uvicorn.workers.UvicornWorker --bind "0.0.0.0:8000"
