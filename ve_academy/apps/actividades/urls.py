from django.urls import path
from . import views

app_name = 'actividades'

urlpatterns = [
    path('<slug:slug>/', views.actividades, name='actividades'),
    path('api/guardar/', views.guardar_resultado, name='guardar'),
    path('puntaje/', views.puntaje, name='puntaje'),
]
