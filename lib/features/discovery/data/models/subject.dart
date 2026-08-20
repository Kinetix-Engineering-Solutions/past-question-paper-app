final class Subject {
  const Subject({required this.id, required this.name, required this.slug});

  final String id;
  final String name;
  final String slug;

  factory Subject.fromJson(Map<String, Object?> json) {
    return switch (json) {
      {
        'id': final String id,
        'name': final String name,
        'slug': final String slug,
      }
          when id.isNotEmpty && name.isNotEmpty && slug.isNotEmpty =>
        Subject(id: id, name: name, slug: slug),
      _ => throw const FormatException('Invalid subject response.'),
    };
  }
}
