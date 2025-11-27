class UserProfile {
  final String id;
  final String? email;
  final String? username;
  final String? fullName;
  final String? phone;
  

  final String? address; 
  final String? addressLine1;
  final String? city;
  final String? postalCode;
  final DateTime? createdAt;
  

  UserProfile({
    required this.id,
    this.email,
    this.username,
    this.fullName,
    this.phone,
    this.address,
    // Add new fields to the constructor
    this.addressLine1,
    this.city,
    this.postalCode,
    this.createdAt,
  });

  // Convert Supabase response (Map) to UserProfile object
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String?,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      // Map the new structured fields from the database
      addressLine1: map['address_line_1'] as String?,
      city: map['city'] as String?,
      postalCode: map['postal_code'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  // Convert UserProfile object to Map for insert/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      // Include the new fields for database operations
      'address_line_1': addressLine1,
      'city': city,
      'postal_code': postalCode,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Copy with method for updating specific fields
  UserProfile copyWith({
    String? email,
    String? username,
    String? fullName,
    String? phone,
    String? address,
    // Add new fields to copyWith
    String? addressLine1,
    String? city,
    String? postalCode,
  }) {
    return UserProfile(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      addressLine1: addressLine1 ?? this.addressLine1,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt,
    );
  }
}