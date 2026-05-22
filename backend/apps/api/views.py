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
def login_estudiante(request):
    """Registrar o iniciar sesión desde Flutter. Devuelve datos + JWT."""
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
    """Verificar JWT almacenado en el dispositivo y devolver datos actualizados."""
    token = request.data.get('token', '')
    if not token:
        return Response({'error': 'Token requerido'}, status=status.HTTP_400_BAD_REQUEST)
    try:
        payload = _decode_token(token)
        estudiante = get_object_or_404(Estudiante, pk=payload['sub'])
        estudiante.actualizar_racha()
        serializer = EstudianteDetailSerializer(estudiante)
        data = dict(serializer.data)
        data['token'] = token  # devolver el mismo token (aún vigente)
        return Response(data)
    except jwt.ExpiredSignatureError:
        return Response({'error': 'Token expirado'}, status=status.HTTP_401_UNAUTHORIZED)
    except jwt.InvalidTokenError:
        return Response({'error': 'Token inválido'}, status=status.HTTP_401_UNAUTHORIZED)


# ──────────────────────────── Estudiantes ────────────────────────────

@api_view(['GET'])
def estudiante_detalle(request, pk):
    """Datos completos del estudiante, actualiza racha."""
    estudiante = get_object_or_404(Estudiante, pk=pk)
    estudiante.actualizar_racha()
    serializer = EstudianteDetailSerializer(estudiante)
    return Response(serializer.data)


@api_view(['GET'])
def ranking(request):
    """Top-10 global o filtrado por edad."""
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
    """Canjear objeto de tienda con puntos del estudiante."""
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

    return Response({'mensaje': '¡Compra realizada con éxito!', 'puntos_restantes': estudiante.puntos})


# ──────────────────────────── Libros ─────────────────────────────────

@api_view(['GET'])
def lista_libros(request):
    """Lista todos los libros activos (sin preguntas para aligerar la respuesta)."""
    libros = Libro.objects.filter(activo=True)
    serializer = LibroSerializer(libros, many=True)
    return Response(serializer.data)


@api_view(['GET'])
def libro_detalle(request, slug):
    """Detalle de un libro incluyendo todas sus preguntas."""
    libro = get_object_or_404(Libro, slug=slug, activo=True)
    serializer = LibroDetailSerializer(libro)
    return Response(serializer.data)


# ──────────────────────────── Actividades ────────────────────────────

@api_view(['POST'])
def guardar_resultado(request):
    """
    Guardar el resultado de un quiz.
    Premia puntos, actualiza racha y desbloquea logros automáticamente.
    """
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
    })


@api_view(['GET'])
def historial_estudiante(request, pk):
    """Últimas 50 actividades del estudiante."""
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
    """Desbloquea automáticamente los logros que el estudiante ya merece."""
    logros = Logro.objects.filter(puntos_requeridos__lte=estudiante.puntos)
    for logro in logros:
        InsigniaEstudiante.objects.get_or_create(estudiante=estudiante, logro=logro)


@api_view(['GET'])
def juegos_libro(request, slug):
    """Datos de mini juegos para un libro (palabras y oraciones)."""
    libro = get_object_or_404(Libro, slug=slug, activo=True)
    try:
        juego = libro.juego
    except LibroJuego.DoesNotExist:
        return Response({'palabras': [], 'oraciones': []})
    serializer = LibroJuegoSerializer(juego)
    return Response(serializer.data)


@api_view(['GET'])
def get_progreso(request, pk):
    """
    Devuelve el progreso del estudiante en cada libro activo.
    Incluye: completado, mejor_puntaje, total_preguntas, porcentaje, intentos.
    """
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
            'libro_slug': libro.slug,
            'completado': mejor.completado if mejor else False,
            'mejor_puntaje': mejor_puntaje,
            'total_preguntas': total_preguntas,
            'intentos': intentos,
            'porcentaje': min(porcentaje, 100),
        })

    return Response(progreso)
