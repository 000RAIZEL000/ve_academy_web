from django.db import models


class Libro(models.Model):
    slug = models.SlugField(unique=True)
    titulo = models.CharField(max_length=200)
    texto = models.TextField()
    portada = models.CharField(max_length=100)  # nombre del archivo en static
    activo = models.BooleanField(default=True)
    orden = models.IntegerField(default=0)

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
    libro = models.ForeignKey(Libro, related_name='preguntas', on_delete=models.CASCADE)
    edad = models.IntegerField(choices=[(5, '5 años'), (6, '6 años'), (7, '7 años')])
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
