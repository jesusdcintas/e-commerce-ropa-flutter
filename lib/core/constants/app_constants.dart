/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FashionStore';
  static const String appVersion = '1.0.0';

  // Supabase - REEMPLAZAR CON TUS CREDENCIALES
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  // Stripe - REEMPLAZAR CON TUS CREDENCIALES
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';
  static const String stripeMerchantId = 'com.fashionstore';

  // Cloudinary
  static const String cloudinaryBaseUrl = 'https://res.cloudinary.com/YOUR_CLOUD_NAME/image/upload/';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int cartReservationMinutes = 15;

  // Pagination
  static const int productsPerPage = 20;
  static const int ordersPerPage = 10;

  // Debounce
  static const int searchDebounceMs = 300;

  // Cache
  static const int imageCacheDays = 7;
  static const int catalogCacheMinutes = 30;
}
