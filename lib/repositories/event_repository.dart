import '../models/event.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class EventRepository {
  final ApiService _apiService;
  final LocalStorageService _storageService;

  EventRepository({
    required ApiService apiService,
    required LocalStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  /// Fetch events from API or fall back to local mock events
  Future<List<Event>> getEvents({bool forceApi = false}) async {
    final useApi = forceApi || _storageService.getUseApiBackend();

    if (useApi) {
      try {
        final apiEvents = await _apiService.fetchEvents();
        // Merge with locally created organizer events
        final customEvents = _storageService.getCustomEvents();
        return [...customEvents, ...apiEvents];
      } catch (e) {
        // If API fails, fall back to mock data but preserve error context
        final mockList = _getMockEvents();
        final customEvents = _storageService.getCustomEvents();
        return [...customEvents, ...mockList];
      }
    } else {
      // Local mock mode
      final mockList = _getMockEvents();
      final customEvents = _storageService.getCustomEvents();
      return [...customEvents, ...mockList];
    }
  }

  /// Add a custom event (organizer mode)
  Future<void> addCustomEvent(Event event) async {
    final customEvents = _storageService.getCustomEvents();
    customEvents.insert(0, event);
    await _storageService.saveCustomEvents(customEvents);
  }

  /// Update an event
  Future<void> updateEvent(Event event) async {
    final customEvents = _storageService.getCustomEvents();
    final index = customEvents.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      customEvents[index] = event;
      await _storageService.saveCustomEvents(customEvents);
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String id) async {
    final customEvents = _storageService.getCustomEvents();
    customEvents.removeWhere((e) => e.id == id);
    await _storageService.saveCustomEvents(customEvents);
  }

  /// Comprehensive, realistic mock events database for offline demo
  List<Event> _getMockEvents() {
    final now = DateTime.now();

    return [
      Event(
        id: 'ev-01',
        title: 'Campus TechFest 2026',
        description:
            'The flagship annual technology festival bringing together 2,000+ engineers, creators, and innovators. Features keynote speeches from leading industry visionaries, hardware project expos, algorithmic gaming competitions, and live tech demos.',
        category: 'Technical',
        venue: 'Main Campus Grand Auditorium',
        organizer: 'IEEE Student Chapter & Tech Council',
        organizerAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        dateTime: now.add(const Duration(days: 3, hours: 9)),
        endTime: now.add(const Duration(days: 3, hours: 18)),
        capacity: 450,
        registeredCount: 382,
        imageUrl:
            'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        eligibility: 'All enrolled undergraduate and postgraduate students',
        registrationDeadline: now.add(const Duration(days: 2, hours: 23)),
        isFeatured: true,
        agenda: [
          AgendaItem(
            time: '09:00 AM - 10:00 AM',
            title: 'Inaugural Address & Keynote: The Agentic AI Revolution',
            speaker: 'Dr. Radhika Sharma (Director of Research)',
          ),
          AgendaItem(
            time: '10:30 AM - 01:00 PM',
            title: 'Inter-College Project Exhibition & Jury Evaluation',
            speaker: 'Industry Jury Panel (Google, Microsoft, NVIDIA)',
          ),
          AgendaItem(
            time: '02:00 PM - 04:30 PM',
            title: 'Algorithmic Speed Coding & Live Debugging Championship',
            speaker: 'Competitive Programming Club',
          ),
          AgendaItem(
            time: '05:00 PM - 06:00 PM',
            title: 'Prize Distribution, Cash Awards & Valedictory Ceremony',
          ),
        ],
      ),
      Event(
        id: 'ev-02',
        title: 'AI Innovation Summit: LLMs to Edge Devices',
        description:
            'Deep dive into generative AI, fine-tuning large language models on personal compute, running quantised models on mobile hardware, and building multimodal applications with Flutter and Python.',
        category: 'Workshops',
        venue: 'Turing Computer Lab & Seminar Hall 4',
        organizer: 'Google Developer Student Club (GDSC)',
        organizerAvatar:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        dateTime: now.add(const Duration(days: 5, hours: 10)),
        endTime: now.add(const Duration(days: 5, hours: 16)),
        capacity: 120,
        registeredCount: 114,
        imageUrl:
            'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
        eligibility: 'Open to 2nd, 3rd, and 4th year CSE/IT/ECE students',
        registrationDeadline: now.add(const Duration(days: 4, hours: 12)),
        isFeatured: true,
        agenda: [
          AgendaItem(
            time: '10:00 AM - 11:30 AM',
            title: 'Architecture of Large Language Models & Quantization',
            speaker: 'Arjun Menon (Senior ML Architect)',
          ),
          AgendaItem(
            time: '11:45 AM - 01:15 PM',
            title: 'Hands-on Lab: Embedding Pipelines & RAG Architecture',
            speaker: 'GDSC Core AI Team',
          ),
          AgendaItem(
            time: '02:00 PM - 04:00 PM',
            title: 'Building an On-Device Mobile AI Assistant in Flutter',
            speaker: 'Kavya Nair (Staff Mobile Engineer)',
          ),
        ],
      ),
      Event(
        id: 'ev-03',
        title: 'CodeSprint 36-Hour Hackathon',
        description:
            '36 hours of continuous code, caffeine, and breakthrough solutions. Build innovative prototypes in Healthcare, FinTech, Sustainability, and Campus Automation. Prizes worth ₹1,50,000 + cloud credits.',
        category: 'Hackathons',
        venue: 'Campus Innovation Center (24/7 Access)',
        organizer: 'CampusVerse Hacker Society',
        organizerAvatar:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
        dateTime: now.add(const Duration(days: 8, hours: 18)),
        endTime: now.add(const Duration(days: 10, hours: 8)),
        capacity: 200,
        registeredCount: 175,
        imageUrl:
            'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=800',
        eligibility: 'Teams of 2 to 4 students from any accredited college',
        registrationDeadline: now.add(const Duration(days: 6, hours: 23)),
        isFeatured: true,
        agenda: [
          AgendaItem(
            time: 'Day 1 - 06:00 PM',
            title: 'Opening Ceremony, Problem Statement Unveiling & Team Hacking Begins',
          ),
          AgendaItem(
            time: 'Day 2 - 10:00 AM',
            title: 'First Mentorship Review Round & Code Architecture Check',
          ),
          AgendaItem(
            time: 'Day 2 - 08:00 PM',
            title: 'Midway Demo & Midnight Energy Sprint',
          ),
          AgendaItem(
            time: 'Day 3 - 08:00 AM',
            title: 'Code Freeze, Pitch Decks & Grand Finale Evaluations',
          ),
        ],
      ),
      Event(
        id: 'ev-04',
        title: 'Xcelerate: Full-Stack Flutter Workshop',
        description:
            'Master state management with Provider, responsive cross-platform layouts, custom animations, API integrations, and deploying production apps to Android and Web.',
        category: 'Workshops',
        venue: 'Software Systems Lab 2',
        organizer: 'Mobile Developers Club',
        organizerAvatar:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
        dateTime: now.add(const Duration(days: 11, hours: 14)),
        endTime: now.add(const Duration(days: 11, hours: 17)),
        capacity: 80,
        registeredCount: 62,
        imageUrl:
            'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800',
        eligibility: 'Laptops with Flutter SDK installed required',
        registrationDeadline: now.add(const Duration(days: 10, hours: 12)),
        isFeatured: false,
        agenda: [
          AgendaItem(
            time: '02:00 PM - 03:00 PM',
            title: 'Modern State Management: Provider vs BLoC in 2026',
            speaker: 'Priya Sundaram',
          ),
          AgendaItem(
            time: '03:15 PM - 04:30 PM',
            title: 'Building Glassmorphism UI & Micro-Interactions in Flutter',
          ),
          AgendaItem(
            time: '04:30 PM - 05:00 PM',
            title: 'Q&A, Source Code Review & Certificate Distribution',
          ),
        ],
      ),
      Event(
        id: 'ev-05',
        title: 'Cultural Night: Milan Music & Dance Fiesta',
        description:
            'An electrifying evening featuring campus rock bands, western acoustic sets, classical fusion dance performances, beatboxing showdowns, and celebrity DJ night.',
        category: 'Cultural',
        venue: 'Open Air Amphitheatre',
        organizer: 'Campus Cultural Affairs Committee',
        organizerAvatar:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
        dateTime: now.add(const Duration(days: 14, hours: 17)),
        endTime: now.add(const Duration(days: 14, hours: 22)),
        capacity: 800,
        registeredCount: 654,
        imageUrl:
            'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
        eligibility: 'College ID card mandatory for gate entry',
        registrationDeadline: now.add(const Duration(days: 13, hours: 23)),
        isFeatured: false,
        agenda: [
          AgendaItem(
            time: '05:00 PM - 06:30 PM',
            title: 'Acoustic Unplugged & Classical Fusion Ensembles',
          ),
          AgendaItem(
            time: '06:45 PM - 08:30 PM',
            title: 'Inter-Department Choreography & Street Dance Battle',
          ),
          AgendaItem(
            time: '08:45 PM - 10:00 PM',
            title: 'Headline Band: The Midnight Echoes & EDM Finale',
          ),
        ],
      ),
      Event(
        id: 'ev-06',
        title: 'Inter-College Sports Meet: Blitz 2026',
        description:
            'Annual athletics, football, basketball, badminton, and table tennis championships across 16 competing collegiate teams. Trophies, medals, and scout scouting sessions.',
        category: 'Sports',
        venue: 'Campus Sports Complex & Synthetic Track',
        organizer: 'Physical Education & Athletics Board',
        organizerAvatar:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
        dateTime: now.add(const Duration(days: 18, hours: 8)),
        endTime: now.add(const Duration(days: 20, hours: 18)),
        capacity: 350,
        registeredCount: 290,
        imageUrl:
            'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800',
        eligibility: 'Valid medical clearance and college sports jersey required',
        registrationDeadline: now.add(const Duration(days: 16, hours: 18)),
        isFeatured: false,
        agenda: [
          AgendaItem(
            time: 'Day 1 - 08:00 AM',
            title: 'Torch Lighting & 100m/400m Track Heats',
          ),
          AgendaItem(
            time: 'Day 2 - 10:00 AM',
            title: 'Basketball & Football Quarter-Finals',
          ),
          AgendaItem(
            time: 'Day 3 - 03:00 PM',
            title: 'Grand Finals & Championship Trophy Presentation',
          ),
        ],
      ),
      Event(
        id: 'ev-07',
        title: 'E-Cell VenturePitch: Startup Showcase',
        description:
            'Pitch your startup concept to angel investors, venture capitalists, and alumni founders. Seed funding grants up to ₹5 Lakhs, incubation desk space, and mentor office hours.',
        category: 'Entrepreneurship',
        venue: 'Executive Seminar Hall & Boardroom 1',
        organizer: 'Centre for Innovation & Entrepreneurship (CIE)',
        organizerAvatar:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=200',
        dateTime: now.add(const Duration(days: 22, hours: 11)),
        endTime: now.add(const Duration(days: 22, hours: 17)),
        capacity: 100,
        registeredCount: 78,
        imageUrl:
            'https://images.unsplash.com/photo-1559136555-9303baea8ebd?w=800',
        eligibility: 'Student founders and early stage college ventures',
        registrationDeadline: now.add(const Duration(days: 20, hours: 23)),
        isFeatured: false,
        agenda: [
          AgendaItem(
            time: '11:00 AM - 12:30 PM',
            title: 'Keynote: Scaling From Dorm Room to Seed Round',
            speaker: 'Vikram Seth (Partner, Campus Ventures)',
          ),
          AgendaItem(
            time: '01:30 PM - 04:30 PM',
            title: 'Pitch Round: 10 Finalist Startups (5 min pitch + 5 min Q&A)',
          ),
          AgendaItem(
            time: '04:45 PM - 05:30 PM',
            title: 'Investment Grants Announcement & Networking Mixer',
          ),
        ],
      ),
      Event(
        id: 'ev-08',
        title: 'RoboWars Arena: Combat Robotics',
        description:
            'Battle of metal, motors, and code! 15kg and 30kg combat robots clash in a high-voltage bulletproof arena. Obstacle courses, pneumatic flippers, and spinning blades.',
        category: 'Technical',
        venue: 'Mechanical Engineering Workshop Arena',
        organizer: 'Robotics & Automation Society (RAS)',
        organizerAvatar:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
        dateTime: now.add(const Duration(days: 26, hours: 13)),
        endTime: now.add(const Duration(days: 26, hours: 19)),
        capacity: 300,
        registeredCount: 210,
        imageUrl:
            'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
        eligibility: 'Teams must pass technical safety inspection prior to match',
        registrationDeadline: now.add(const Duration(days: 24, hours: 18)),
        isFeatured: false,
        agenda: [
          AgendaItem(
            time: '01:00 PM - 02:30 PM',
            title: 'Technical Inspection & Failsafe Wireless Verification',
          ),
          AgendaItem(
            time: '03:00 PM - 06:00 PM',
            title: 'Knockout Combat Rounds & Arena Hazard Challenges',
          ),
          AgendaItem(
            time: '06:30 PM - 07:00 PM',
            title: 'Championship Bout & Most Innovative Design Trophy',
          ),
        ],
      ),
    ];
  }
}
