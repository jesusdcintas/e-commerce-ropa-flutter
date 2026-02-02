/// Modelo de perfil de usuario
class Profile {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? nif;
  final String role;
  final bool newsletterSubscribed;
  final List<Address> addresses;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.nif,
    this.role = 'customer',
    this.newsletterSubscribed = false,
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String?,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      nif: json['nif'] as String?,
      role: json['role'] as String? ?? 'customer',
      newsletterSubscribed: json['newsletter_subscribed'] as bool? ?? false,
      addresses: json['addresses'] != null
          ? (json['addresses'] as List)
              .map((a) => Address.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'nif': nif,
      'role': role,
      'newsletter_subscribed': newsletterSubscribed,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }

  Profile copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? nif,
    String? role,
    bool? newsletterSubscribed,
    List<Address>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      nif: nif ?? this.nif,
      role: role ?? this.role,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modelo de dirección
class Address {
  final String? id;
  final String street;
  final String city;
  final String postalCode;
  final String province;
  final String country;
  final bool isDefault;

  Address({
    this.id,
    required this.street,
    required this.city,
    required this.postalCode,
    required this.province,
    this.country = 'España',
    this.isDefault = false,
  });

  String get fullAddress => '$street, $postalCode $city, $province';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String?,
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      province: json['province'] as String? ?? '',
      country: json['country'] as String? ?? 'España',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'street': street,
      'city': city,
      'postal_code': postalCode,
      'province': province,
      'country': country,
      'is_default': isDefault,
    };
  }

  Address copyWith({
    String? id,
    String? street,
    String? city,
    String? postalCode,
    String? province,
    String? country,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      street: street ?? this.street,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      province: province ?? this.province,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
