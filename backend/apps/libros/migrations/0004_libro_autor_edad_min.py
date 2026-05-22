from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('libros', '0003_librojuego'),
    ]

    operations = [
        migrations.AddField(
            model_name='libro',
            name='autor',
            field=models.CharField(blank=True, default='Anónimo', max_length=100),
        ),
        migrations.AddField(
            model_name='libro',
            name='edad_min',
            field=models.IntegerField(choices=[(5, '5 años'), (6, '6 años'), (7, '7 años')], default=5),
        ),
    ]
