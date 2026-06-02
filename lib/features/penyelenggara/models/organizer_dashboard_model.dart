class OrganizerTicketBreakdown {
  final String typeName;
  final int scanned;
  final int sold;

  OrganizerTicketBreakdown({
    required this.typeName,
    required this.scanned,
    required this.sold,
  });

  factory OrganizerTicketBreakdown.fromJson(Map<String, dynamic> json) {
    return OrganizerTicketBreakdown(
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

class OrganizerRecentScan {
  final String orderId;
  final String buyerName;
  final String scannedAt;
  final String eventName;
  final String category;
  final String status;
  final String reason;

  OrganizerRecentScan({
    required this.orderId,
    required this.buyerName,
    required this.scannedAt,
    required this.eventName,
    required this.category,
    required this.status,
    required this.reason,
  });

  factory OrganizerRecentScan.fromJson(Map<String, dynamic> json) {
    return OrganizerRecentScan(
      orderId: json['order_id'] ?? '',
      buyerName: json['buyer_name'] ?? 'Unknown',
      scannedAt: json['scanned_at'] ?? '',
      eventName: json['event_name'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'SUCCESS',
      reason: json['reason'] ?? 'Scan Berhasil',
    );
  }
}

class OrganizerDashboardModel {
  final String eventId;
  final String eventName;
  final int totalScanned;
  final int totalSold;
  final List<OrganizerTicketBreakdown> breakdown;
  final List<OrganizerRecentScan> recentScans;

  OrganizerDashboardModel({
    required this.eventId,
    required this.eventName,
    required this.totalScanned,
    required this.totalSold,
    required this.breakdown,
    required this.recentScans,
  });

  factory OrganizerDashboardModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    
    final rawBreakdown = json['breakdown'];
    final List<OrganizerTicketBreakdown> breakdownList = [];
    if (rawBreakdown is List) {
      for (var e in rawBreakdown) {
        if (e is Map) {
          breakdownList.add(OrganizerTicketBreakdown.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final rawRecent = json['recent_scans'];
    final List<OrganizerRecentScan> recentList = [];
    if (rawRecent is List) {
      for (var e in rawRecent) {
        if (e is Map) {
          recentList.add(OrganizerRecentScan.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return OrganizerDashboardModel(
      eventId: json['event_id'] ?? '',
      eventName: json['event_name'] ?? '',
      totalScanned: (summary['total_scanned'] ?? 0) is int
          ? summary['total_scanned']
          : (summary['total_scanned'] as num).toInt(),
      totalSold: (summary['total_sold'] ?? 0) is int
          ? summary['total_sold']
          : (summary['total_sold'] as num).toInt(),
      breakdown: breakdownList,
      recentScans: recentList,
    );
  }
}
