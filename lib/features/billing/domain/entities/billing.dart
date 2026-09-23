import 'package:equatable/equatable.dart';

enum PaymentMethodType { cardToken, bankTransfer, cash, insurance }
enum PaymentStatus { pending, authorized, captured, failed, refunded, partiallyRefunded }

class PaymentMethod extends Equatable {
  const PaymentMethod({required this.id, required this.type, this.displayLabel});
  final String id;
  final PaymentMethodType type;
  final String? displayLabel;
  @override List<Object?> get props => [id, type, displayLabel];
}

class InvoiceLine extends Equatable {
  const InvoiceLine({required this.id, required this.description, required this.quantity, required this.unitAmount, required this.totalAmount});
  final String id; final String description; final int quantity; final int unitAmount; final int totalAmount;
  @override List<Object?> get props => [id, description, quantity, unitAmount, totalAmount];
}

class Invoice extends Equatable {
  const Invoice({required this.id, required this.patientId, required this.currency, required this.totalAmount, required this.status, required this.issuedAt, required this.lines, this.dueAt});
  final String id; final String patientId; final String currency; final int totalAmount; final PaymentStatus status; final DateTime issuedAt; final DateTime? dueAt; final List<InvoiceLine> lines;
  @override List<Object?> get props => [id, patientId, currency, totalAmount, status, issuedAt, dueAt, lines];
}

class Payment extends Equatable {
  const Payment({required this.id, required this.invoiceId, required this.amount, required this.currency, required this.status, required this.createdAt, this.providerReference});
  final String id; final String invoiceId; final int amount; final String currency; final PaymentStatus status; final DateTime createdAt; final String? providerReference;
  @override List<Object?> get props => [id, invoiceId, amount, currency, status, createdAt, providerReference];
}

class Refund extends Equatable {
  const Refund({required this.id, required this.paymentId, required this.amount, required this.currency, required this.createdAt, this.reason});
  final String id; final String paymentId; final int amount; final String currency; final DateTime createdAt; final String? reason;
  @override List<Object?> get props => [id, paymentId, amount, currency, createdAt, reason];
}
