from django.db import models


class Libro(models.Model):
    slug = models.SlugField(unique=True)
    titulo = models.CharField(max_length=200)
    autor = models.CharField(max_length=100, default='Anónimo', blank=True)
    texto = models.TextField()
    portada = models.CharField(max_length=100)
    activo = models.BooleanField(default=True)
    orden = models.IntegerField(default=0)
    edad_min = models.IntegerField(choices=[(5, '5 años'), (6, '6 años'), (7, '7 años')], default=5)

    class Meta:
        ordering = ['orden']
        verbose_name = 'Libro'
        verbose_name_plural = 'Libros'

    def __str__(self):
        return self.titulo

    @property
    def portada_url(self):
        return f"/static/img/covers/{self.portada}"


class Pregunta(models.Model):
    TIPOS = [('multiple', 'Opción Múltiple'), ('completar', 'Completar Frase')]

    libro = models.ForeignKey(Libro, related_name='preguntas', on_delete=models.CASCADE)
    edad = models.IntegerField(choices=[(5, '5 años'), (6, '6 años'), (7, '7 años')])
    tipo = models.CharField(max_length=20, choices=TIPOS, default='multiple')
    dificultad = models.IntegerField(default=1)

    enunciado = models.TextField()
    opcion_a = models.CharField(max_length=200)
    opcion_b = models.CharField(max_length=200)
    opcion_c = models.CharField(max_length=200)
    correcta = models.IntegerField(choices=[(0, 'A'), (1, 'B'), (2, 'C')])

    class Meta:
        ordering = ['edad']
        verbose_name = 'Pregunta'
        verbose_name_plural = 'Preguntas'

    def __str__(self):
        return f"{self.libro.titulo} | Edad {self.edad}: {self.enunciado[:50]}"

    @property
    def opciones(self):
        return [self.opcion_a, self.opcion_b, self.opcion_c]


class LibroJuego(models.Model):
    libro = models.OneToOneField(Libro, related_name='juego', on_delete=models.CASCADE)
    palabras = models.JSONField(default=list)
    oraciones = models.JSONField(default=list)
    adivinanzas = models.JSONField(default=list)

    def __str__(self):
        return f"Juego: {self.libro.titulo}"
