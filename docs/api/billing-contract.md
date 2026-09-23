# Billing API Contract

**Status: backend dependency — no billing UI is implemented.**

The mobile client must not collect or store raw card data. Payment processing must be delegated to a PCI-scoped provider/tokenization flow defined by the backend.

## Endpoints

- `GET /billing/invoices`
- `GET /billing/invoices/{id}`
- `POST /billing/payments`
- `POST /billing/payments/{id}/refund`
- `GET /billing/payment-methods`

## Payment request

The client sends a provider-issued payment method token/reference, not PAN, CVV or full card data.

The server revalidates invoice ownership, amount, currency, status, organization scope and payment state.

## Webhooks

Payment/refund state is authoritative only after verified provider webhook processing. The mobile app never marks an invoice paid locally.

## PCI boundary

Before UI implementation, document the selected payment provider, hosted/tokenized payment flow, SAQ/PCI scope, webhook verification and refund policy.

No payment UI is implemented until this contract is approved by the backend/payment owner.
