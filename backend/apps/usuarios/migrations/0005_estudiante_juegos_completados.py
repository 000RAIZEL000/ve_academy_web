from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('usuarios', '0004_alter_estudiante_avatar'),
    ]

    operations = [
        migrations.AddField(
            model_name='estudiante',
            name='juegos_completados',
            field=models.IntegerField(default=0),
        ),
    ]
