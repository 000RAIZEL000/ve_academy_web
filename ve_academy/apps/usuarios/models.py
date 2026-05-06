from django.db import models


AVATAR_CHOICES = [
    ('conejo', 'Conejo'),
    ('gato', 'Gato'),
    ('lechuza', 'Lechuza'),
    ('leon', 'León'),
    ('oso', 'Oso'),
    ('panda', 'Panda'),
    ('Perico', 'Perico'),
    ('tigre', 'Tigre'),
    ('zorro', 'Zorro'),
]

EDAD_CHOICES = [(5, '5 años'), (6, '6 años'), (7, '7 años')]


class Estudiante(models.Model):
    nombre = models.CharField(max_length=100, unique=True)
    edad = models.IntegerField(choices=EDAD_CHOICES, default=5)
    avatar = models.CharField(max_length=20, choices=AVATAR_CHOICES, default='panda')
    puntos = models.IntegerField(default=0)
    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Estudiante'
        verbose_name_plural = 'Estudiantes'
        ordering = ['-puntos']

    def __str__(self):
        return f"{self.nombre} ({self.edad} años) - {self.puntos} pts"

    @property
    def avatar_url(self):
        return f"/static/img/avatars/{self.avatar}.png"
