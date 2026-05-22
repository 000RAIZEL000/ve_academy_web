from rest_framework import serializers
from apps.usuarios.models import Estudiante, Logro, InsigniaEstudiante, ObjetoTienda, CompraEstudiante
from apps.libros.models import Libro, Pregunta, LibroJuego


class LogroSerializer(serializers.ModelSerializer):
    class Meta:
        model = Logro
        fields = '__all__'


class InsigniaSerializer(serializers.ModelSerializer):
    logro = LogroSerializer(read_only=True)

    class Meta:
        model = InsigniaEstudiante
        fields = ['id', 'logro', 'fecha_obtenida']


class ObjetoTiendaSerializer(serializers.ModelSerializer):
    class Meta:
        model = ObjetoTienda
        fields = '__all__'


class CompraSerializer(serializers.ModelSerializer):
    objeto = ObjetoTiendaSerializer(read_only=True)

    class Meta:
        model = CompraEstudiante
        fields = ['id', 'objeto', 'fecha_compra']


class EstudianteDetailSerializer(serializers.ModelSerializer):
    insignias = InsigniaSerializer(many=True, read_only=True)
    compras = CompraSerializer(many=True, read_only=True)

    class Meta:
        model = Estudiante
        fields = [
            'id', 'nombre', 'edad', 'avatar', 'avatar_url',
            'puntos', 'racha_actual', 'max_racha',
            'insignias', 'compras',
        ]


class PreguntaSerializer(serializers.ModelSerializer):
    opciones = serializers.ReadOnlyField()

    class Meta:
        model = Pregunta
        fields = ['id', 'edad', 'enunciado', 'opciones', 'correcta']


class LibroSerializer(serializers.ModelSerializer):
    class Meta:
        model = Libro
        fields = ['id', 'titulo', 'slug', 'texto', 'portada_url', 'activo']


class LibroDetailSerializer(serializers.ModelSerializer):
    preguntas = PreguntaSerializer(many=True, read_only=True)

    class Meta:
        model = Libro
        fields = ['id', 'titulo', 'slug', 'texto', 'portada_url', 'activo', 'preguntas']


class LibroJuegoSerializer(serializers.ModelSerializer):
    class Meta:
        model = LibroJuego
        fields = ['palabras', 'oraciones']
