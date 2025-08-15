class PlaceModel {
  final double lat;
  final double lon;
  final double distance;
  final String name;
  final String address;

  const PlaceModel({
    required this.lat,
    required this.lon,
    required this.distance,
    required this.name,
    required this.address,
  });

  factory PlaceModel.fromJson(dynamic value) {
    return PlaceModel(
      lat: value['lat'],
      lon: value['lon'],
      distance: 0,
      name: value['name'],
      address: value['address'],
    );
  }

  toJson() {
    return {
      'lat': lat,
      'lon': lon,
      'distance': distance,
      'name': name,
      'address': address,
    };
  }
}
