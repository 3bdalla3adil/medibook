from odoo import api, fields, models

class MediBookInvoice(models.Model):
    _name="medibook.invoice"
    _description="MediBook Invoice"
    _rec_name="name"

    name=fields.Char(required=True,index=True)
    patient_id=fields.Many2one("medibook.patient",required=True,index=True,ondelete="restrict")
    appointment_id=fields.Many2one("medibook.appointment",index=True,ondelete="restrict")
    organization_id=fields.Many2one(related="patient_id.organization_id",store=True,index=True)
    currency_id=fields.Many2one("res.currency",required=True,default=lambda self:self.env.company.currency_id)
    amount_total=fields.Monetary(required=True,currency_field="currency_id")
    amount_paid=fields.Monetary(required=True,currency_field="currency_id",default=0)
    state=fields.Selection([("draft","Draft"),("posted","Posted"),("paid","Paid"),("cancelled","Cancelled")],default="draft",required=True,index=True)
    line_ids=fields.One2many("medibook.invoice.line","invoice_id")
    payment_ids=fields.One2many("medibook.payment","invoice_id")

class MediBookInvoiceLine(models.Model):
    _name="medibook.invoice.line"
    _description="MediBook Invoice Line"
    invoice_id=fields.Many2one("medibook.invoice",required=True,ondelete="cascade")
    description=fields.Char(required=True)
    quantity=fields.Float(required=True,default=1)
    unit_price=fields.Monetary(required=True,currency_field="currency_id")
    currency_id=fields.Many2one("res.currency",related="invoice_id.currency_id",store=True)
    subtotal=fields.Monetary(compute="_compute_subtotal",store=True,currency_field="currency_id")
    @api.depends("quantity","unit_price")
    def _compute_subtotal(self):
        for r in self:
            r.subtotal=r.quantity*r.unit_price

class MediBookPayment(models.Model):
    _name="medibook.payment"
    _description="MediBook Payment"
    _rec_name="reference"
    invoice_id=fields.Many2one("medibook.invoice",required=True,index=True,ondelete="restrict")
    reference=fields.Char(required=True,index=True)
    provider=fields.Char(required=True)
    provider_payment_token=fields.Char(required=True)
    amount=fields.Monetary(required=True,currency_field="currency_id")
    currency_id=fields.Many2one("res.currency",related="invoice_id.currency_id",store=True)
    state=fields.Selection([("pending","Pending"),("succeeded","Succeeded"),("failed","Failed"),("refunded","Refunded")],default="pending",required=True)
    processed_at=fields.Datetime()
    _reference_unique=models.Constraint("UNIQUE(reference)","Payment reference must be unique.")

class MediBookRefund(models.Model):
    _name="medibook.refund"
    _description="MediBook Refund"
    payment_id=fields.Many2one("medibook.payment",required=True,index=True,ondelete="restrict")
    reference=fields.Char(required=True,index=True)
    amount=fields.Monetary(required=True,currency_field="currency_id")
    currency_id=fields.Many2one("res.currency",related="payment_id.currency_id",store=True)
    state=fields.Selection([("pending","Pending"),("succeeded","Succeeded"),("failed","Failed")],default="pending")
    _reference_unique=models.Constraint("UNIQUE(reference)","Refund reference must be unique.")

class MediBookPaymentMethod(models.Model):
    _name="medibook.payment.method"
    _description="MediBook Payment Method"
    patient_id=fields.Many2one("medibook.patient",required=True,index=True,ondelete="cascade")
    provider=fields.Char(required=True)
    token_reference=fields.Char(required=True)
    label=fields.Char()
    active=fields.Boolean(default=True)
