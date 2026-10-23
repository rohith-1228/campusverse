import 'package:flutter_test/flutter_test.dart';
import 'package:campusverse/models/event.dart';

void main() {
  group('Event Model JSON Parsing & Calculations', () {
    final sampleJson = {
      'id': 'ev-test-1',
      'title': 'AI HackFest 2026',
      'description': '36 hours of competitive machine learning and deep learning solutions.',
      'category': 'Hackathons',
      'venue': 'Computing Hall 1',
      'organizer': 'AI Club',
      'dateTime': '2026-11-15T09:00:00.000',
      'endTime': '2026-11-16T18:00:00.000',
      'capacity': 100,
      'registeredCount': 75,
      'imageUrl': 'https://images.unsplash.com/photo-test',
      'eligibility': 'All engineering students',
      'registrationDeadline': '2026-11-14T23:59:59.000',
      'isFeatured': true,
      'isCompleted': false,
      'agenda': [
        {
          'time': '09:00 AM',
          'title': 'Opening Keynote',
          'speaker': 'Dr. Alan Turing',
        }
      ],
    };

    test('should parse Event accurately from json map', () {
      final event = Event.fromJson(sampleJson);

      expect(event.id, 'ev-test-1');
      expect(event.title, 'AI HackFest 2026');
      expect(event.category, 'Hackathons');
      expect(event.capacity, 100);
      expect(event.registeredCount, 75);
      expect(event.availableSeats, 25);
      expect(event.seatsPercentage, 0.75);
      expect(event.isFull, false);
      expect(event.isFeatured, true);
      expect(event.agenda.length, 1);
      expect(event.agenda.first.speaker, 'Dr. Alan Turing');
    });

    test('should serialize Event accurately to json map', () {
      final event = Event.fromJson(sampleJson);
      final json = event.toJson();

      expect(json['id'], 'ev-test-1');
      expect(json['title'], 'AI HackFest 2026');
      expect(json['capacity'], 100);
      expect(json['category'], 'Hackathons');
      expect((json['agenda'] as List).length, 1);
    });

    test('should calculate seats and isFull correctly', () {
      final fullEvent = Event(
        id: 'full-1',
        title: 'Sold Out Workshop',
        description: 'Desc',
        category: 'Workshops',
        venue: 'Room 101',
        organizer: 'Lead',
        dateTime: DateTime.now().add(const Duration(days: 2)),
        endTime: DateTime.now().add(const Duration(days: 2, hours: 3)),
        capacity: 50,
        registeredCount: 50,
        imageUrl: 'url',
        registrationDeadline: DateTime.now().add(const Duration(days: 1)),
      );

      expect(fullEvent.availableSeats, 0);
      expect(fullEvent.isFull, true);
      expect(fullEvent.seatsPercentage, 1.0);
    });
  });
}
