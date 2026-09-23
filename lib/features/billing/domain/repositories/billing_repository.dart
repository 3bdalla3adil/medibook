import '../../../../core/error/result.dart';
import '../entities/billing.dart';

abstract interface class BillingRepository {
  Future<Result<List<Invoice>>> getInvoices();
  Future<Result<Invoice?>> getInvoice(String id);
  Future<Result<List<PaymentMethod>>> getPaymentMethods();
  Future<Result<Payment>> createPayment({required String invoiceId, required String paymentMethodToken, required int amount, required String currency, required String idempotencyKey});
  Future<Result<Refund>> refundPayment({required String paymentId, required int amount, String? reason});
}
