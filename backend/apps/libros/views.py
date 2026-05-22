from django.shortcuts import render, redirect, get_object_or_404
from apps.usuarios.models import Estudiante
from .models import Libro


def _get_estudiante(request):
    est_id = request.session.get('estudiante_id')
    if not est_id:
        return None
    try:
        return Estudiante.objects.get(id=est_id)
    except Estudiante.DoesNotExist:
        return None


def lista(request):
    estudiante = _get_estudiante(request)
    if not estudiante:
        return redirect('home')

    libros = Libro.objects.filter(activo=True)
    return render(request, 'libros/lista.html', {
        'libros': libros,
        'estudiante': estudiante,
    })


def lectura(request, slug):
    estudiante = _get_estudiante(request)
    if not estudiante:
        return redirect('home')

    libro = get_object_or_404(Libro, slug=slug, activo=True)
    return render(request, 'libros/lectura.html', {
        'libro': libro,
        'estudiante': estudiante,
    })
