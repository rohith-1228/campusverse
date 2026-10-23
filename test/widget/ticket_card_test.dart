import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusverse/models/registration.dart';
import 'package:campusverse/models/student.dart';
import 'package:campusverse/widgets/qr_matrix_painter.dart';
import 'package:campusverse/widgets/ticket_card.dart';

void main() {
  testWidgets('TicketCard displays registration ID, QR code, and event details',
      (WidgetTester tester) async {
    final registration = Registration(
      registrationId: 'CV-2026-9481',
      eventId: 'ev-01',
      eventTitle: 'Campus TechFest 2026',
      eventVenue: 'Main Auditorium',
      eventDate: DateTime(2026, 11, 20, 10, 0),
      student: const Student(
        name: 'Alex Chen',
        email: 'alex@campus.edu',
        rollNumber: 'CS-2023-042',
        department: 'Computer Science',
        yearOfStudy: '3rd Year',
        phone: '9876543210',
      ),
      registeredAt: DateTime.now(),
      status: 'confirmed',
      qrCodeData: 'CAMPUSVERSE://VERIFY?regId=CV-2026-9481',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TicketCard(registration: registration),
          ),
        ),
      ),
    );

    // Verify key ticket details are present
    expect(find.text('Campus TechFest 2026'), findsOneWidget);
    expect(find.text('CV-2026-9481'), findsOneWidget);
    expect(find.text('Alex Chen'), findsOneWidget);
    expect(find.text('CS-2023-042'), findsOneWidget);
    expect(find.text('Main Auditorium'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);

    // Verify QR matrix code widget is rendered
    expect(find.byType(QrMatrixWidget), findsOneWidget);
  });
}
