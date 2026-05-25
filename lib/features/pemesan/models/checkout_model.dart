/// Respons dari POST /checkout
class CheckoutResultModel {
  final String paymentId;

  /// null jika tiket gratis, berisi URL Xendit jika tiket berbayar
  final String? paymentUrl;

  CheckoutResultModel({required this.paymentId, this.paymentUrl});

  factory CheckoutResultModel.fromJson(Map<String, dynamic> json) {
    return CheckoutResultModel(
      paymentId: json['payment_id'] ?? '',
      paymentUrl: json['payment_url'],
    );
  }

  bool get isFree => paymentUrl == null;
}
