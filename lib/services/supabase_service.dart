import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fashion_store/core/constants/app_constants.dart';

/// Servicio de Supabase - Singleton
class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseClient get client => Supabase.instance.client;

  SupabaseService._();

  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// Inicializar Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // ============ AUTH ============

  /// Usuario actual
  User? get currentUser => client.auth.currentUser;

  /// ¿Está autenticado?
  bool get isAuthenticated => currentUser != null;

  /// ID del usuario actual
  String? get userId => currentUser?.id;

  /// Email del usuario actual
  String? get userEmail => currentUser?.email;

  /// Stream de cambios de auth
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Registro con email y contraseña
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// Login con email y contraseña
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /// Enviar email de recuperación de contraseña
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /// Actualizar contraseña
  Future<UserResponse> updatePassword(String newPassword) async {
    return await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Actualizar datos del usuario
  Future<UserResponse> updateUser(Map<String, dynamic> data) async {
    return await client.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  // ============ PROFILE ============

  /// Obtener perfil del usuario actual
  Future<Map<String, dynamic>?> getProfile() async {
    if (userId == null) return null;
    
    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId!)
        .maybeSingle();
    
    return response;
  }

  /// Actualizar perfil
  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (userId == null) return;
    
    await client
        .from('profiles')
        .update(data)
        .eq('id', userId!);
  }

  /// Verificar si es admin
  Future<bool> isAdmin() async {
    final profile = await getProfile();
    return profile?['role'] == 'admin';
  }

  // ============ PRODUCTS ============

  /// Obtener productos con paginación
  Future<List<Map<String, dynamic>>> getProducts({
    int page = 0,
    int limit = 20,
    int? categoryId,
    String? search,
    int? minPrice,
    int? maxPrice,
    bool? onlyFeatured,
    bool? onlyNew,
    bool? onlyOffers,
  }) async {
    var query = client
        .from('products')
        .select('*, product_variants(*), categories(name)')
        .eq('is_active', true);

    if (categoryId != null) {
      query = query.eq('category_id', categoryId);
    }
    if (search != null && search.isNotEmpty) {
      query = query.ilike('name', '%$search%');
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
    }
    if (onlyFeatured == true) {
      query = query.eq('is_featured', true);
    }
    if (onlyNew == true) {
      query = query.eq('is_new', true);
    }
    if (onlyOffers == true) {
      query = query.not('original_price', 'is', null);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener producto por ID
  Future<Map<String, dynamic>?> getProductById(int id) async {
    final response = await client
        .from('products')
        .select('*, product_variants(*), categories(name)')
        .eq('id', id)
        .maybeSingle();
    
    return response;
  }

  /// Obtener producto por slug
  Future<Map<String, dynamic>?> getProductBySlug(String slug) async {
    final response = await client
        .from('products')
        .select('*, product_variants(*), categories(name)')
        .eq('slug', slug)
        .maybeSingle();
    
    return response;
  }

  // ============ CATEGORIES ============

  /// Obtener todas las categorías
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await client
        .from('categories')
        .select()
        .order('display_order');
    
    return List<Map<String, dynamic>>.from(response);
  }

  // ============ ORDERS ============

  /// Obtener pedidos del usuario
  Future<List<Map<String, dynamic>>> getOrders({int limit = 20}) async {
    if (userId == null) return [];
    
    final response = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId!)
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Obtener pedido por ID
  Future<Map<String, dynamic>?> getOrderById(int id) async {
    final response = await client
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .maybeSingle();
    
    return response;
  }

  /// Crear pedido
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    final response = await client
        .from('orders')
        .insert(orderData)
        .select()
        .single();
    
    return response;
  }

  /// Añadir items al pedido
  Future<void> addOrderItems(List<Map<String, dynamic>> items) async {
    await client.from('order_items').insert(items);
  }

  /// Cancelar pedido (RPC)
  Future<void> cancelOrder(int orderId) async {
    await client.rpc('rpc_cancel_order', params: {'order_id': orderId});
  }

  // ============ FAVORITES ============

  /// Obtener favoritos del usuario
  Future<List<Map<String, dynamic>>> getFavorites() async {
    if (userId == null) return [];
    
    final response = await client
        .from('favorites')
        .select('*, products(*, product_variants(*))')
        .eq('user_id', userId!);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Añadir a favoritos
  Future<void> addFavorite(int productId) async {
    if (userId == null) return;
    
    await client.from('favorites').insert({
      'user_id': userId,
      'product_id': productId,
    });
  }

  /// Quitar de favoritos
  Future<void> removeFavorite(int productId) async {
    if (userId == null) return;
    
    await client
        .from('favorites')
        .delete()
        .eq('user_id', userId!)
        .eq('product_id', productId);
  }

  /// ¿Es favorito?
  Future<bool> isFavorite(int productId) async {
    if (userId == null) return false;
    
    final response = await client
        .from('favorites')
        .select('id')
        .eq('user_id', userId!)
        .eq('product_id', productId)
        .maybeSingle();
    
    return response != null;
  }

  // ============ COUPONS ============

  /// Obtener cupones disponibles para el usuario
  Future<List<Map<String, dynamic>>> getAvailableCoupons() async {
    if (userId == null) return [];
    
    final response = await client
        .from('cupones')
        .select('*, reglas_cupones(*)')
        .eq('activo', true)
        .eq('usado', false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Validar cupón (RPC)
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required int orderTotal,
  }) async {
    final response = await client.rpc('rpc_validate_coupon', params: {
      'code': code,
      'user_id': userId,
      'order_total': orderTotal,
    });
    
    return Map<String, dynamic>.from(response);
  }

  /// Consumir cupón (RPC)
  Future<void> consumeCoupon({
    required String code,
    required int orderId,
  }) async {
    await client.rpc('rpc_consume_coupon', params: {
      'code': code,
      'user_id': userId,
      'order_id': orderId,
    });
  }

  // ============ NOTIFICATIONS ============

  /// Obtener notificaciones del usuario
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    if (userId == null) return [];
    
    final response = await client
        .from('notifications')
        .select()
        .eq('user_id', userId!)
        .order('created_at', ascending: false)
        .limit(limit);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Marcar notificación como leída
  Future<void> markNotificationAsRead(String notificationId) async {
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// Marcar todas como leídas
  Future<void> markAllNotificationsAsRead() async {
    if (userId == null) return;
    
    await client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId!)
        .eq('is_read', false);
  }

  /// Suscribirse a notificaciones en tiempo real
  RealtimeChannel subscribeToNotifications(
    void Function(Map<String, dynamic>) onInsert,
  ) {
    return client
        .channel('notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onInsert(payload.newRecord);
          },
        )
        .subscribe();
  }

  // ============ CART RESERVATIONS ============

  /// Crear reserva de stock
  Future<void> createCartReservation({
    required int variantId,
    required int quantity,
    required String sessionId,
  }) async {
    await client.from('cart_reservations').insert({
      'variant_id': variantId,
      'quantity': quantity,
      'session_id': sessionId,
      'expires_at': DateTime.now()
          .add(Duration(minutes: AppConstants.cartReservationMinutes))
          .toIso8601String(),
    });
  }

  /// Eliminar reservas del session
  Future<void> clearCartReservations(String sessionId) async {
    await client
        .from('cart_reservations')
        .delete()
        .eq('session_id', sessionId);
  }

  // ============ SETTINGS ============

  /// Obtener configuración global
  Future<Map<String, dynamic>?> getSettings() async {
    final response = await client
        .from('settings')
        .select()
        .eq('id', 1)
        .maybeSingle();
    
    return response;
  }

  // ============ INQUIRIES (Chat) ============

  /// Obtener consultas del usuario
  Future<List<Map<String, dynamic>>> getInquiries() async {
    if (userEmail == null) return [];
    
    final response = await client
        .from('product_inquiries')
        .select('*, inquiry_messages(*), products(name, images)')
        .eq('customer_email', userEmail!)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  /// Crear nueva consulta
  Future<Map<String, dynamic>> createInquiry({
    required int productId,
    required String customerName,
    required String customerEmail,
    required String message,
  }) async {
    final response = await client.from('product_inquiries').insert({
      'product_id': productId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'message': message,
    }).select().single();
    
    return response;
  }

  /// Añadir mensaje a consulta
  Future<void> addInquiryMessage({
    required int inquiryId,
    required String message,
    required bool isAdmin,
  }) async {
    await client.from('inquiry_messages').insert({
      'inquiry_id': inquiryId,
      'message': message,
      'is_admin': isAdmin,
    });
  }
}
