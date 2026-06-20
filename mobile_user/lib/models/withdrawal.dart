class Withdrawal {
  final int id;
  final double amount;
  final String maskedCard;
  final String cardHolder;
  final String status;
  final DateTime createdAt;

  Withdrawal({
    required this.id,
    required this.amount,
    required this.maskedCard,
    required this.cardHolder,
    required this.status,
    required this.createdAt,
  });

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        id: json['id'] as int,
        amount: double.tryParse('${json['amount']}') ?? 0,
        maskedCard: json['masked_card'] as String? ?? '',
        cardHolder: json['card_holder'] as String? ?? '',
        status: json['status'] as String,
        createdAt: DateTime.tryParse('${json['created_at']}') ?? DateTime.now(),
      );
}
