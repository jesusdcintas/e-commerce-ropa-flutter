import 'package:flutter/material.dart';
import 'package:fashion_store/core/utils/app_utils.dart';
import 'package:fashion_store/core/constants/app_colors.dart';

/// Tipos de notificación
enum NotificationType {
  order,      // Actualización de pedido
  coupon,     // Cupón disponible
  promo,      // Promoción
  system,     // Sistema
  message;    // Mensaje de consulta

  IconData get icon {
    switch (this) {
      case NotificationType.order:
        return Icons.local_shipping;
      case NotificationType.coupon:
        return Icons.discount;
      case NotificationType.promo:
        return Icons.campaign;
      case NotificationType.system:
        return Icons.info;
      case NotificationType.message:
        return Icons.message;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.order:
        return AppColors.info;
      case NotificationType.coupon:
        return AppColors.secondary;
      case NotificationType.promo:
        return AppColors.warning;
      case NotificationType.system:
        return AppColors.textSecondary;
      case NotificationType.message:
        return AppColors.success;
    }
  }

  static NotificationType fromString(String? value) {
    switch (value) {
      case 'order':
        return NotificationType.order;
      case 'coupon':
        return NotificationType.coupon;
      case 'promo':
        return NotificationType.promo;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.system;
    }
  }
}

/// Modelo de notificación
class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl; // Deep link opcional
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = NotificationType.system,
    this.isRead = false,
    this.actionUrl,
    this.data,
    required this.createdAt,
  });

  /// Tiempo relativo
  String get relativeTime => AppUtils.formatRelativeTime(createdAt);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String?),
      isRead: json['is_read'] as bool? ?? false,
      actionUrl: json['action_url'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.name,
      'is_read': isRead,
      'action_url': actionUrl,
      'data': data,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
