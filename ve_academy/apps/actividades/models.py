from django.db import models
from apps.libros.models import Libro
from apps.usuarios.models import Estudiante


class SesionActividad(models.Model):
    """Registro de actividades completadas por un estudiante"""
    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name='sesiones')
    libro = models.ForeignKey(Libro, on_delete=models.CASCADE, related_name='sesiones')
    puntos_obtenidos = models.IntegerField(default=0)
    completado = models.BooleanField(default=False)
    fecha = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Sesión de Actividad'
        verbose_name_plural = 'Sesiones de Actividad'
        ordering = ['-fecha']

    def __str__(self):
        return f"{self.estudiante.nombre} - {self.libro.titulo} ({self.puntos_obtenidos} pts)"
