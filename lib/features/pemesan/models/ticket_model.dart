/// Merepresentasikan satu item tiket dalam daftar "Tiket Saya"
class TicketModel {
  final String paymentId;
  final String eventName;
  final String organizerName;
  final String? dateStart;
  final Map<String, dynamic>? location;
  final String? banner1x1;
  final int totalTickets;

  TicketModel({
    required this.paymentId,
    required this.eventName,
    required this.organizerName,
    this.dateStart,
    this.location,
    this.banner1x1,
    required this.totalTickets,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      paymentId: json['payment_id'] ?? '',
      eventName: json['event_name'] ?? '',
      organizerName: json['organizer_name'] ?? 'Organizer',
      dateStart: json['date_start'],
      location: json['location'] is Map
          ? Map<String, dynamic>.from(json['location'])
          : null,
      banner1x1: json['banner_1x1'],
      totalTickets: (json['total_tickets'] ?? 0) is int
          ? json['total_tickets']
          : (json['total_tickets'] as num).toInt(),
    );
  }

  String get venueName =>
      location?['venue'] ?? location?['address'] ?? 'Lokasi TBA';
}
