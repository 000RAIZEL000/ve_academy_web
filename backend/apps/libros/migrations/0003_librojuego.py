import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('libros', '0002_pregunta_dificultad_pregunta_tipo'),
    ]

    operations = [
        migrations.CreateModel(
            name='LibroJuego',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('palabras', models.JSONField(default=list)),
                ('oraciones', models.JSONField(default=list)),
                ('libro', models.OneToOneField(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='juego',
                    to='libros.libro',
                )),
            ],
        ),
    ]
