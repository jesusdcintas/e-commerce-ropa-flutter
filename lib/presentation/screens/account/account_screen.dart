import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fashion_store/core/constants/app_colors.dart';
import 'package:fashion_store/presentation/providers/auth_provider.dart';

/// Pantalla de cuenta de usuario
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open settings
            },
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              // Header con nombre
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppColors.primary,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.secondary,
                      child: Text(
                        user?.fullName?.isNotEmpty == true
                            ? user!.fullName![0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu options
              _MenuSection(
                title: 'Compras',
                items: [
                  _MenuItem(
                    icon: Icons.receipt_long,
                    title: 'Mis Pedidos',
                    onTap: () => context.push('/orders'),
                  ),
                  _MenuItem(
                    icon: Icons.favorite,
                    title: 'Favoritos',
                    onTap: () => context.push('/favorites'),
                  ),
                  _MenuItem(
                    icon: Icons.discount,
                    title: 'Mis Cupones',
                    onTap: () => context.push('/coupons'),
                  ),
                ],
              ),

              _MenuSection(
                title: 'Cuenta',
                items: [
                  _MenuItem(
                    icon: Icons.person,
                    title: 'Datos personales',
                    onTap: () {
                      // TODO: Navigate to personal data
                    },
                  ),
                  _MenuItem(
                    icon: Icons.location_on,
                    title: 'Direcciones',
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  _MenuItem(
                    icon: Icons.lock,
                    title: 'Cambiar contraseña',
                    onTap: () {
                      // TODO: Navigate to change password
                    },
                  ),
                ],
              ),

              _MenuSection(
                title: 'Comunicaciones',
                items: [
                  _MenuItem(
                    icon: Icons.mail,
                    title: 'Newsletter',
                    trailing: Switch(
                      value: user?.newsletterSubscribed ?? false,
                      onChanged: (value) {
                        // TODO: Toggle newsletter
                      },
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.notifications,
                    title: 'Notificaciones',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  _MenuItem(
                    icon: Icons.chat,
                    title: 'Mis Consultas',
                    onTap: () {
                      // TODO: Navigate to messages
                    },
                  ),
                ],
              ),

              _MenuSection(
                title: 'Ayuda',
                items: [
                  _MenuItem(
                    icon: Icons.help,
                    title: 'Preguntas frecuentes',
                    onTap: () {
                      // TODO: Navigate to FAQ
                    },
                  ),
                  _MenuItem(
                    icon: Icons.support_agent,
                    title: 'Contacto',
                    onTap: () {
                      // TODO: Navigate to contact
                    },
                  ),
                ],
              ),

              // Logout
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      trailing: trailing ??
          (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
