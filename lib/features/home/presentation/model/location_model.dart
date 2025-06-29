class LocationModel {
  final String name;
  final String address;
  final Map<String, double>? coordinates;
  final String? description;
  final double? lat;
  final double? lng;

  LocationModel({
    required this.name,
    required this.address,
    this.coordinates,
    this.description,
    this.lat,
    this.lng,
  });

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.name == name &&
        other.address == address &&
        other.coordinates == coordinates &&
        other.lat == lat &&
        other.lng == lng;
  }

  @override
  int get hashCode {
    return name.hashCode ^ address.hashCode ^ coordinates.hashCode ^ lat.hashCode ^ lng.hashCode;
  }
} 