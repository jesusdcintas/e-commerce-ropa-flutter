import 'package:flutter/material.dart';
import 'package:fashion_store/core/constants/app_colors.dart';

/// Pantalla de catálogo de productos
class CatalogScreen extends StatelessWidget {
  final int? categoryId;
  final String? search;

  const CatalogScreen({
    super.key,
    this.categoryId,
    this.search,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(search != null ? 'Buscar: $search' : 'Catálogo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Open search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open filters
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              'Catálogo de productos',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Próximamente...',
              style: TextStyle(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
