class AppConstants {
  static const String appName = 'CampusVerse';
  static const String appTagline = 'Discover, Connect & Experience Campus Life';
  static const String appVersion = '1.0.0 (Expo Edition)';

  // Categories
  static const String categoryAll = 'All Events';
  static const List<String> categories = [
    categoryAll,
    'Technical',
    'Hackathons',
    'Workshops',
    'Cultural',
    'Sports',
    'Entrepreneurship',
  ];

  // College Departments
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Biotechnology',
    'Business Administration (MBA)',
  ];

  // Academic Years
  static const List<String> academicYears = [
    '1st Year (Freshman)',
    '2nd Year (Sophomore)',
    '3rd Year (Junior)',
    '4th Year (Senior)',
    'Postgraduate',
  ];

  // Default API configuration
  static const String defaultApiUrl = 'https://campusverse-api.local/api/v1';
  static const Duration apiTimeout = Duration(seconds: 8);

  // Storage Keys
  static const String keyStudentProfile = 'cv_student_profile';
  static const String keyStudentAccounts = 'cv_student_accounts';
  static const String keyAuthCredentials = 'cv_auth_credentials';
  static const String keySessionRollNumber = 'cv_session_roll_number';
  static const String keyUserRole = 'cv_user_role';
  static const String keyRegistrations = 'cv_registrations';
  static const String keyBookmarks = 'cv_bookmarks';
  static const String keyNotifications = 'cv_notifications';
  static const String keyThemeIsDark = 'cv_theme_is_dark';
  static const String keyUseApiBackend = 'cv_use_api_backend';
  static const String keyCustomEvents = 'cv_custom_events';

  // =========================================================================
  // Isolated Local Demo Environment Flags & Mock Credentials
  //
  // SECURITY NOTICE:
  // These constants are strictly for local offline demonstration, manual testing,
  // and automated test suites. They DO NOT provide secure production authentication.
  // In a production environment, authentication MUST be handled by a secure
  // backend or institutional Identity Provider (OAuth2/OIDC/SSO) with server-side
  // session validation and role-based access control (RBAC). Client-side Dart
  // constants must never be treated as secrets or privileged production credentials.
  // =========================================================================
  static const bool isDemoEnvironment = true;
  static const String demoStudentDefaultPassword = 'Password@123';
  static const String demoOrganizerEmail = 'admin@gmail.com';
  static const String demoOrganizerPassword = 'admin';
  static const String demoOrganizerName = 'CampusVerse Admin';
  static const String demoOrganizerRoleTitle = 'Admin';
}

