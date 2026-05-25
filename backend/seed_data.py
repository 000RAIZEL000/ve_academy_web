import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 've_academy.settings')
django.setup()

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

# Avatares nuevos
for name, key, price in [
    ("Dragón Dorado", "dragon_gold", 800),
    ("Unicornio Rosa", "unicorn_pink", 450),
    ("Robot Ninja", "robot_ninja", 600),
    ("Tiburón Rey", "shark_king", 700),
    ("Hada de Luz", "fairy_light", 500),
    ("Astronauta", "astronaut", 900),
]:
    ObjetoTienda.objects.get_or_create(
        nombre=name, categoria="avatar", precio=price, 
        imagen=f"/static/shop/avatars/{key}.png", emoji="🎭"
    )

# Fondos nuevos
for name, key, price in [
    ("Ciudad Galáctica", "galaxy_city", 400),
    ("Selva Encantada", "magic_jungle", 300),
    ("Castillo de Nubes", "cloud_castle", 350),
    ("Fondo de Cristales", "crystals", 250),
    ("Desierto de Oro", "gold_desert", 450),
]:
    ObjetoTienda.objects.get_or_create(
        nombre=name, categoria="fondo", precio=price, 
        imagen=f"/static/shop/fondos/{key}.png", emoji="🌅"
    )

# Accesorios nuevos
for name, key, price in [
    ("Escudo Diamante", "shield_diamond", 1200),
    ("Capa de Hielo", "cape_ice", 500),
    ("Espada de Juguete", "sword_toy", 300),
    ("Varita Mágica", "wand", 400),
    ("Auriculares Pro", "headphones", 600),
]:
    ObjetoTienda.objects.get_or_create(
        nombre=name, categoria="accesorio", precio=price, 
        imagen=f"/static/shop/accesorios/{key}.png", emoji="🎀"
    )

print("¡Datos de prueba creados con éxito!")
