from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_exempt
import json

from apps.usuarios.models import Estudiante
from apps.libros.models import Libro, Pregunta
from .models import SesionActividad


def _get_estudiante(request):
    est_id = request.session.get('estudiante_id')
    if not est_id:
        return None
    try:
        return Estudiante.objects.get(id=est_id)
    except Estudiante.DoesNotExist:
        return None


def actividades(request, slug):
    estudiante = _get_estudiante(request)
    if not estudiante:
        return redirect('home')

    libro = get_object_or_404(Libro, slug=slug, activo=True)
    preguntas = Pregunta.objects.filter(libro=libro, edad=estudiante.edad)

    if not preguntas.exists():
        # Si no hay preguntas para esa edad, buscar las más cercanas
        preguntas = Pregunta.objects.filter(libro=libro).order_by('edad')

    preguntas_data = []
    for p in preguntas:
        preguntas_data.append({
            'id': p.id,
            'enunciado': p.enunciado,
            'opciones': p.opciones,
            'correcta': p.correcta,
        })

    return render(request, 'actividades/actividades.html', {
        'libro': libro,
        'estudiante': estudiante,
        'preguntas_json': json.dumps(preguntas_data),
        'total_preguntas': len(preguntas_data),
    })


@require_POST
def guardar_resultado(request):
    """Guardar resultado final de actividad"""
    estudiante = _get_estudiante(request)
    if not estudiante:
        return JsonResponse({'ok': False, 'msg': 'Sin sesión'})

    data = json.loads(request.body)
    slug = data.get('libro_slug')
    puntos = int(data.get('puntos', 0))
    completado = data.get('completado', False)

    try:
        libro = Libro.objects.get(slug=slug)
    except Libro.DoesNotExist:
        return JsonResponse({'ok': False})

    SesionActividad.objects.create(
        estudiante=estudiante,
        libro=libro,
        puntos_obtenidos=puntos,
        completado=completado,
    )

    estudiante.puntos += puntos
    estudiante.save()

    return JsonResponse({'ok': True, 'puntos_totales': estudiante.puntos})


def puntaje(request):
    estudiante = _get_estudiante(request)
    if not estudiante:
        return redirect('home')

    sesiones = SesionActividad.objects.filter(estudiante=estudiante).order_by('-fecha')[:10]
    top = Estudiante.objects.order_by('-puntos')[:5]

    return render(request, 'actividades/puntaje.html', {
        'estudiante': estudiante,
        'sesiones': sesiones,
        'top': top,
    })
