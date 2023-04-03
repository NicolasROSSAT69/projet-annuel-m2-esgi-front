class LegalMentions {
  final String title;
  final List<Section> content;

  LegalMentions({required this.title, required this.content});

  factory LegalMentions.fromJson(Map<String, dynamic> json) {
    return LegalMentions(
      title: json['title'],
      content: (json['content'] as List)
          .map((section) => Section.fromJson(section))
          .toList(),
    );
  }
}

class Section {
  final String title;
  final String text;

  Section({required this.title, required this.text});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json['title'],
      text: json['text'],
    );
  }
}
