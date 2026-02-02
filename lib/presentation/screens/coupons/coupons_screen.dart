import 'package:flutter/material.dart';
import 'package:fashion_store/core/constants/app_colors.dart';

/// Pantalla de cupones del usuario
class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cupones'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.discount_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 16),
            Text(
              'No tienes cupones disponibles',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los cupones que obtengas aparecerán aquí',
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
