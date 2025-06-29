class LocationModel {
  final String name;
  final String address;
  final Map<String, double>? coordinates;
  final String? description;

  LocationModel({
    required this.name,
    required this.address,
    this.coordinates,
    this.description,
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
        other.coordinates == coordinates;
  }

  @override
  int get hashCode {
    return name.hashCode ^ address.hashCode ^ coordinates.hashCode;
  }
} 