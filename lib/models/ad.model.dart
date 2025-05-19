class AdModel {
  final String? background;
  final String? logo;
  final String title;
  final String subtitle;
  final String button;
  final String url;

  AdModel({
    required this.background,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.url,
  });

  factory AdModel.fromJson(dynamic json) {
    return AdModel(
      background: json['background'],
      logo: json['logo'],
      title: json['title'],
      subtitle: json['subtitle'],
      button: json['button'],
      url: json['url'],
    );
  }
}
