import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  Set<String> _bookmarkedIds = {};

  BookmarkProvider(this._storageService) {
    _loadBookmarks();
  }

  Set<String> get bookmarkedIds => _bookmarkedIds;
  int get count => _bookmarkedIds.length;

  void _loadBookmarks() {
    _bookmarkedIds = _storageService.getBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String eventId) {
    return _bookmarkedIds.contains(eventId);
  }

  Future<void> toggleBookmark(String eventId) async {
    if (_bookmarkedIds.contains(eventId)) {
      _bookmarkedIds.remove(eventId);
    } else {
      _bookmarkedIds.add(eventId);
    }
    notifyListeners();
    await _storageService.saveBookmarks(_bookmarkedIds);
  }

  Future<void> removeBookmark(String eventId) async {
    if (_bookmarkedIds.contains(eventId)) {
      _bookmarkedIds.remove(eventId);
      notifyListeners();
      await _storageService.saveBookmarks(_bookmarkedIds);
    }
  }
}
