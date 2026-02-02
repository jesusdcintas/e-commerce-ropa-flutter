/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FashionStore';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'https://lswokdjpfmsxczkeyvft.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxzd29rZGpwZm1zeGN6a2V5dmZ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgyMDY2NTcsImV4cCI6MjA4Mzc4MjY1N30._QQu-zV793LKYZg826TniyGMWpnDycK2yHOVf9PHORc';

  // Stripe
  static const String stripePublishableKey = 'pk_test_51SLLYiLLsVBEq7m5Ll2L4Qz4Wgpjv0RU5ftnUYWhQ6u2VmP5CJnmmwI3uGNmeTgB8uHytNflRz42D8VYfxZekcxr00glpaF1G9';
  static const String stripeMerchantId = 'com.fashionstore';

  // Cloudinary
  static const String cloudinaryCloudName = 'dmgrt2aua';
  static const String cloudinaryBaseUrl = 'https://res.cloudinary.com/dmgrt2aua/image/upload/';

  // Site URL
  static const String siteUrl = 'http://cintasfashionstore.victoriafp.online';

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
