class GameWord {
  final String word;
  final String emoji;

  const GameWord({required this.word, required this.emoji});

  factory GameWord.fromJson(Map<String, dynamic> json) => GameWord(
        word: (json['word'] as String).toUpperCase(),
        emoji: json['emoji'] as String,
      );
}

class BookGameData {
  final List<GameWord> palabras;
  final List<String> oraciones;

  const BookGameData({required this.palabras, required this.oraciones});

  factory BookGameData.fromJson(Map<String, dynamic> json) {
    return BookGameData(
      palabras: (json['palabras'] as List? ?? [])
          .map((p) => GameWord.fromJson(p as Map<String, dynamic>))
          .toList(),
      oraciones: (json['oraciones'] as List? ?? [])
          .map((o) => o as String)
          .toList(),
    );
  }

  bool get isEmpty => palabras.isEmpty && oraciones.isEmpty;
}
