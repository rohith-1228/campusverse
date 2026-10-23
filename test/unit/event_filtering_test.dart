import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/providers/event_provider.dart';
import 'package:campusverse/repositories/event_repository.dart';
import 'package:campusverse/services/api_service.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('Event Provider Filtering & Searching', () {
    late LocalStorageService storageService;
    late EventRepository repo;
    late EventProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      final apiService = ApiService();
      repo = EventRepository(apiService: apiService, storageService: storageService);
      provider = EventProvider(
        repository: repo,
        apiService: apiService,
        storageService: storageService,
      );
      // Wait for mock events to load
      await provider.loadEvents();
    });

    test('should load default mock events successfully', () {
      expect(provider.allEvents.isNotEmpty, true);
      expect(provider.featuredEvents.isNotEmpty, true);
      expect(provider.upcomingEvents.isNotEmpty, true);
    });

    test('should filter events by category', () {
      provider.selectCategory('Hackathons');
      final hackathons = provider.filteredEvents;

      expect(hackathons.every((e) => e.category.toLowerCase() == 'hackathons'), true);
      expect(hackathons.length, greaterThan(0));
    });

    test('should filter events by search query keyword', () {
      provider.setSearchQuery('Summit');
      final results = provider.filteredEvents;

      expect(results.every((e) =>
          e.title.toLowerCase().contains('summit') ||
          e.description.toLowerCase().contains('summit')), true);
    });

    test('should sort events by popularity (registeredCount desc)', () {
      provider.setSortBy('popularity');
      final sorted = provider.filteredEvents;

      for (int i = 0; i < sorted.length - 1; i++) {
        expect(sorted[i].registeredCount >= sorted[i + 1].registeredCount, true);
      }
    });

    test('should clear all active filters', () {
      provider.selectCategory('Sports');
      provider.setSearchQuery('Blitz');
      provider.setSortBy('popularity');

      provider.clearFilters();

      expect(provider.selectedCategory, 'All Events');
      expect(provider.searchQuery, '');
      expect(provider.sortBy, 'date_asc');
      expect(provider.filteredEvents.length, provider.allEvents.length);
    });
  });
}
