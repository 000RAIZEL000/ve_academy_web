from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('usuarios', '0002_logro_objetotienda_estudiante_max_racha_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='estudiante',
            name='email',
            field=models.EmailField(blank=True, max_length=254, null=True, unique=True),
        ),
        migrations.AddField(
            model_name='estudiante',
            name='password_hash',
            field=models.CharField(blank=True, max_length=128, null=True),
        ),
        migrations.AddField(
            model_name='objetotienda',
            name='emoji',
            field=models.CharField(default='🎁', max_length=10),
        ),
        migrations.AddField(
            model_name='compraestudiante',
            name='equipado',
            field=models.BooleanField(default=False),
        ),
    ]
