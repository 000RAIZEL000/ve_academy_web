#!/usr/bin/env bash
set -e

echo "============================================================"
echo "  V&E Academy — Configuracion automatica del backend"
echo "============================================================"
echo

cd "$(dirname "$0")/backend"

echo "[1/5] Creando entorno virtual..."
python3 -m venv venv

echo "[2/5] Instalando dependencias..."
source venv/bin/activate
pip install -r requirements.txt --quiet

echo "[3/5] Configurando variables de entorno..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Archivo .env creado desde .env.example"
    echo "NOTA: La BD usara SQLite por defecto. Edita .env para usar MySQL/PostgreSQL."
fi

echo "[4/5] Ejecutando migraciones..."
python manage.py migrate --run-syncdb

echo "[5/5] Cargando datos iniciales (libros, preguntas, juegos, tienda)..."
python manage.py loaddata fixtures/datos_iniciales.json

echo
echo "============================================================"
echo "  Listo! Iniciando servidor en http://localhost:8000"
echo "  Presiona Ctrl+C para detener."
echo "============================================================"
echo
python manage.py runserver
