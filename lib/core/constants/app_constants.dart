/// App constants for configuration
class AppConstants {
// ✅ SIMPLEST - Use directly
static const String supabaseUrl = 'https://ywgvxwdhiylsqjpstalt.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl3Z3Z4d2RoaXlsc3FqcHN0YWx0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg5NjU1NjYsImV4cCI6MjA4NDU0MTU2Nn0.-HwhrxwtxCNcNn9fyV4bTksqlALp9qnD73AgCL1hwqo';
  
  // Storage bucket name for project images
  static const String projectImagesBucket = 'project-images';
  
  // App Info
  static const String appName = 'Portfolio';
  static const String developerName = 'Alhussein Abdlsabour';
  static const String username = 'toalhussein';
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Skills list
  static const List<String> skills = [
    'Flutter',
    'Dart',
    'Firebase',
    'Supabase',
    'REST APIs',
    'State Management (Riverpod)',
    'Git & GitHub',
    'UI/UX Design',
    'Responsive Design',
    'Clean Architecture',
  ];
  
  // Social Links (Update with actual links)
  static const String githubUrl = 'https://github.com/toalhussein';
  static const String linkedInUrl = 'https://linkedin.com/in/toalhussein';
  static const String twitterUrl = 'https://twitter.com/toalhussein';
  static const String emailAddress = 'toalhussein@gmail.com';
}
