class AdModel {
  final int version;
  final String? background;
  final String? logo;
  final String title;
  final String subtitle;
  final String button;
  final String url;
  final List<String> cities;
  final String place;

  AdModel({
    this.version = 1,
    required this.background,
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.url,
    required this.cities,
    required this.place,
  });

  factory AdModel.fromJson(dynamic json) {
    return AdModel(
      version: json['version'] ?? 0,
      background: json['background'],
      logo: json['logo'],
      title: json['title'],
      subtitle: json['subtitle'],
      button: json['button'],
      url: json['url'],
      cities: List<String>.from(json['cities'] ?? []),
      place: json['place'],
    );
  }
}
