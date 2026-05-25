class QrCodeModel {
  final String id;
  final String qrCodeString;
  final bool isUsed;

  QrCodeModel({
    required this.id,
    required this.qrCodeString,
    required this.isUsed,
  });

  factory QrCodeModel.fromJson(Map<String, dynamic> json) {
    return QrCodeModel(
      id: json['_id'] ?? json['id'] ?? '',
      qrCodeString: json['qr_code_string'] ?? '',
      isUsed: json['is_used'] == true,
    );
  }
}

class TicketItemModel {
  final String typeId;
  final String typeName;
  final int quantity;
  final int price;
  final int subTotal;

  TicketItemModel({
    required this.typeId,
    required this.typeName,
    required this.quantity,
    required this.price,
    required this.subTotal,
  });

  factory TicketItemModel.fromJson(Map<String, dynamic> json) {
    return TicketItemModel(
      typeId: json['type_id'] ?? '',
      typeName: json['type_name'] ?? '',
      quantity: (json['quantity'] ?? 0) is int
          ? json['quantity']
          : (json['quantity'] as num).toInt(),
      price: (json['price'] ?? 0) is int
          ? json['price']
          : (json['price'] as num).toInt(),
      subTotal: (json['sub_total'] ?? 0) is int
          ? json['sub_total']
          : (json['sub_total'] as num).toInt(),
    );
  }
}

/// Detail lengkap sebuah tiket (E-Ticket view) dari GET /my-tickets/{payment_id}
class TicketDetailModel {
  final Map<String, dynamic> eventDetails;
  final Map<String, dynamic> buyerDetails;
  final List<TicketItemModel> ticketItems;
  final int totalPaid;
  final String status;
  final List<QrCodeModel> qrCodes;

  TicketDetailModel({
    required this.eventDetails,
    required this.buyerDetails,
    required this.ticketItems,
    required this.totalPaid,
    required this.status,
    required this.qrCodes,
  });

  factory TicketDetailModel.fromJson(Map<String, dynamic> json) {
    return TicketDetailModel(
      eventDetails: Map<String, dynamic>.from(json['event_details'] ?? {}),
      buyerDetails: Map<String, dynamic>.from(json['buyer_details'] ?? {}),
      ticketItems: (json['ticket_items'] as List? ?? [])
          .map((e) => TicketItemModel.fromJson(e))
          .toList(),
      totalPaid: (json['total_paid'] ?? 0) is int
          ? json['total_paid']
          : (json['total_paid'] as num).toInt(),
      status: json['status'] ?? '',
      qrCodes: (json['qr_codes'] as List? ?? [])
          .map((e) => QrCodeModel.fromJson(e))
          .toList(),
    );
  }

  String get eventName => eventDetails['name'] ?? '';
  String get venueName {
    final loc = eventDetails['location'];
    if (loc is Map) return loc['venue'] ?? loc['address'] ?? 'Lokasi TBA';
    return 'Lokasi TBA';
  }
}
