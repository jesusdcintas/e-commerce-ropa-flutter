import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_store/presentation/providers/auth_provider.dart';

// Screens
import 'package:fashion_store/presentation/screens/auth/splash_screen.dart';
import 'package:fashion_store/presentation/screens/auth/login_screen.dart';
import 'package:fashion_store/presentation/screens/auth/register_screen.dart';
import 'package:fashion_store/presentation/screens/auth/forgot_password_screen.dart';
import 'package:fashion_store/presentation/screens/home/home_screen.dart';
import 'package:fashion_store/presentation/screens/catalog/catalog_screen.dart';
import 'package:fashion_store/presentation/screens/product/product_detail_screen.dart';
import 'package:fashion_store/presentation/screens/cart/cart_screen.dart';
import 'package:fashion_store/presentation/screens/checkout/checkout_screen.dart';
import 'package:fashion_store/presentation/screens/orders/orders_screen.dart';
import 'package:fashion_store/presentation/screens/orders/order_detail_screen.dart';
import 'package:fashion_store/presentation/screens/account/account_screen.dart';
import 'package:fashion_store/presentation/screens/favorites/favorites_screen.dart';
import 'package:fashion_store/presentation/screens/coupons/coupons_screen.dart';
import 'package:fashion_store/presentation/widgets/main_scaffold.dart';

/// Provider del router
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    
    // Redirect según estado de auth
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register') ||
          state.matchedLocation.startsWith('/forgot-password');
      final isProtectedRoute = state.matchedLocation.startsWith('/account') ||
          state.matchedLocation.startsWith('/orders') ||
          state.matchedLocation.startsWith('/checkout') ||
          state.matchedLocation.startsWith('/favorites') ||
          state.matchedLocation.startsWith('/coupons') ||
          state.matchedLocation.startsWith('/admin');

      // Mientras carga, mostrar splash
      if (isLoading) {
        return state.matchedLocation == '/' ? null : '/';
      }

      // Si va a ruta protegida sin auth, ir a login
      if (isProtectedRoute && !isLoggedIn) {
        return '/login?redirect=${state.matchedLocation}';
      }

      // Si está logueado y va a auth, ir a home
      if (isLoggedIn && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    
    routes: [
      // Splash
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main app routes with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/catalog',
            name: 'catalog',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CatalogScreen(),
            ),
          ),
          GoRoute(
            path: '/cart',
            name: 'cart',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CartScreen(),
            ),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AccountScreen(),
            ),
          ),
        ],
      ),

      // Product detail
      GoRoute(
        path: '/product/:id',
        name: 'product',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ProductDetailScreen(productId: id);
        },
      ),

      // Checkout
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),

      // Orders
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        name: 'order-detail',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailScreen(orderId: id);
        },
      ),

      // Favorites
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),

      // Coupons
      GoRoute(
        path: '/coupons',
        name: 'coupons',
        builder: (context, state) => const CouponsScreen(),
      ),

      // TODO: Add admin routes
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
