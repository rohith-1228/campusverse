class AgendaItem {
  final String time;
  final String title;
  final String? speaker;

  AgendaItem({
    required this.time,
    required this.title,
    this.speaker,
  });

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    return AgendaItem(
      time: json['time'] as String? ?? '',
      title: json['title'] as String? ?? '',
      speaker: json['speaker'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'title': title,
      if (speaker != null) 'speaker': speaker,
    };
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final String venue;
  final String organizer;
  final String? organizerAvatar;
  final DateTime dateTime;
  final DateTime endTime;
  final int capacity;
  final int registeredCount;
  final String imageUrl;
  final String eligibility;
  final List<AgendaItem> agenda;
  final DateTime registrationDeadline;
  final bool isFeatured;
  final bool isCompleted;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.venue,
    required this.organizer,
    this.organizerAvatar,
    required this.dateTime,
    required this.endTime,
    required this.capacity,
    this.registeredCount = 0,
    required this.imageUrl,
    this.eligibility = 'Open to all college students',
    this.agenda = const [],
    required this.registrationDeadline,
    this.isFeatured = false,
    this.isCompleted = false,
  });

  int get availableSeats => (capacity - registeredCount).clamp(0, capacity);
  bool get isFull => registeredCount >= capacity;
  double get seatsPercentage =>
      capacity > 0 ? (registeredCount / capacity).clamp(0.0, 1.0) : 0.0;
  bool get isUpcoming => dateTime.isAfter(DateTime.now());
  bool get isRegistrationOpen =>
      registrationDeadline.isAfter(DateTime.now()) && !isFull;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Technical',
      venue: json['venue'] as String? ?? 'Campus Auditorium',
      organizer: json['organizer'] as String? ?? 'Student Council',
      organizerAvatar: json['organizerAvatar'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : DateTime.now().add(const Duration(days: 3)),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : DateTime.now().add(const Duration(days: 3, hours: 3)),
      capacity: (json['capacity'] as num?)?.toInt() ?? 100,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl'] as String? ??
          'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      eligibility:
          json['eligibility'] as String? ?? 'Open to all college students',
      agenda: (json['agenda'] as List<dynamic>?)
              ?.map((e) => AgendaItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.parse(json['registrationDeadline'] as String)
          : DateTime.now().add(const Duration(days: 2)),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'venue': venue,
      'organizer': organizer,
      if (organizerAvatar != null) 'organizerAvatar': organizerAvatar,
      'dateTime': dateTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'capacity': capacity,
      'registeredCount': registeredCount,
      'imageUrl': imageUrl,
      'eligibility': eligibility,
      'agenda': agenda.map((a) => a.toJson()).toList(),
      'registrationDeadline': registrationDeadline.toIso8601String(),
      'isFeatured': isFeatured,
      'isCompleted': isCompleted,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? venue,
    String? organizer,
    String? organizerAvatar,
    DateTime? dateTime,
    DateTime? endTime,
    int? capacity,
    int? registeredCount,
    String? imageUrl,
    String? eligibility,
    List<AgendaItem>? agenda,
    DateTime? registrationDeadline,
    bool? isFeatured,
    bool? isCompleted,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      venue: venue ?? this.venue,
      organizer: organizer ?? this.organizer,
      organizerAvatar: organizerAvatar ?? this.organizerAvatar,
      dateTime: dateTime ?? this.dateTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      imageUrl: imageUrl ?? this.imageUrl,
      eligibility: eligibility ?? this.eligibility,
      agenda: agenda ?? this.agenda,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      isFeatured: isFeatured ?? this.isFeatured,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
