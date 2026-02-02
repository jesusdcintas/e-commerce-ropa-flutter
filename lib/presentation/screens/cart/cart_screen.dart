import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_store/core/constants/app_colors.dart';

/// Pantalla del carrito
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual cart data
    final isEmpty = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
      ),
      body: isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Añade productos para empezar',
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
            )
          : const Column(
              children: [
                // TODO: Cart items list
                Expanded(
                  child: Center(child: Text('Items del carrito')),
                ),
              ],
            ),
      bottomNavigationBar: isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Total
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '0,00 €',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/checkout'),
                        child: const Text('Proceder al pago'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
