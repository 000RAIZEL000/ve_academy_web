from django.core.management.base import BaseCommand
from apps.libros.models import Libro, Pregunta, LibroJuego


LIBROS_DATA = [
    {
        "slug": "leon_raton",
        "titulo": "El León y el Ratón",
        "portada": "leon_raton.png",
        "texto": "Un león atrapó a un pequeño ratón. El ratón pidió perdón y el león lo dejó ir. Días después, el león quedó atrapado en una red. El ratón escuchó sus rugidos, corrió y con sus dientes rompió la cuerda para liberarlo. El león aprendió que nadie es demasiado pequeño para ayudar.",
        "orden": 1,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Quién ayudó al león a salir de la red?", "opciones": ["El ratón", "La tortuga", "El zorro"], "correcta": 0},
            {"edad": 6, "enunciado": "¿Por qué el león dejó ir al ratón la primera vez?", "opciones": ["Porque tenía sueño", "Porque el ratón le pidió perdón", "Porque tenía hambre"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué enseñanza deja la historia?", "opciones": ["Los grandes no necesitan a los pequeños", "A veces los pequeños pueden ayudar mucho", "Es mejor no perdonar nunca"], "correcta": 1},
        ]
    },
    {
        "slug": "liebre_tortuga",
        "titulo": "La Liebre y la Tortuga",
        "portada": "liebre_tortuga.png",
        "texto": "Una liebre se burlaba de la lentitud de una tortuga. Decidieron hacer una carrera. La liebre era muy rápida, pero se confió y se quedó dormida. La tortuga siguió sin detenerse y ganó. La liebre aprendió a no subestimar a los demás.",
        "orden": 2,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Quién ganó la carrera?", "opciones": ["La liebre", "La tortuga", "Nadie"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué perdió la liebre?", "opciones": ["Porque se perdió", "Porque se detuvo a dormir", "Porque se hizo de noche"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Cuál es la moraleja más cercana?", "opciones": ["Siempre gana el más rápido", "La constancia vale más que la velocidad", "Dormir es malo"], "correcta": 1},
        ]
    },
    {
        "slug": "zorro_uvas",
        "titulo": "El Zorro y las Uvas",
        "portada": "zorro_uvas.png",
        "texto": "Un zorro hambriento vio unas uvas colgando de una parra. Saltó y saltó, pero no logró alcanzarlas. Cansado, se fue diciendo: '¡Están verdes!'. A veces despreciamos lo que no podemos conseguir.",
        "orden": 3,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Qué quería comer el zorro?", "opciones": ["Manzanas", "Uvas", "Peras"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué el zorro dijo que estaban verdes?", "opciones": ["Porque realmente estaban verdes", "Porque no podía alcanzarlas", "Porque no le gustaban"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué actitud muestra el zorro al final?", "opciones": ["Aceptar con calma", "Aprender a trepar", "Despreciar lo que no consiguió"], "correcta": 2},
        ]
    },
    {
        "slug": "hormiga_valiente",
        "titulo": "La Hormiga Valiente",
        "portada": "hormiga_valiente.png",
        "texto": "En un hormiguero muy grande vivía Lina, una hormiga pequeñita. Todas las hormigas cargaban hojas, pero Lina no podía cargar ni una. Un día de lluvia, el río empezó a crecer y el agua llegó hasta la entrada del hormiguero. Todas corrieron asustadas. Lina tuvo una idea: agarró una ramita y la puso como puente para que todas cruzaran al otro lado. Una por una, las hormigas pasaron por el puente de Lina. La reina hormiga la felicitó: '¡No hace falta ser fuerte para ser valiente!'. Desde ese día, Lina se convirtió en la exploradora oficial del hormiguero.",
        "orden": 4,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Cómo se llama la hormiga pequeñita?", "opciones": ["Luna", "Lina", "Lola"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué usó Lina para hacer el puente?", "opciones": ["Una hoja", "Una ramita", "Una piedra"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué pasó cuando llovió mucho?", "opciones": ["Salió el sol", "El río creció", "Cayó nieve"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué las hormigas estaban asustadas?", "opciones": ["Porque vieron un pájaro", "Porque el agua podía inundar el hormiguero", "Porque tenían hambre"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué problema tenía Lina al principio?", "opciones": ["No podía cargar hojas como las demás", "No sabía caminar", "No tenía amigos"], "correcta": 0},
            {"edad": 6, "enunciado": "¿Por qué la reina felicitó a Lina?", "opciones": ["Porque cargó muchas hojas", "Porque salvó al hormiguero con su idea", "Porque corrió muy rápido"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué quiere decir 'no hace falta ser fuerte para ser valiente'?", "opciones": ["Solo los fuertes pueden ayudar", "La valentía no depende del tamaño o la fuerza", "Ser valiente es peligroso"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué cualidad de Lina fue más importante en la emergencia?", "opciones": ["Su fuerza física", "Su inteligencia y creatividad", "Su velocidad"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué hubiera pasado si Lina no hubiera actuado?", "opciones": ["Nada, la lluvia se iba a detener", "El hormiguero se hubiera inundado", "Otra hormiga habría tenido la misma idea"], "correcta": 1},
        ]
    },
    {
        "slug": "pajaro_volar",
        "titulo": "El Pájaro que Aprendió a Volar",
        "portada": "pajaro_volar.png",
        "texto": "Pipo era un gorrión que vivía en un nido alto en un árbol. Todos sus hermanos ya sabían volar, pero Pipo tenía miedo de saltar. '¿Y si me caigo?', pensaba cada mañana. Su mamá le dijo: 'Todos sentimos miedo, pero hay que intentarlo'. Un día, una tormenta sacudió el árbol y el nido empezó a caer. Pipo no tuvo más remedio que abrir las alas. Al principio tembló, pero luego sintió el viento bajo sus plumas. ¡Estaba volando! Dio vueltas alrededor del árbol, subió hasta las nubes y bajó riendo. 'El miedo no desaparece', le dijo su mamá, 'solo aprendes a volar con él'.",
        "orden": 5,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Cómo se llama el pajarito?", "opciones": ["Pepe", "Pipo", "Tito"], "correcta": 1},
            {"edad": 5, "enunciado": "¿De qué tenía miedo Pipo?", "opciones": ["De la oscuridad", "De volar", "Del agua"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué pasó con el nido durante la tormenta?", "opciones": ["Se mojó un poco", "Empezó a caer", "Se hizo más grande"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué Pipo no volaba como sus hermanos?", "opciones": ["Porque no tenía alas", "Porque le daba miedo caerse", "Porque era muy pequeño"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué obligó a Pipo a intentar volar?", "opciones": ["Su mamá lo empujó", "La tormenta sacudió el nido", "Sus hermanos lo retaron"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué sintió Pipo cuando por fin voló?", "opciones": ["Mucho frío", "Alegría y libertad", "Más miedo que antes"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué quiso decir la mamá con 'aprendes a volar con él'?", "opciones": ["Que el miedo nunca se va pero puedes actuar igual", "Que volar es fácil", "Que el miedo es malo"], "correcta": 0},
            {"edad": 7, "enunciado": "¿Qué enseñanza puedes aplicar a tu propia vida?", "opciones": ["Es mejor nunca arriesgarse", "A veces hay que enfrentar el miedo para crecer", "El miedo siempre desaparece solo"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Por qué es importante que Pipo haya volado por necesidad y no por obligación?", "opciones": ["Porque así aprendió más rápido", "Porque nadie puede obligarte a superar tus miedos", "Porque las tormentas son buenas"], "correcta": 1},
        ]
    },
    {
        "slug": "arbol_magico",
        "titulo": "El Árbol Mágico",
        "portada": "arbol_magico.png",
        "texto": "En el centro del bosque había un árbol enorme con hojas de colores brillantes. Los animales decían que era mágico: si le contabas un secreto, te daba un fruto especial. El conejo le contó que se sentía solo. El árbol le dio una manzana dorada. Cuando el conejo la comió, escuchó las voces de otros animales que también se sentían solos. El conejo fue a buscarlos y juntos formaron un grupo de amigos. La ardilla le preguntó al conejo: '¿El árbol te dio magia?'. El conejo sonrió: 'No, me dio el valor de buscar lo que necesitaba'. Desde entonces, los animales visitaban al árbol no por magia, sino para pensar en lo que realmente querían.",
        "orden": 6,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Dónde estaba el árbol mágico?", "opciones": ["En la playa", "En el centro del bosque", "En una montaña"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué animal le contó un secreto al árbol?", "opciones": ["La ardilla", "El conejo", "El oso"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué fruto le dio el árbol al conejo?", "opciones": ["Una pera verde", "Una manzana dorada", "Una naranja"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué secreto le contó el conejo al árbol?", "opciones": ["Que tenía hambre", "Que se sentía solo", "Que quería volar"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué pasó cuando el conejo comió la manzana?", "opciones": ["Se hizo invisible", "Pudo escuchar a otros animales que se sentían solos", "Se convirtió en un árbol"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué los animales seguían visitando al árbol?", "opciones": ["Para pedir más frutos", "Para pensar en lo que realmente querían", "Porque les daba miedo el bosque"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Era realmente mágico el árbol o la magia estaba en otra parte?", "opciones": ["El árbol era totalmente mágico", "La magia estaba en el valor que daba para actuar", "No había ninguna magia"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué quiso decir el conejo con 'me dio el valor de buscar lo que necesitaba'?", "opciones": ["Que la manzana le dio superpoderes", "Que el árbol lo ayudó a darse cuenta y actuar", "Que el conejo ya no necesitaba amigos"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué nos enseña esta historia sobre resolver nuestros problemas?", "opciones": ["Que siempre necesitamos magia", "Que muchas veces la solución está en nosotros mismos", "Que los árboles pueden hablar"], "correcta": 1},
        ]
    },
    {
        "slug": "sol_luna",
        "titulo": "El Sol y la Luna",
        "portada": "sol_luna.png",
        "texto": "El Sol y la Luna eran muy amigos, pero nunca podían verse. Cuando el Sol salía, la Luna se iba a dormir. Cuando la Luna aparecía, el Sol ya se había ido. Un día, el Sol le dejó un mensaje pintado en las nubes del atardecer: 'Te extraño, amiga'. La Luna respondió dibujando estrellas que formaban un corazón. El Sol se puso tan contento que al día siguiente pintó el cielo de rosa, naranja y dorado. Desde entonces, cada atardecer es el momento en que el Sol y la Luna se saludan. Si miras bien el cielo cuando el día se acaba, a veces puedes ver a la Luna asomarse mientras el Sol aún brilla.",
        "orden": 7,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Quiénes son amigos en esta historia?", "opciones": ["El río y la montaña", "El Sol y la Luna", "Las estrellas y las nubes"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué dibujó la Luna con las estrellas?", "opciones": ["Una flor", "Un corazón", "Una casa"], "correcta": 1},
            {"edad": 5, "enunciado": "¿De qué colores pintó el Sol el cielo?", "opciones": ["Azul y verde", "Rosa, naranja y dorado", "Negro y gris"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué el Sol y la Luna no podían verse?", "opciones": ["Porque estaban peleados", "Porque cuando uno salía, el otro se iba", "Porque vivían muy lejos"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Cómo se comunicaron el Sol y la Luna?", "opciones": ["Con un teléfono", "Con mensajes en el cielo: nubes y estrellas", "Gritando muy fuerte"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Qué momento del día representa su saludo?", "opciones": ["La medianoche", "El atardecer", "El mediodía"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué nos enseña esta historia sobre la amistad?", "opciones": ["Los amigos deben estar siempre juntos", "Se puede mantener una amistad aunque no estés cerca", "Solo son amigos los que se ven todos los días"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Por qué el autor dice que el atardecer es un 'saludo'?", "opciones": ["Porque es el único momento en que Sol y Luna comparten el cielo", "Porque el cielo se pone oscuro", "Porque las nubes desaparecen"], "correcta": 0},
            {"edad": 7, "enunciado": "¿Qué sentimiento principal expresa la historia?", "opciones": ["Tristeza porque nunca se ven", "Cariño y creatividad para mantener la amistad", "Enojo porque el Sol brilla más"], "correcta": 1},
        ]
    },
    {
        "slug": "ballena_amiga",
        "titulo": "La Ballena Amiga",
        "portada": "ballena_amiga.png",
        "texto": "En el fondo del mar vivía Azul, una ballena enorme y muy tímida. Los peces pequeños le tenían miedo por su tamaño. Un día, una red de pescadores atrapó a un grupo de peces. Estaban asustados y no podían escapar. Azul escuchó sus gritos y, aunque le daba vergüenza acercarse, nadó hacia la red. Con su cola fuerte rompió las cuerdas y los peces quedaron libres. '¡Gracias, Azul!', gritaron los peces. Un pececito naranja se acercó y le dijo: 'Eres grande por fuera, pero también por dentro'. Desde ese día, Azul jugaba con los peces todos los días y descubrió que ser diferente no significaba estar solo.",
        "orden": 8,
        "preguntas": [
            {"edad": 5, "enunciado": "¿Cómo se llama la ballena?", "opciones": ["Roja", "Azul", "Verde"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué atrapó a los peces?", "opciones": ["Una ola", "Una red", "Un tiburón"], "correcta": 1},
            {"edad": 5, "enunciado": "¿Qué usó Azul para romper la red?", "opciones": ["Su boca", "Su cola", "Sus aletas"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué los peces le tenían miedo a Azul?", "opciones": ["Porque era mala", "Porque era muy grande", "Porque hacía mucho ruido"], "correcta": 1},
            {"edad": 6, "enunciado": "¿Por qué a Azul le daba vergüenza acercarse?", "opciones": ["Porque era tímida y temía asustarlos", "Porque no sabía nadar bien", "Porque estaba enojada"], "correcta": 0},
            {"edad": 6, "enunciado": "¿Qué cambió después de que Azul salvó a los peces?", "opciones": ["Los peces se fueron lejos", "Azul y los peces se hicieron amigos", "Azul se fue a otro mar"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué quiso decir el pececito con 'eres grande por fuera, pero también por dentro'?", "opciones": ["Que Azul come mucho", "Que Azul tiene un corazón bondadoso y generoso", "Que Azul es más grande que los demás animales"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Qué nos enseña la historia sobre juzgar a otros por su apariencia?", "opciones": ["Es correcto tener miedo de los que son diferentes", "No debemos juzgar a alguien solo por cómo se ve", "Los grandes siempre dan miedo"], "correcta": 1},
            {"edad": 7, "enunciado": "¿Por qué es importante que Azul haya superado su timidez?", "opciones": ["Porque así pudo presumir", "Porque gracias a eso salvó a los peces y ganó amigos", "Porque los tímidos no pueden tener amigos"], "correcta": 1},
        ]
    },
]

JUEGOS_DATA = {
    "leon_raton": {
        "palabras": [
            {"word": "LEON", "emoji": "🦁"},
            {"word": "RATON", "emoji": "🐭"},
            {"word": "RED", "emoji": "🕸️"},
            {"word": "PERDON", "emoji": "🙏"},
            {"word": "CUERDA", "emoji": "🔗"},
        ],
        "oraciones": [
            "El ratón ayudó al león",
            "El ratón rompió la red",
        ],
    },
    "liebre_tortuga": {
        "palabras": [
            {"word": "LIEBRE", "emoji": "🐰"},
            {"word": "TORTUGA", "emoji": "🐢"},
            {"word": "CARRERA", "emoji": "🏁"},
            {"word": "DORMIR", "emoji": "💤"},
            {"word": "RAPIDA", "emoji": "💨"},
        ],
        "oraciones": [
            "La tortuga ganó la carrera",
            "La liebre se quedó dormida",
        ],
    },
    "zorro_uvas": {
        "palabras": [
            {"word": "ZORRO", "emoji": "🦊"},
            {"word": "UVAS", "emoji": "🍇"},
            {"word": "SALTAR", "emoji": "🦘"},
            {"word": "VERDE", "emoji": "🌿"},
            {"word": "PARRA", "emoji": "🌱"},
        ],
        "oraciones": [
            "El zorro quería comer las uvas",
            "Las uvas estaban muy altas",
        ],
    },
    "hormiga_valiente": {
        "palabras": [
            {"word": "HORMIGA", "emoji": "🐜"},
            {"word": "PUENTE", "emoji": "🌉"},
            {"word": "LLUVIA", "emoji": "🌧️"},
            {"word": "RAMITA", "emoji": "🌿"},
            {"word": "REINA", "emoji": "👑"},
        ],
        "oraciones": [
            "Lina salvó al hormiguero",
            "El río creció con la lluvia",
        ],
    },
    "pajaro_volar": {
        "palabras": [
            {"word": "PAJARO", "emoji": "🐦"},
            {"word": "VOLAR", "emoji": "✈️"},
            {"word": "MIEDO", "emoji": "😨"},
            {"word": "NIDO", "emoji": "🪺"},
            {"word": "PIPO", "emoji": "⭐"},
        ],
        "oraciones": [
            "Pipo aprendió a volar",
            "La tormenta sacudió el nido",
        ],
    },
    "arbol_magico": {
        "palabras": [
            {"word": "ARBOL", "emoji": "🌳"},
            {"word": "CONEJO", "emoji": "🐰"},
            {"word": "MANZANA", "emoji": "🍎"},
            {"word": "AMIGOS", "emoji": "👫"},
            {"word": "SECRETO", "emoji": "🤫"},
        ],
        "oraciones": [
            "El conejo se sentía solo",
            "El árbol le dio una manzana",
        ],
    },
    "sol_luna": {
        "palabras": [
            {"word": "SOL", "emoji": "☀️"},
            {"word": "LUNA", "emoji": "🌙"},
            {"word": "NUBES", "emoji": "☁️"},
            {"word": "CIELO", "emoji": "🌤️"},
            {"word": "ROSA", "emoji": "🌹"},
        ],
        "oraciones": [
            "El Sol y la Luna eran amigos",
            "La Luna dibujó un corazón",
        ],
    },
    "ballena_amiga": {
        "palabras": [
            {"word": "BALLENA", "emoji": "🐋"},
            {"word": "PECES", "emoji": "🐠"},
            {"word": "COLA", "emoji": "🌊"},
            {"word": "AZUL", "emoji": "💙"},
            {"word": "TIMIDA", "emoji": "😳"},
        ],
        "oraciones": [
            "Azul rompió la red con su cola",
            "Los peces se hicieron amigos",
        ],
    },
}


class Command(BaseCommand):
    help = 'Pobla la base de datos con los libros, preguntas y juegos de V&E Academy'

    def handle(self, *args, **kwargs):
        for libro_data in LIBROS_DATA:
            libro, created = Libro.objects.update_or_create(
                slug=libro_data['slug'],
                defaults={
                    'titulo': libro_data['titulo'],
                    'portada': libro_data['portada'],
                    'texto': libro_data['texto'],
                    'orden': libro_data['orden'],
                    'autor': libro_data.get('autor', 'Anónimo'),
                    'edad_min': libro_data.get('edad_min', 5),
                    'activo': True,
                }
            )
            action = 'Creado' if created else 'Actualizado'
            self.stdout.write(f"  {action}: {libro.titulo}")

            Pregunta.objects.filter(libro=libro).delete()
            for pq in libro_data['preguntas']:
                Pregunta.objects.create(
                    libro=libro,
                    edad=pq['edad'],
                    enunciado=pq['enunciado'],
                    opcion_a=pq['opciones'][0],
                    opcion_b=pq['opciones'][1],
                    opcion_c=pq['opciones'][2],
                    correcta=pq['correcta'],
                )

            # Crear/actualizar juego del libro
            juego_data = JUEGOS_DATA.get(libro_data['slug'])
            if juego_data:
                LibroJuego.objects.update_or_create(
                    libro=libro,
                    defaults={
                        'palabras': juego_data['palabras'],
                        'oraciones': juego_data['oraciones'],
                    }
                )
                self.stdout.write(f"    Juego configurado para: {libro.titulo}")

        self.stdout.write(self.style.SUCCESS('Base de datos poblada exitosamente!'))
