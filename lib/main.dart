import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/bookmark_provider.dart';
import 'providers/event_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/registration_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/event_repository.dart';
import 'repositories/registration_repository.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge transparent navigation bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize persistent storage
  final storageService = await LocalStorageService.init();

  // Initialize API service
  final apiService = ApiService();

  // Initialize repositories
  final eventRepository = EventRepository(
    apiService: apiService,
    storageService: storageService,
  );
  final registrationRepository = RegistrationRepository(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(
            repository: eventRepository,
            apiService: apiService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(registrationRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarkProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(storageService),
        ),
      ],
      child: const CampusVerseApp(),
    ),
  );
}
