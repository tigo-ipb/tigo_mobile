import 'event_model.dart';

class EventScheduleModel {
  final String date;
  final String startTime;
  final String endTime;

  EventScheduleModel({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory EventScheduleModel.fromJson(Map<String, dynamic> json) {
    return EventScheduleModel(
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}

class EventLocationModel {
  final String venue;
  final String address;
  final String mapLink;

  EventLocationModel({
    required this.venue,
    required this.address,
    required this.mapLink,
  });

  factory EventLocationModel.fromJson(Map<String, dynamic> json) {
    return EventLocationModel(
      venue: json['venue'] ?? '',
      address: json['address'] ?? '',
      mapLink: json['map_link'] ?? '',
    );
  }
}

class EventTicketTypeModel {
  final String typeId;
  final String typeName;
  final int price;
  final int availableStock;
  final String description;

  EventTicketTypeModel({
    required this.typeId,
    required this.typeName,
    required this.price,
    required this.availableStock,
    required this.description,
  });

  factory EventTicketTypeModel.fromJson(Map<String, dynamic> json) {
    return EventTicketTypeModel(
      typeId: json['type_id'] ?? '',
      typeName: json['type_name'] ?? '',
      price: json['price'] != null
          ? (json['price'] is int
              ? json['price'] as int
              : (json['price'] as num).toInt())
          : 0,
      availableStock: json['available_stock'] != null
          ? (json['available_stock'] is int
              ? json['available_stock'] as int
              : (json['available_stock'] as num).toInt())
          : 0,
      description: json['description'] ?? '',
    );
  }
}

class EventOrganizerModel {
  final String id;
  final String name;
  final String photo;

  EventOrganizerModel({
    required this.id,
    required this.name,
    required this.photo,
  });

  factory EventOrganizerModel.fromJson(Map<String, dynamic> json) {
    return EventOrganizerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photo: json['photo'] ?? '',
    );
  }
}

class EventDetailModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String format;
  final EventLocationModel location;
  final String image16x9;
  final String image1x1;
  final List<EventScheduleModel> schedules;
  final List<EventTicketTypeModel> ticketTypes;
  final List<String> termsConditions;
  final List<String> galleries;
  final EventOrganizerModel organizer;
  final List<EventModel> otherEvents;

  EventDetailModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.format,
    required this.location,
    required this.image16x9,
    required this.image1x1,
    required this.schedules,
    required this.ticketTypes,
    required this.termsConditions,
    required this.galleries,
    required this.organizer,
    required this.otherEvents,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      format: json['format'] ?? '',
      location: EventLocationModel.fromJson(json['location'] ?? {}),
      image16x9: json['image_16x9'] ?? '',
      image1x1: json['image_1x1'] ?? '',
      schedules: (json['schedules'] as List? ?? [])
          .map((e) => EventScheduleModel.fromJson(e))
          .toList(),
      ticketTypes: (json['ticket_types'] as List? ?? [])
          .map((e) => EventTicketTypeModel.fromJson(e))
          .toList(),
      termsConditions: List<String>.from(json['terms_conditions'] ?? []),
      galleries: List<String>.from(json['galleries'] ?? []),
      organizer: EventOrganizerModel.fromJson(json['organizer'] ?? {}),
      otherEvents: (json['other_events'] as List? ?? [])
          .map((e) => EventModel.fromJson(e))
          .toList(),
    );
  }
}
