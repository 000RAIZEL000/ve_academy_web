from django.contrib import admin
from .models import SesionActividad

@admin.register(SesionActividad)
class SesionActividadAdmin(admin.ModelAdmin):
    list_display = ['estudiante', 'libro', 'puntos_obtenidos', 'completado', 'fecha']
    list_filter = ['completado', 'libro']
    ordering = ['-fecha']
