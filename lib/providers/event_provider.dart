import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/event.dart';
import '../repositories/event_repository.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository _repository;
  final ApiService _apiService;
  final LocalStorageService _storageService;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter & Search states
  String _searchQuery = '';
  String _selectedCategory = AppConstants.categoryAll;
  String _filterTimeline = 'all'; // 'all', 'upcoming', 'past'
  String _sortBy = 'date_asc'; // 'date_asc', 'date_desc', 'popularity', 'capacity'
  bool _useApiBackend = false;

  EventProvider({
    required EventRepository repository,
    required ApiService apiService,
    required LocalStorageService storageService,
  })  : _repository = repository,
        _apiService = apiService,
        _storageService = storageService {
    _useApiBackend = _storageService.getUseApiBackend();
    loadEvents();
  }

  // Getters
  List<Event> get allEvents => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get filterTimeline => _filterTimeline;
  String get sortBy => _sortBy;
  bool get useApiBackend => _useApiBackend;
  String get apiUrl => _apiService.baseUrl;

  List<Event> get featuredEvents =>
      _events.where((e) => e.isFeatured).toList();

  List<Event> get upcomingEvents =>
      _events.where((e) => e.isUpcoming).toList();

  /// Primary filtered & sorted list of events for Discover and Explore
  List<Event> get filteredEvents {
    var result = List<Event>.from(_events);

    // 1. Category Filter
    if (_selectedCategory != AppConstants.categoryAll) {
      result = result
          .where((e) =>
              e.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    // 2. Search Query Filter
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.description.toLowerCase().contains(query) ||
            e.venue.toLowerCase().contains(query) ||
            e.organizer.toLowerCase().contains(query) ||
            e.category.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Timeline Filter
    if (_filterTimeline == 'upcoming') {
      result = result.where((e) => e.isUpcoming).toList();
    } else if (_filterTimeline == 'past') {
      result = result.where((e) => !e.isUpcoming || e.isCompleted).toList();
    }

    // 4. Sorting
    switch (_sortBy) {
      case 'date_desc':
        result.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
      case 'popularity':
        result.sort((a, b) => b.registeredCount.compareTo(a.registeredCount));
        break;
      case 'capacity':
        result.sort((a, b) => b.capacity.compareTo(a.capacity));
        break;
      case 'date_asc':
      default:
        result.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
    }

    return result;
  }

  // ---------------- ACTIONS ----------------

  Future<void> loadEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.getEvents();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setFilterTimeline(String timeline) {
    _filterTimeline = timeline;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = AppConstants.categoryAll;
    _filterTimeline = 'all';
    _sortBy = 'date_asc';
    notifyListeners();
  }

  Future<void> setUseApiBackend(bool value) async {
    _useApiBackend = value;
    await _storageService.saveUseApiBackend(value);
    await loadEvents();
  }

  void setCustomApiUrl(String url) {
    _apiService.baseUrl = url;
    notifyListeners();
  }

  // ---------------- ORGANIZER ACTIONS ----------------

  Future<void> addCustomEvent(Event event) async {
    await _repository.addCustomEvent(event);
    await loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _repository.updateEvent(event);
    await loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _repository.deleteEvent(id);
    await loadEvents();
  }

  Event? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
