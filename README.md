# V&E Academy — App Educativa de Comprensión Lectora

Aplicación educativa para niños de 5 a 7 años que combina cuentos interactivos con actividades de comprensión lectora y minijuegos. Construida con **Flutter Web** (frontend) y **Django + SQLite/PostgreSQL** (backend).

---

## Inicio Rápido

### Windows (automático)

```bat
git clone https://github.com/000RAIZEL000/ve_academy_web.git
cd ve_academy_web
setup.bat
```

### Linux / Mac (automático)

```bash
git clone https://github.com/000RAIZEL000/ve_academy_web.git
cd ve_academy_web
chmod +x setup.sh
./setup.sh
```

El script hace todo: crea el entorno virtual, instala dependencias, migra la base de datos, carga los datos y arranca el servidor.

---

## Instalación Manual (paso a paso)

### Requisitos

- Python 3.11 o superior
- Flutter 3.x (solo para el frontend)
- Git

### Backend Django

```bash
cd backend

# 1. Entorno virtual
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # Linux/Mac

# 2. Dependencias
pip install -r requirements.txt

# 3. Variables de entorno
copy .env.example .env       # Windows
# cp .env.example .env       # Linux/Mac
# Por defecto usa SQLite. No se necesita configurar nada más.

# 4. Migraciones
python manage.py migrate

# 5. Cargar datos iniciales (libros, preguntas, juegos, tienda)
python manage.py loaddata fixtures/datos_iniciales.json

# 6. (Opcional) Crear superusuario para el panel admin
python manage.py createsuperuser

# 7. Iniciar servidor
python manage.py runserver
```

El backend queda disponible en **http://localhost:8000**

### Frontend Flutter

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

La app se abre en el navegador. Asegúrate de que el backend esté corriendo primero.

---

## Datos Incluidos

El fixture `backend/fixtures/datos_iniciales.json` contiene:

| Tipo | Cantidad |
|------|----------|
| Libros con texto completo | ~8 |
| Preguntas de comprensión | ~80 |
| Datos de minijuegos (LibroJuego) | ~8 |
| Objetos de la tienda | ~6 |

Para recargar los datos desde cero:

```bash
python manage.py flush --no-input
python manage.py loaddata fixtures/datos_iniciales.json
```

---

## Estructura del Proyecto

```
ve_academy_web/
├── setup.bat              ← Script automático Windows
├── setup.sh               ← Script automático Linux/Mac
├── backend/
│   ├── apps/
│   │   ├── usuarios/      # Registro, sesión, ranking, tienda
│   │   ├── libros/        # Catálogo de libros y preguntas
│   │   ├── actividades/   # Historial de puntajes
│   │   └── api/           # REST API para Flutter
│   ├── fixtures/
│   │   └── datos_iniciales.json  ← Datos de libros y juegos
│   ├── static/img/
│   │   ├── avatars/       # Imágenes de avatares (9 PNGs)
│   │   └── covers/        # Portadas de libros
│   ├── .env.example       # Plantilla de configuración
│   ├── manage.py
│   └── requirements.txt
└── frontend/
    ├── assets/
│   └── avatars/           # Avatares empaquetados en Flutter
    ├── lib/
    │   ├── screens/        # Pantallas de la app
    │   ├── services/       # Llamadas a la API
    │   └── widgets/        # Componentes reutilizables
    └── pubspec.yaml
```

---

## Stack Tecnológico

| Capa | Tecnología |
|------|------------|
| Frontend | Flutter 3.x (Web/Mobile) |
| Backend | Django 4.2 + DRF |
| Base de datos local | SQLite (por defecto) |
| Base de datos producción | PostgreSQL (Railway) |
| Servidor estático | WhiteNoise |
| Nube | Railway |

---

## Configuración de Base de Datos

El proyecto detecta automáticamente qué BD usar según las variables de entorno:

| Escenario | Configuración |
|-----------|--------------|
| Sin `.env` o sin `DB_NAME` | **SQLite** (archivo local, sin instalar nada) |
| `.env` con `DB_NAME` | **MySQL** (XAMPP local) |
| Variable `DATABASE_URL` | **PostgreSQL** (Railway/producción) |

Para desarrollo rápido en un nuevo computador, SQLite es suficiente — no requiere instalar ningún servidor de base de datos.

---

## Variables de Entorno

Copia `.env.example` a `.env` y ajusta según necesites:

```env
SECRET_KEY=django-insecure-dev-key-change-in-production-xyz123
DEBUG=True
JWT_SECRET_KEY=dev-jwt-secret-key

# Dejar vacío para usar SQLite
# DB_NAME=ve_academy_db
# DB_USER=root
# DB_PASSWORD=
# DB_HOST=localhost
# DB_PORT=3306
```

---

## API REST — Endpoints Principales

```
POST /api/register/                    → Crear cuenta
POST /api/login-email/                 → Iniciar sesión
GET  /api/libros/                      → Lista de libros
GET  /api/libros/<slug>/               → Detalle de libro
GET  /api/juegos/<slug>/               → Datos de minijuegos
POST /api/guardar/                     → Guardar resultado
GET  /api/ranking/                     → Tabla de puntajes
GET  /api/tienda/                      → Objetos de la tienda
POST /api/comprar/                     → Comprar objeto
```

---

## Despliegue en Railway

1. Hacer fork/push a GitHub
2. Crear nuevo proyecto en [railway.app](https://railway.app)
3. Conectar el repositorio de GitHub
4. Agregar servicio PostgreSQL en Railway
5. Railway asigna `DATABASE_URL` automáticamente
6. Agregar variables de entorno:

| Variable | Valor |
|----------|-------|
| `SECRET_KEY` | Cadena aleatoria larga |
| `DEBUG` | `False` |
| `ALLOWED_HOSTS` | `tu-app.railway.app` |

Railway detecta el `Procfile` y despliega automáticamente.

---

## Panel de Administración

```bash
python manage.py createsuperuser
```

Accede en http://localhost:8000/admin/ para gestionar libros, preguntas, estudiantes y objetos de la tienda.

---

_V&E Academy © 2025 — Aprender es una aventura_
