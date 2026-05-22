from django.contrib import admin
from .models import Estudiante

@admin.register(Estudiante)
class EstudianteAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'edad', 'avatar', 'puntos', 'creado']
    list_filter = ['edad', 'avatar']
    search_fields = ['nombre']
    ordering = ['-puntos']
