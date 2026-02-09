import 'dart:io';

class OotdPhoto {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final String? note;

  OotdPhoto({
    required this.id,
    required this.filePath,
    required this.createdAt,
    this.note,
  });

  File get file => File(filePath);

  bool get exists => file.existsSync();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  factory OotdPhoto.fromJson(Map<String, dynamic> json) {
    return OotdPhoto(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  OotdPhoto copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    String? note,
  }) {
    return OotdPhoto(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OotdPhoto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
