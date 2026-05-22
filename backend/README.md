# 🎓 V&E Academy — Prototipo Web

Plataforma educativa de lectura y actividades para niños de 5 a 7 años.  
Construida con **Django + PostgreSQL**, lista para desplegarse en **Railway**.

---

## 🗂️ Estructura del Proyecto

```
ve_academy/
├── apps/
│   ├── usuarios/          # Registro, sesión, ranking
│   ├── libros/            # Catálogo de cuentos
│   └── actividades/       # Preguntas y puntajes
├── static/
│   ├── css/main.css
│   ├── js/main.js
│   └── img/               # Avatares, portadas, fondos
├── templates/
│   ├── base.html
│   ├── usuarios/
│   ├── libros/
│   └── actividades/
├── ve_academy/
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── manage.py
├── requirements.txt
├── Procfile
└── railway.json
```

---

## 🚀 Despliegue en Railway (paso a paso)

### 1. Crear cuenta y proyecto en Railway

1. Ir a [railway.app](https://railway.app) → Registrarse (gratis)
2. Click en **"New Project"**
3. Elegir **"Deploy from GitHub repo"**

### 2. Subir el código a GitHub

```bash
# En la carpeta ve_academy/
git init
git add .
git commit -m "V&E Academy - Prototipo Web inicial"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/ve-academy.git
git push -u origin main
```

### 3. Agregar PostgreSQL en Railway

1. En tu proyecto Railway → click **"+ New"** → **"Database"** → **"PostgreSQL"**
2. Railway crea la base de datos automáticamente
3. En la sección **Variables** del servicio DB, copia el valor de `DATABASE_URL`

### 4. Configurar variables de entorno en Railway

En tu servicio web → **Variables** → agregar:

| Variable | Valor |
|----------|-------|
| `SECRET_KEY` | Una clave larga y aleatoria (ej: `python -c "import secrets; print(secrets.token_hex(50))"`) |
| `DEBUG` | `False` |
| `DATABASE_URL` | (se conecta automáticamente si están en el mismo proyecto) |

> 💡 Railway conecta automáticamente la DB si el servicio web y PostgreSQL están en el mismo proyecto. No necesitas copiar la URL manualmente.

### 5. Deploy automático

Railway detecta el `Procfile` y ejecuta:
```
release: python manage.py migrate && python manage.py poblar_db
web: gunicorn ve_academy.wsgi --bind 0.0.0.0:$PORT --workers 2
```

¡El deploy se hace solo! En ~2 minutos tu app está online.

---

## 💻 Correr localmente

```bash
# 1. Crear entorno virtual
python -m venv venv
source venv/bin/activate       # Windows: venv\Scripts\activate

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Crear archivo .env
cp .env.example .env
# Editar .env con tus valores (puedes dejar la DB vacía para usar SQLite)

# 4. Migrar y poblar base de datos
python manage.py migrate
python manage.py poblar_db

# 5. Correr el servidor
python manage.py runserver
```

Abre http://localhost:8000 en tu navegador 🎉

---

## 📱 Compatibilidad con Flutter (opcional)

El backend expone una API REST simple. Para conectar Flutter:

### Endpoints disponibles:
```
POST /registro/                  → Crear/cargar usuario
GET  /libros/                    → Lista de libros (requiere sesión)
GET  /libros/<slug>/             → Detalle de libro
GET  /actividades/<slug>/        → Actividades del libro
POST /actividades/api/guardar/   → Guardar resultado
GET  /ranking/                   → Tabla de puntajes
POST /api/puntos/                → Sumar puntos (AJAX)
```

Para usar desde Flutter, puedes agregar autenticación por token (DRF) más adelante.

---

## 🗄️ Base de Datos PostgreSQL — Modelos

```
Estudiante
  - nombre (único)
  - edad (5, 6 o 7)
  - avatar (conejo, gato, lechuza, etc.)
  - puntos (acumulados)

Libro
  - slug (identificador único)
  - titulo
  - texto
  - portada (nombre de imagen)
  - activo / orden

Pregunta
  - libro (FK)
  - edad (5, 6 o 7)
  - enunciado
  - opcion_a / opcion_b / opcion_c
  - correcta (0, 1 o 2)

SesionActividad
  - estudiante (FK)
  - libro (FK)
  - puntos_obtenidos
  - completado
  - fecha
```

---

## 🛠️ Panel de Administración

```bash
python manage.py createsuperuser
```

Luego entrar a `/admin/` para gestionar libros, preguntas y estudiantes.

---

## 🧩 Stack Tecnológico

| Capa | Tecnología |
|------|-----------|
| Backend | Django 4.2 |
| Base de datos | PostgreSQL (Railway) |
| ORM | Django ORM |
| Frontend | HTML5 + CSS3 + JavaScript vanilla |
| Servidor | Gunicorn |
| Archivos estáticos | WhiteNoise |
| Nube | Railway |
| Opcional | Flutter (mobile), Django REST Framework (API) |

---

## ✅ Checklist antes de deploy

- [ ] `SECRET_KEY` generada y configurada en Railway
- [ ] `DEBUG=False` en producción
- [ ] `DATABASE_URL` conectada (PostgreSQL en Railway)
- [ ] Código subido a GitHub
- [ ] Deploy ejecutado correctamente

---

_V&E Academy © 2025 — Aprender es una aventura_ 🌟
