class CityModel {
  // name, lat, lon, zoom (14.0 default)
  final String name;
  final double lat;
  final double lon;
  final double zoom;

  const CityModel({
    required this.name,
    required this.lat,
    required this.lon,
    this.zoom = 14.0,
  });
}
