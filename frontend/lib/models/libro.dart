class Libro {
  final int id;
  final String slug;
  final String titulo;
  final String texto;
  final String portadaUrl;
  final List<Pregunta> preguntas;

  Libro({
    required this.id,
    required this.slug,
    required this.titulo,
    required this.texto,
    required this.portadaUrl,
    required this.preguntas,
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    var list = json['preguntas'] as List? ?? [];
    List<Pregunta> preguntasList = list.map((i) => Pregunta.fromJson(i)).toList();

    return Libro(
      id: json['id'],
      slug: json['slug'],
      titulo: json['titulo'],
      texto: json['texto'],
      portadaUrl: json['portada_url'],
      preguntas: preguntasList,
    );
  }
}

class Pregunta {
  final int id;
  final int edad;
  final String enunciado;
  final List<String> opciones;
  final int correcta;

  Pregunta({
    required this.id,
    required this.edad,
    required this.enunciado,
    required this.opciones,
    required this.correcta,
  });

  factory Pregunta.fromJson(Map<String, dynamic> json) {
    return Pregunta(
      id: json['id'],
      edad: json['edad'],
      enunciado: json['enunciado'],
      opciones: List<String>.from(json['opciones']),
      correcta: json['correcta'],
    );
  }
}
