from django.contrib import admin
from .models import Libro, Pregunta

class PreguntaInline(admin.TabularInline):
    model = Pregunta
    extra = 1

@admin.register(Libro)
class LibroAdmin(admin.ModelAdmin):
    list_display = ['titulo', 'slug', 'activo', 'orden']
    inlines = [PreguntaInline]
    prepopulated_fields = {'slug': ('titulo',)}

@admin.register(Pregunta)
class PreguntaAdmin(admin.ModelAdmin):
    list_display = ['libro', 'edad', 'enunciado']
    list_filter = ['edad', 'libro']
