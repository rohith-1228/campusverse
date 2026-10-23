import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campusverse/providers/bookmark_provider.dart';
import 'package:campusverse/services/local_storage_service.dart';

void main() {
  group('Bookmark Provider State Operations', () {
    late LocalStorageService storageService;
    late BookmarkProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = LocalStorageService(prefs);
      provider = BookmarkProvider(storageService);
    });

    test('should toggle bookmark on and off', () async {
      expect(provider.isBookmarked('ev-01'), false);
      expect(provider.count, 0);

      await provider.toggleBookmark('ev-01');
      expect(provider.isBookmarked('ev-01'), true);
      expect(provider.count, 1);

      await provider.toggleBookmark('ev-01');
      expect(provider.isBookmarked('ev-01'), false);
      expect(provider.count, 0);
    });

    test('should persist bookmarks to storage service', () async {
      await provider.toggleBookmark('ev-01');
      await provider.toggleBookmark('ev-02');

      final reloaded = BookmarkProvider(storageService);
      expect(reloaded.isBookmarked('ev-01'), true);
      expect(reloaded.isBookmarked('ev-02'), true);
      expect(reloaded.count, 2);
    });
  });
}
