from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from django.views.decorators.http import require_POST
import json
from .models import Estudiante, AVATAR_CHOICES


def home(request):
    """Pantalla de inicio / registro"""
    if request.session.get('estudiante_id'):
        return redirect('libros:lista')
    
    avatares = [a[0] for a in AVATAR_CHOICES]
    return render(request, 'usuarios/registro.html', {
        'avatares': avatares,
        'edades': [5, 6, 7],
    })


def registro(request):
    """Registrar o cargar usuario existente"""
    if request.method == 'POST':
        nombre = request.POST.get('nombre', '').strip()
        edad = int(request.POST.get('edad', 5))
        avatar = request.POST.get('avatar', 'panda')

        if not nombre or edad not in [5, 6, 7]:
            return redirect('home')

        estudiante, created = Estudiante.objects.get_or_create(
            nombre__iexact=nombre,
            defaults={'nombre': nombre, 'edad': edad, 'avatar': avatar, 'puntos': 0}
        )
        if not created:
            estudiante.edad = edad
            estudiante.avatar = avatar
            estudiante.save()

        request.session['estudiante_id'] = estudiante.id
        request.session['estudiante_nombre'] = estudiante.nombre
        return redirect('libros:lista')

    return redirect('home')


def cerrar_sesion(request):
    request.session.flush()
    return redirect('home')


def ranking(request):
    """Tabla de puntaje / ranking"""
    top = Estudiante.objects.order_by('-puntos')[:20]
    estudiante_id = request.session.get('estudiante_id')
    return render(request, 'usuarios/ranking.html', {
        'top': top,
        'estudiante_id': estudiante_id,
    })


def api_sumar_puntos(request):
    """API endpoint para sumar puntos via AJAX"""
    if request.method == 'POST':
        data = json.loads(request.body)
        delta = int(data.get('puntos', 0))
        est_id = request.session.get('estudiante_id')
        if est_id and delta > 0:
            try:
                est = Estudiante.objects.get(id=est_id)
                est.puntos += delta
                est.save()
                return JsonResponse({'ok': True, 'puntos': est.puntos})
            except Estudiante.DoesNotExist:
                pass
    return JsonResponse({'ok': False})
