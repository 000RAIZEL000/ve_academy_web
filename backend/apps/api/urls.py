from django.urls import path
from . import views

urlpatterns = [
    # Auth
    path('login/', views.login_estudiante, name='api_login'),
    path('verify-token/', views.verify_token, name='api_verify_token'),

    # Estudiantes
    path('estudiante/<int:pk>/', views.estudiante_detalle, name='api_estudiante_detalle'),
    path('ranking/', views.ranking, name='api_ranking'),

    # Logros y Tienda
    path('logros/', views.lista_logros, name='api_logros'),
    path('tienda/', views.lista_tienda, name='api_tienda'),
    path('comprar/', views.comprar_objeto, name='api_comprar'),

    # Libros
    path('libros/', views.lista_libros, name='api_libros'),
    path('libros/<slug:slug>/', views.libro_detalle, name='api_libro_detalle'),
    path('juegos/<slug:slug>/', views.juegos_libro, name='api_juegos'),

    # Actividades
    path('guardar/', views.guardar_resultado, name='api_guardar'),
    path('progreso/<int:pk>/', views.get_progreso, name='api_progreso'),
    path('historial/<int:pk>/', views.historial_estudiante, name='api_historial'),
]
