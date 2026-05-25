class EventModel {
  final String id;
  final String name;
  final String venue;
  final String image;
  final String schedule;
  final int lowestPrice;
  final String organizerName;
  final String organizerPhoto;

  EventModel({
    required this.id,
    required this.name,
    required this.venue,
    required this.image,
    required this.schedule,
    required this.lowestPrice,
    required this.organizerName,
    required this.organizerPhoto,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      venue: json['venue'] ?? 'Lokasi TBA',
      image: json['image'] ?? '',
      schedule: json['schedule'] ?? '',
      lowestPrice: (json['lowest_price'] ?? 0) is int
          ? json['lowest_price']
          : (json['lowest_price'] as num).toInt(),
      organizerName: json['organizer_name'] ?? 'Penyelenggara',
      organizerPhoto: json['organizer_photo'] ?? '',
    );
  }

  /// Format harga menjadi string Rupiah (misal: "Rp 50.000" atau "Gratis")
  String get formattedPrice {
    if (lowestPrice <= 0) return 'Gratis';
    final formatted = lowestPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}
