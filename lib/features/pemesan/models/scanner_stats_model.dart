class TicketBreakdownModel {
  final String typeName;
  final int scanned;
  final int sold;

  TicketBreakdownModel({
    required this.typeName,
    required this.scanned,
    required this.sold,
  });

  factory TicketBreakdownModel.fromJson(Map<String, dynamic> json) {
    return TicketBreakdownModel(
      typeName: json['type_name'] ?? '',
      scanned: (json['scanned'] ?? 0) is int
          ? json['scanned']
          : (json['scanned'] as num).toInt(),
      sold: (json['sold'] ?? 0) is int
          ? json['sold']
          : (json['sold'] as num).toInt(),
    );
  }

  double get scanRate => sold > 0 ? scanned / sold : 0.0;
}

class RecentScanModel {
  final String orderId;
  final String buyerName;
  final String scannedAt;
  final String eventName;
  final String category;

  RecentScanModel({
    required this.orderId,
    required this.buyerName,
    required this.scannedAt,
    required this.eventName,
    required this.category,
  });

  factory RecentScanModel.fromJson(Map<String, dynamic> json) {
    return RecentScanModel(
      orderId: json['order_id'] ?? '',
      buyerName: json['buyer_name'] ?? 'Unknown',
      scannedAt: json['scanned_at'] ?? '',
      eventName: json['event_name'] ?? '',
      category: json['category'] ?? '',
    );
  }
}

/// Respons dari GET /staff/dashboard
class ScannerStatsModel {
  final String eventName;
  final int totalScanned;
  final int totalSold;
  final List<TicketBreakdownModel> breakdown;
  final List<RecentScanModel> recentScans;

  ScannerStatsModel({
    required this.eventName,
    required this.totalScanned,
    required this.totalSold,
    required this.breakdown,
    required this.recentScans,
  });

  factory ScannerStatsModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    return ScannerStatsModel(
      eventName: json['event_name'] ?? '',
      totalScanned: (summary['total_scanned'] ?? 0) is int
          ? summary['total_scanned']
          : (summary['total_scanned'] as num).toInt(),
      totalSold: (summary['total_sold'] ?? 0) is int
          ? summary['total_sold']
          : (summary['total_sold'] as num).toInt(),
      breakdown: (json['breakdown'] as List? ?? [])
          .map((e) => TicketBreakdownModel.fromJson(e))
          .toList(),
      recentScans: (json['recent_scans'] as List? ?? [])
          .map((e) => RecentScanModel.fromJson(e))
          .toList(),
    );
  }
}
