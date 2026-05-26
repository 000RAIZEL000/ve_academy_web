@echo off
chcp 65001 > nul
echo ============================================================
echo   V^&E Academy — Configuracion automatica del backend
echo ============================================================
echo.

cd /d "%~dp0backend"

echo [1/5] Creando entorno virtual...
python -m venv venv
if errorlevel 1 (
    echo ERROR: No se pudo crear el entorno virtual. Verifica que Python 3.11+ este instalado.
    pause & exit /b 1
)

echo [2/5] Instalando dependencias...
call venv\Scripts\activate.bat
pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo ERROR: Fallo la instalacion de dependencias.
    pause & exit /b 1
)

echo [3/5] Configurando variables de entorno...
if not exist .env (
    copy .env.example .env > nul
    echo Archivo .env creado desde .env.example
    echo NOTA: La BD usara SQLite por defecto. Edita .env para usar MySQL.
)

echo [4/5] Ejecutando migraciones...
python manage.py migrate --run-syncdb
if errorlevel 1 (
    echo ERROR: Fallo la migracion.
    pause & exit /b 1
)

echo [5/5] Cargando datos iniciales (libros, preguntas, juegos, tienda)...
python manage.py loaddata fixtures/datos_iniciales.json
if errorlevel 1 (
    echo ERROR: Fallo la carga de datos.
    pause & exit /b 1
)

echo.
echo ============================================================
echo   Listo! Iniciando servidor en http://localhost:8000
echo   Presiona Ctrl+C para detener.
echo ============================================================
echo.
python manage.py runserver
