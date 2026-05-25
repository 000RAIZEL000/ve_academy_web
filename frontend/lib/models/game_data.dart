class GameWord {
  final String word;
  final String emoji;

  const GameWord({required this.word, required this.emoji});

  factory GameWord.fromJson(Map<String, dynamic> json) => GameWord(
        word: (json['word'] as String).toUpperCase(),
        emoji: json['emoji'] as String,
      );
}

class Riddle {
  final String question;
  final String answer;
  final List<String> options;

  const Riddle({required this.question, required this.answer, required this.options});

  factory Riddle.fromJson(Map<String, dynamic> json) => Riddle(
        question: json['pregunta'] as String,
        answer: (json['respuesta'] as String).toUpperCase(),
        options: (json['opciones'] as List).map((o) => (o as String).toUpperCase()).toList(),
      );
}

class BookGameData {
  final List<GameWord> palabras;
  final List<String> oraciones;
  final List<Riddle> adivinanzas;

  const BookGameData({required this.palabras, required this.oraciones, required this.adivinanzas});

  factory BookGameData.fromJson(Map<String, dynamic> json) {
    return BookGameData(
      palabras: (json['palabras'] as List? ?? [])
          .map((p) => GameWord.fromJson(p as Map<String, dynamic>))
          .toList(),
      oraciones: (json['oraciones'] as List? ?? [])
          .map((o) => o as String)
          .toList(),
      adivinanzas: (json['adivinanzas'] as List? ?? [])
          .map((a) => Riddle.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isEmpty => palabras.isEmpty && oraciones.isEmpty && adivinanzas.isEmpty;
}
