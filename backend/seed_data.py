from apps.usuarios.models import Logro, ObjetoTienda

# Crear Logros
Logro.objects.get_or_create(
    nombre="Primeras Letras",
    descripcion="¡Has leído tu primer libro!",
    icono="📖",
    puntos_requeridos=100
)
Logro.objects.get_or_create(
    nombre="Racha de Bronce",
    descripcion="Mantén tu racha por 3 días seguidos",
    icono="🥉",
    puntos_requeridos=300
)
Logro.objects.get_or_create(
    nombre="Maestro Lector",
    descripcion="Has completado 5 cuentos",
    icono="🎓",
    puntos_requeridos=500
)

# Crear Objetos de la Tienda
ObjetoTienda.objects.get_or_create(
    nombre="Panda Guerrero",
    categoria="avatar",
    precio=200,
    imagen="/static/img/avatars/panda_warrior.png"
)
ObjetoTienda.objects.get_or_create(
    nombre="Gato Espacial",
    categoria="avatar",
    precio=250,
    imagen="/static/img/avatars/space_cat.png"
)
ObjetoTienda.objects.get_or_create(
    nombre="Bosque Encantado",
    categoria="fondo",
    precio=400,
    imagen="/static/img/backgrounds/enchanted_forest.png"
)
ObjetoTienda.objects.get_or_create(
    nombre="Capa de Héroe",
    categoria="accesorio",
    precio=150,
    imagen="/static/img/accessories/hero_cape.png"
)

print("¡Datos de prueba creados con éxito!")
