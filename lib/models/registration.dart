import 'student.dart';

class Registration {
  final String registrationId;
  final String eventId;
  final String eventTitle;
  final String eventVenue;
  final DateTime eventDate;
  final Student student;
  final String? teamName;
  final DateTime registeredAt;
  final String status; // 'confirmed', 'attended', 'cancelled'
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final String qrCodeData;

  Registration({
    required this.registrationId,
    required this.eventId,
    required this.eventTitle,
    required this.eventVenue,
    required this.eventDate,
    required this.student,
    this.teamName,
    required this.registeredAt,
    this.status = 'confirmed',
    this.isCheckedIn = false,
    this.checkedInAt,
    required this.qrCodeData,
  });

  bool get isConfirmed => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isAttended => status == 'attended' || isCheckedIn;

  factory Registration.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'confirmed';
    final checkedIn = json['isCheckedIn'] as bool? ?? (statusStr == 'attended');

    return Registration(
      registrationId: json['registrationId'] as String? ?? 'CV-000',
      eventId: json['eventId'] as String? ?? '',
      eventTitle: json['eventTitle'] as String? ?? 'Campus Event',
      eventVenue: json['eventVenue'] as String? ?? 'Campus Auditorium',
      eventDate: json['eventDate'] != null
          ? DateTime.parse(json['eventDate'] as String)
          : DateTime.now(),
      student: Student.fromJson(json['student'] as Map<String, dynamic>? ?? {}),
      teamName: json['teamName'] as String?,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'] as String)
          : DateTime.now(),
      status: statusStr,
      isCheckedIn: checkedIn,
      checkedInAt: json['checkedInAt'] != null
          ? DateTime.parse(json['checkedInAt'] as String)
          : null,
      qrCodeData: json['qrCodeData'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationId': registrationId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventVenue': eventVenue,
      'eventDate': eventDate.toIso8601String(),
      'student': student.toJson(),
      if (teamName != null) 'teamName': teamName,
      'registeredAt': registeredAt.toIso8601String(),
      'status': status,
      'isCheckedIn': isCheckedIn,
      if (checkedInAt != null) 'checkedInAt': checkedInAt!.toIso8601String(),
      'qrCodeData': qrCodeData,
    };
  }

  Registration copyWith({
    String? registrationId,
    String? eventId,
    String? eventTitle,
    String? eventVenue,
    DateTime? eventDate,
    Student? student,
    String? teamName,
    DateTime? registeredAt,
    String? status,
    bool? isCheckedIn,
    DateTime? checkedInAt,
    String? qrCodeData,
  }) {
    return Registration(
      registrationId: registrationId ?? this.registrationId,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventVenue: eventVenue ?? this.eventVenue,
      eventDate: eventDate ?? this.eventDate,
      student: student ?? this.student,
      teamName: teamName ?? this.teamName,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }
}
