class Review {
  final String id;
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final DateTime date;
  final bool verifiedPurchase;

  Review({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.verifiedPurchase = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'userAvatar': userAvatar,
    'rating': rating,
    'comment': comment,
    'date': date.toIso8601String(),
    'verifiedPurchase': verifiedPurchase,
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    userName: json['userName'] as String,
    userAvatar: json['userAvatar'] as String? ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'] as String,
    date: DateTime.parse(json['date'] as String),
    verifiedPurchase: json['verifiedPurchase'] as bool? ?? true,
  );
}
