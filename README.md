# V&E Academy — App Educativa de Comprensión Lectora

Aplicación educativa para niños de 5 a 7 años que combina cuentos interactivos con actividades de comprensión lectora. Construida con **Flutter Web** (frontend) y **Django + PostgreSQL** (backend), lista para desplegarse en Railway.

---

## Estructura del Proyecto

```
ve_academy_web/
├── backend/          # API Django + servidor web
│   ├── apps/
│   │   ├── usuarios/     # Registro, sesión, ranking
│   │   ├── libros/       # Catálogo de cuentos
│   │   ├── actividades/  # Preguntas y puntajes
│   │   └── api/          # REST API para Flutter
│   ├── static/           # CSS, JS, imágenes
│   ├── templates/        # HTML (Django templates)
│   ├── ve_academy/       # Configuración Django
│   ├── manage.py
│   ├── requirements.txt
│   ├── Procfile
│   └── railway.json
└── frontend/         # App Flutter Web
    ├── lib/
    │   ├── screens/      # Pantallas de la app
    │   ├── models/       # Modelos de datos
    │   └── services/     # Llamadas a la API
    └── pubspec.yaml
```

---

## Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Frontend mobile/web | Flutter 3.x |
| Backend | Django 4.2 |
| Base de datos | PostgreSQL (Railway) |
| API | Django REST Framework |
| Servidor | Gunicorn + WhiteNoise |
| Nube | Railway |

---

## Funcionalidades

- Registro de estudiante con nombre, edad (5-7) y avatar
- Catálogo de cuentos adaptados por nivel de edad
- Actividades de comprensión lectora con preguntas de opción múltiple
- Sistema de puntos y ranking
- 8+ libros con historias y juegos: La Hormiga Valiente, El Pájaro que Aprendió a Volar, El Árbol Mágico, El Sol y la Luna, La Ballena Amiga, y más

---

## API REST — Endpoints

```
POST /registro/                  → Crear/cargar usuario
GET  /libros/                    → Lista de libros
GET  /libros/<slug>/             → Detalle de libro
GET  /actividades/<slug>/        → Actividades del libro
POST /actividades/api/guardar/   → Guardar resultado
GET  /ranking/                   → Tabla de puntajes
POST /api/puntos/                → Sumar puntos
```

---

## Modelos de Base de Datos

```
Estudiante
  - nombre (único)
  - edad (5, 6 o 7)
  - avatar (conejo, gato, lechuza, leon, oso, panda, tigre, zorro)
  - puntos (acumulados)

Libro
  - slug (identificador único)
  - titulo / texto / portada
  - activo / orden

Pregunta
  - libro (FK) / edad (5, 6 o 7)
  - enunciado / opcion_a / opcion_b / opcion_c
  - correcta (índice 0, 1 o 2)

SesionActividad
  - estudiante (FK) / libro (FK)
  - puntos_obtenidos / completado / fecha
```

---

## Correr el Backend Localmente

```bash
cd backend

# 1. Crear entorno virtual
python -m venv venv
venv\Scripts\activate      # Windows
# source venv/bin/activate  # Mac/Linux

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env (puedes dejar DB vacía para usar SQLite)

# 4. Migrar y poblar la base de datos
python manage.py migrate
python manage.py poblar_db

# 5. Iniciar servidor
python manage.py runserver
```

Abre http://localhost:8000

---

## Correr el Frontend Flutter

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## Despliegue en Railway

1. Subir código a GitHub
2. Crear nuevo proyecto en [railway.app](https://railway.app)
3. Elegir "Deploy from GitHub repo" → seleccionar este repositorio
4. Agregar servicio PostgreSQL en Railway
5. Configurar variables de entorno:

| Variable | Valor |
|----------|-------|
| `SECRET_KEY` | Clave secreta larga |
| `DEBUG` | `False` |
| `DATABASE_URL` | (Railway lo conecta automáticamente) |

Railway detecta el `Procfile` y ejecuta el deploy automáticamente.

---

## Panel de Administración

```bash
python manage.py createsuperuser
```

Luego entrar a `/admin/` para gestionar libros, preguntas y estudiantes.

---

_V&E Academy © 2025 — Aprender es una aventura_
