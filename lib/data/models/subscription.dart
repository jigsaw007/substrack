class Subscription {
  final String id;
  final String name;
  final double price;
  final String cycle;
  final DateTime renewalDate;
  final String userId;
  final String? category;
  final String? notes; // 👈 ADD THIS

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.cycle,
    required this.renewalDate,
    required this.userId,
    this.category,
    this.notes, // 👈 ADD THIS
  });

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      cycle: map['cycle'],
      renewalDate: DateTime.parse(map['renewal_date']),
      userId: map['user_id'],
      category: map['category'],
      notes: map['notes'], // 👈 ADD THIS
    );
  }

  Map<String, dynamic> toMap(String userId) {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cycle': cycle,
      'renewal_date': renewalDate.toIso8601String(),
      'user_id': userId,
      'category': category,
      'notes': notes, // 👈 ADD THIS
    };
  }
}
