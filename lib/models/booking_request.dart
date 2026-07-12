class BookingRequest {
  BookingRequest({
    required this.id,
    required this.name,
    required this.phone,
    required this.serviceInterest,
    this.preferredDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String name;
  final String phone;
  final String serviceInterest;
  final DateTime? preferredDate;
  final String notes;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'serviceInterest': serviceInterest,
        'preferredDate': preferredDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BookingRequest.fromJson(Map<String, dynamic> json) {
    return BookingRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      serviceInterest: json['serviceInterest'] as String,
      preferredDate: json['preferredDate'] != null
          ? DateTime.parse(json['preferredDate'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
