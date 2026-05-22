from django.db import models
from django.utils import timezone
from datetime import timedelta
from django.contrib.auth.hashers import make_password, check_password as _check_password


AVATAR_CHOICES = [
    ('conejo', 'Conejo'),
    ('gato', 'Gato'),
    ('lechuza', 'Lechuza'),
    ('leon', 'León'),
    ('oso', 'Oso'),
    ('panda', 'Panda'),
    ('perico', 'Perico'),
    ('tigre', 'Tigre'),
    ('zorro', 'Zorro'),
]

EDAD_CHOICES = [(5, '5 años'), (6, '6 años'), (7, '7 años')]

AVATAR_EMOJIS = {
    'conejo': '🐰', 'gato': '🐱', 'lechuza': '🦉', 'leon': '🦁',
    'oso': '🐻', 'panda': '🐼', 'perico': '🦜', 'tigre': '🐯', 'zorro': '🦊',
}


class Estudiante(models.Model):
    nombre = models.CharField(max_length=100, unique=True)
    edad = models.IntegerField(choices=EDAD_CHOICES, default=5)
    avatar = models.CharField(max_length=20, choices=AVATAR_CHOICES, default='panda')
    puntos = models.IntegerField(default=0)

    # Autenticación por email
    email = models.EmailField(unique=True, null=True, blank=True)
    password_hash = models.CharField(max_length=128, null=True, blank=True)

    # Sistema de Rachas
    racha_actual = models.IntegerField(default=0)
    max_racha = models.IntegerField(default=0)
    ultima_actividad = models.DateField(null=True, blank=True)

    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)

    def set_password(self, raw_password):
        self.password_hash = make_password(raw_password)

    def check_password(self, raw_password):
        return _check_password(raw_password, self.password_hash or '')

    def actualizar_racha(self):
        hoy = timezone.now().date()
        if self.ultima_actividad == hoy:
            return
        if self.ultima_actividad == hoy - timedelta(days=1):
            self.racha_actual += 1
        else:
            self.racha_actual = 1
        if self.racha_actual > self.max_racha:
            self.max_racha = self.racha_actual
        self.ultima_actividad = hoy
        self.save()

    class Meta:
        verbose_name = 'Estudiante'
        verbose_name_plural = 'Estudiantes'
        ordering = ['-puntos']

    def __str__(self):
        return f"{self.nombre} ({self.edad} años) - {self.puntos} pts"

    @property
    def avatar_url(self):
        return f"/static/img/avatars/{self.avatar}.png"

    @property
    def avatar_emoji(self):
        return AVATAR_EMOJIS.get(self.avatar, '🐼')


class Logro(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField()
    icono = models.CharField(max_length=50)
    puntos_requeridos = models.IntegerField(default=0)

    def __str__(self):
        return self.nombre


class InsigniaEstudiante(models.Model):
    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name='insignias')
    logro = models.ForeignKey(Logro, on_delete=models.CASCADE)
    fecha_obtenida = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('estudiante', 'logro')


class ObjetoTienda(models.Model):
    CATEGORIAS = [('avatar', 'Avatar'), ('fondo', 'Fondo'), ('accesorio', 'Accesorio')]
    nombre = models.CharField(max_length=100)
    categoria = models.CharField(max_length=20, choices=CATEGORIAS)
    precio = models.IntegerField()
    imagen = models.CharField(max_length=100)
    emoji = models.CharField(max_length=10, default='🎁')

    def __str__(self):
        return f"{self.nombre} ({self.precio} pts)"


class CompraEstudiante(models.Model):
    estudiante = models.ForeignKey(Estudiante, on_delete=models.CASCADE, related_name='compras')
    objeto = models.ForeignKey(ObjetoTienda, on_delete=models.CASCADE)
    fecha_compra = models.DateTimeField(auto_now_add=True)
    equipado = models.BooleanField(default=False)
