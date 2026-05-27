import jwt
from datetime import datetime, timedelta, timezone

from django.conf import settings
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from apps.usuarios.models import Estudiante, Logro, ObjetoTienda, CompraEstudiante, InsigniaEstudiante
from apps.libros.models import Libro, LibroJuego
from apps.actividades.models import SesionActividad
from .serializers import (
    EstudianteDetailSerializer, LogroSerializer,
    ObjetoTiendaSerializer, LibroSerializer, LibroDetailSerializer, LibroJuegoSerializer,
)


# ──────────────────────────── JWT helpers ────────────────────────────

def _generate_token(estudiante_id: int) -> str:
    payload = {
        'sub': estudiante_id,
        'iat': datetime.now(tz=timezone.utc),
        'exp': datetime.now(tz=timezone.utc) + timedelta(days=30),
    }
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm='HS256')


def _decode_token(token: str) -> dict:
    return jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=['HS256'])


# ──────────────────────────── Auth ───────────────────────────────────

@api_view(['POST'])
def register_estudiante(request):
    """Registrar nuevo estudiante con nombre, edad, avatar, email y contraseña."""
    nombre = request.data.get('nombre', '').strip()
    edad_raw = request.data.get('edad', 5)
    avatar = request.data.get('avatar', 'panda')
    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '').strip()

    try:
        edad = int(edad_raw)
    except (ValueError, TypeError):
        edad = 0

    if not nombre or edad not in [5, 6, 7]:
        return Response({'error': 'Nombre y edad (5-7) son requeridos'}, status=status.HTTP_400_BAD_REQUEST)
    if not email or '@' not in email:
        return Response({'error': 'Correo electrónico inválido'}, status=status.HTTP_400_BAD_REQUEST)
    if not password or len(password) < 6:
        return Response({'error': 'La contraseña debe tener al menos 6 caracteres'}, status=status.HTTP_400_BAD_REQUEST)

    if Estudiante.objects.filter(email__iexact=email).exists():
        return Response({'error': 'Este correo ya está registrado'}, status=status.HTTP_400_BAD_REQUEST)

    if Estudiante.objects.filter(nombre__iexact=nombre).exists():
        return Response({'error': 'Este nombre de usuario ya existe'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante = Estudiante(nombre=nombre, edad=edad, avatar=avatar, email=email)
    estudiante.set_password(password)
    estudiante.save()

    estudiante.actualizar_racha()
    serializer = EstudianteDetailSerializer(estudiante)
    data = dict(serializer.data)
    data['token'] = _generate_token(estudiante.id)
    return Response(data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def login_email(request):
    """Iniciar sesión con email y contraseña."""
    email = request.data.get('email', '').strip().lower()
    password = request.data.get('password', '').strip()

    if not email or not password:
        return Response({'error': 'Correo y contraseña son requeridos'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        estudiante = Estudiante.objects.get(email__iexact=email)
    except Estudiante.DoesNotExist:
        return Response({'error': 'Correo o contraseña incorrectos'}, status=status.HTTP_401_UNAUTHORIZED)

    if not estudiante.check_password(password):
        return Response({'error': 'Correo o contraseña incorrectos'}, status=status.HTTP_401_UNAUTHORIZED)

    estudiante.actualizar_racha()
    serializer = EstudianteDetailSerializer(estudiante)
    data = dict(serializer.data)
    data['token'] = _generate_token(estudiante.id)
    return Response(data)


@api_view(['POST'])
def login_estudiante(request):
    """Login legacy por nombre/edad/avatar (mantener compatibilidad)."""
    nombre = request.data.get('nombre', '').strip()
    edad = int(request.data.get('edad', 5))
    avatar = request.data.get('avatar', 'panda')

    if not nombre or edad not in [5, 6, 7]:
        return Response({'error': 'Datos inválidos'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante, created = Estudiante.objects.get_or_create(
        nombre__iexact=nombre,
        defaults={'nombre': nombre, 'edad': edad, 'avatar': avatar, 'puntos': 0},
    )
    if not created:
        estudiante.edad = edad
        estudiante.avatar = avatar
        estudiante.save()

    estudiante.actualizar_racha()
    serializer = EstudianteDetailSerializer(estudiante)
    data = dict(serializer.data)
    data['token'] = _generate_token(estudiante.id)
    return Response(data)


@api_view(['POST'])
def verify_token(request):
    """Verificar JWT y devolver datos actualizados."""
    token = request.data.get('token', '')
    if not token:
        return Response({'error': 'Token requerido'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        payload = _decode_token(token)
        estudiante = get_object_or_404(Estudiante, pk=payload['sub'])
        estudiante.actualizar_racha()
        serializer = EstudianteDetailSerializer(estudiante)
        data = dict(serializer.data)
        data['token'] = token
        return Response(data)
    except jwt.ExpiredSignatureError:
        return Response({'error': 'Token expirado'}, status=status.HTTP_401_UNAUTHORIZED)
    except jwt.InvalidTokenError:
        return Response({'error': 'Token inválido'}, status=status.HTTP_401_UNAUTHORIZED)


# ──────────────────────────── Estudiantes ────────────────────────────

@api_view(['GET'])
def estudiante_detalle(request, pk):
    estudiante = get_object_or_404(Estudiante, pk=pk)
    estudiante.actualizar_racha()
    serializer = EstudianteDetailSerializer(estudiante)
    return Response(serializer.data)


@api_view(['POST'])
def actualizar_perfil(request, pk):
    """Actualizar nombre, avatar del estudiante."""
    estudiante = get_object_or_404(Estudiante, pk=pk)
    nombre = request.data.get('nombre', '').strip()
    avatar = request.data.get('avatar', '').strip()

    if nombre and nombre != estudiante.nombre:
        if Estudiante.objects.filter(nombre__iexact=nombre).exclude(pk=pk).exists():
            return Response({'error': 'Ese nombre ya está en uso'}, status=status.HTTP_400_BAD_REQUEST)
        estudiante.nombre = nombre
    if avatar:
        estudiante.avatar = avatar
    estudiante.save()

    serializer = EstudianteDetailSerializer(estudiante)
    return Response(serializer.data)


@api_view(['POST'])
def cambiar_password(request, pk):
    """Cambiar contraseña del estudiante."""
    estudiante = get_object_or_404(Estudiante, pk=pk)
    password_actual = request.data.get('password_actual', '')
    password_nuevo = request.data.get('password_nuevo', '')

    if estudiante.password_hash and not estudiante.check_password(password_actual):
        return Response({'error': 'Contraseña actual incorrecta'}, status=status.HTTP_400_BAD_REQUEST)
    if len(password_nuevo) < 6:
        return Response({'error': 'La nueva contraseña debe tener al menos 6 caracteres'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante.set_password(password_nuevo)
    estudiante.save()
    return Response({'mensaje': 'Contraseña actualizada correctamente'})


@api_view(['GET'])
def ranking(request):
    edad = request.query_params.get('edad')
    qs = Estudiante.objects.order_by('-puntos')
    if edad:
        qs = qs.filter(edad=edad)
    serializer = EstudianteDetailSerializer(qs[:10], many=True)
    return Response(serializer.data)


# ──────────────────────────── Logros / Tienda ────────────────────────

@api_view(['GET'])
def lista_logros(request):
    serializer = LogroSerializer(Logro.objects.all(), many=True)
    return Response(serializer.data)


@api_view(['GET'])
def lista_tienda(request):
    serializer = ObjetoTiendaSerializer(ObjetoTienda.objects.all(), many=True)
    return Response(serializer.data)


@api_view(['POST'])
def comprar_objeto(request):
    estudiante_id = request.data.get('estudiante_id')
    objeto_id = request.data.get('objeto_id')

    estudiante = get_object_or_404(Estudiante, pk=estudiante_id)
    objeto = get_object_or_404(ObjetoTienda, pk=objeto_id)

    if estudiante.puntos < objeto.precio:
        return Response({'error': 'No tienes suficientes puntos'}, status=status.HTTP_400_BAD_REQUEST)

    if CompraEstudiante.objects.filter(estudiante=estudiante, objeto=objeto).exists():
        return Response({'error': 'Ya tienes este objeto'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante.puntos -= objeto.precio
    estudiante.save()
    CompraEstudiante.objects.create(estudiante=estudiante, objeto=objeto)

    return Response({'mensaje': '¡Compra realizada!', 'puntos_restantes': estudiante.puntos})


@api_view(['POST'])
def equipar_objeto(request):
    """Equipar un objeto comprado."""
    estudiante_id = request.data.get('estudiante_id')
    compra_id = request.data.get('compra_id')

    compra = get_object_or_404(CompraEstudiante, pk=compra_id, estudiante__id=estudiante_id)
    CompraEstudiante.objects.filter(
        estudiante=compra.estudiante, objeto__categoria=compra.objeto.categoria
    ).update(equipado=False)
    compra.equipado = True
    compra.save()

    return Response({'mensaje': '¡Objeto equipado!'})


# ──────────────────────────── Libros ─────────────────────────────────

@api_view(['GET'])
def lista_libros(request):
    libros = Libro.objects.filter(activo=True)
    edad = request.query_params.get('edad')
    if edad:
        libros = libros.filter(edad_min__lte=int(edad))
    serializer = LibroSerializer(libros, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def libro_detalle(request, slug):
    libro = get_object_or_404(Libro, slug=slug, activo=True)
    serializer = LibroDetailSerializer(libro)
    return Response(serializer.data)


# ──────────────────────────── Actividades ────────────────────────────

@api_view(['POST'])
def guardar_resultado(request):
    estudiante_id = request.data.get('estudiante_id')
    libro_id = request.data.get('libro_id')
    puntos = int(request.data.get('puntos', 0))
    total = int(request.data.get('total', 1))

    if total <= 0:
        return Response({'error': 'Total inválido'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante = get_object_or_404(Estudiante, pk=estudiante_id)
    libro = get_object_or_404(Libro, pk=libro_id)

    completado = puntos >= (total / 2)
    puntos_ganados = puntos * 10

    SesionActividad.objects.create(
        estudiante=estudiante,
        libro=libro,
        puntos_obtenidos=puntos,
        completado=completado,
    )

    estudiante.puntos += puntos_ganados
    estudiante.save()
    estudiante.actualizar_racha()

    _verificar_logros(estudiante)

    return Response({
        'mensaje': '¡Resultado guardado!',
        'puntos_ganados': puntos_ganados,
        'puntos_totales': estudiante.puntos,
        'completado': completado,
        'estrellas': _calcular_estrellas(puntos, total),
    })


def _calcular_estrellas(puntos, total):
    if puntos == 0:
        return 0
    pct = puntos / total if total > 0 else 0
    if pct >= 0.9:
        return 3
    if pct >= 0.5:
        return 2
    return 1


@api_view(['GET'])
def historial_estudiante(request, pk):
    estudiante = get_object_or_404(Estudiante, pk=pk)
    sesiones = (
        SesionActividad.objects
        .filter(estudiante=estudiante)
        .select_related('libro')
        .order_by('-fecha')[:50]
    )
    data = [
        {
            'id': s.id,
            'libro_titulo': s.libro.titulo,
            'libro_slug': s.libro.slug,
            'libro_portada_url': s.libro.portada_url,
            'puntos_obtenidos': s.puntos_obtenidos,
            'completado': s.completado,
            'fecha': s.fecha.isoformat(),
        }
        for s in sesiones
    ]
    return Response(data)


def _verificar_logros(estudiante):
    logros = Logro.objects.filter(puntos_requeridos__lte=estudiante.puntos)
    for logro in logros:
        InsigniaEstudiante.objects.get_or_create(estudiante=estudiante, logro=logro)


@api_view(['GET'])
def juegos_libro(request, slug):
    libro = get_object_or_404(Libro, slug=slug, activo=True)
    try:
        juego = libro.juego
    except LibroJuego.DoesNotExist:
        return Response({'palabras': [], 'oraciones': []})
    serializer = LibroJuegoSerializer(juego)
    return Response(serializer.data)


@api_view(['GET'])
def get_progreso(request, pk):
    estudiante = get_object_or_404(Estudiante, pk=pk)
    libros = Libro.objects.filter(activo=True)
    progreso = []

    for libro in libros:
        total_preguntas = libro.preguntas.filter(edad=estudiante.edad).count()
        sesiones = SesionActividad.objects.filter(
            estudiante=estudiante, libro=libro
        ).order_by('-puntos_obtenidos')

        mejor = sesiones.first()
        intentos = sesiones.count()
        mejor_puntaje = mejor.puntos_obtenidos if mejor else 0
        porcentaje = round(mejor_puntaje / total_preguntas * 100) if total_preguntas > 0 else 0

        progreso.append({
            'libro_id': libro.id,
            'libro_titulo': libro.titulo,
            'libro_slug': libro.slug,
            'libro_portada_url': libro.portada_url,
            'completado': mejor.completado if mejor else False,
            'mejor_puntaje': mejor_puntaje,
            'total_preguntas': total_preguntas,
            'intentos': intentos,
            'porcentaje': min(porcentaje, 100),
        })

    return Response(progreso)


@api_view(['POST'])
def completar_actividad(request):
    """Marcar una actividad (juego) como completada y sumar puntos."""
    tipo = request.data.get('tipo', 'juego')
    
    # Obtener token del header
    auth_header = request.headers.get('Authorization', '')
    token = None
    if auth_header.startswith('Bearer '):
        token = auth_header.split(' ')[1]
    
    if not token:
        # Fallback para desarrollo: permitir estudiante_id directo
        estudiante_id = request.data.get('estudiante_id')
    else:
        try:
            payload = _decode_token(token)
            estudiante_id = payload['sub']
        except Exception:
            return Response({'error': 'Token inválido o expirado'}, status=status.HTTP_401_UNAUTHORIZED)

    if not estudiante_id:
        return Response({'error': 'Estudiante no identificado'}, status=status.HTTP_400_BAD_REQUEST)

    estudiante = get_object_or_404(Estudiante, pk=estudiante_id)
    
    puntos_ganados = 5
        
    estudiante.puntos += puntos_ganados
    estudiante.save()
    estudiante.actualizar_racha()
    
    _verificar_logros(estudiante)

    return Response({
        'mensaje': f'¡Juego {tipo} completado!', 
        'puntos_ganados': puntos_ganados,
        'puntos_totales': estudiante.puntos
    })
