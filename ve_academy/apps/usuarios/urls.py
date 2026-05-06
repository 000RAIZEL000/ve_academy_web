from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('registro/', views.registro, name='registro'),
    path('salir/', views.cerrar_sesion, name='cerrar_sesion'),
    path('ranking/', views.ranking, name='ranking'),
    path('api/puntos/', views.api_sumar_puntos, name='api_puntos'),
]
