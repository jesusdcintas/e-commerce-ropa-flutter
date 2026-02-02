import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_store/core/constants/app_colors.dart';

/// Pantalla de favoritos
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_outline,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'No tienes favoritos aún',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los productos que marques aparecerán aquí',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/catalog'),
              child: const Text('Explorar catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
