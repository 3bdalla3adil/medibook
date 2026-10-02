import 'package:flutter/material.dart';
import '../../../../l10n/gen/app_localizations.dart';

class BillingPage extends StatefulWidget {
  const BillingPage({super.key});
  @override State<BillingPage> createState()=>_BillingPageState();
}

class _BillingPageState extends State<BillingPage>{
  String _filter='all';
  final _invoices=[
    ('INV-1001','Consultation','120.00','Paid'),
    ('INV-1002','Laboratory','85.00','Pending'),
    ('INV-1003','Medication','45.00','Paid'),
  ];
  @override Widget build(BuildContext context){
    final l=AppLocalizations.of(context);
    final items=_invoices.where((x)=>_filter=='all'||x.$4.toLowerCase()==_filter).toList();
    return Scaffold(
      appBar:AppBar(title:Text(l.billingTitle)),
      body:ListView(
        padding:const EdgeInsets.all(16),
        children:[
          Row(children:[
            Expanded(child:_summary(context,l.billingOutstanding,'85.00')),
            const SizedBox(width:12),
            Expanded(child:_summary(context,l.billingCollected,'165.00')),
          ]),
          const SizedBox(height:16),
          SegmentedButton<String>(
            segments:[
              ButtonSegment(value:'all',label:Text(l.billingAll)),
              ButtonSegment(value:'paid',label:Text(l.billingPaid)),
              ButtonSegment(value:'pending',label:Text(l.billingPending)),
            ],
            selected:{_filter},
            onSelectionChanged:(v)=>setState(()=>_filter=v.first),
          ),
          const SizedBox(height:12),
          ...items.map((x)=>Card(
            child:ListTile(
              leading:const CircleAvatar(child:Icon(Icons.receipt_long_outlined)),
              title:Text(x.$1),
              subtitle:Text(x.$2),
              trailing:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[
                Text(x.$3,style:const TextStyle(fontWeight:FontWeight.bold)),
                Text(x.$4),
              ]),
            ),
          )),
        ],
      ),
      floatingActionButton:FloatingActionButton.extended(
        onPressed:()=>_showPaymentDialog(context,l),
        icon:const Icon(Icons.add_card_outlined),
        label:Text(l.billingRecordPayment),
      ),
    );
  }
  Widget _summary(BuildContext c,String label,String value)=>Card(
    child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label,style:Theme.of(c).textTheme.labelLarge),const SizedBox(height:6),
      Text(value,style:Theme.of(c).textTheme.headlineSmall),
    ])));
  Future<void> _showPaymentDialog(BuildContext context,AppLocalizations l) async{
    final amount=TextEditingController();
    final formKey=GlobalKey<FormState>();
    await showDialog<void>(context:context,builder:(dialogContext)=>AlertDialog(
      title:Text(l.billingRecordPayment),
      content:Form(key:formKey,child:TextFormField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:l.billingAmount),validator:(v)=>double.tryParse(v??'')==null?l.billingInvalidAmount:null)),
      actions:[
        TextButton(onPressed:()=>Navigator.pop(dialogContext),child:Text(l.actionClose)),
        FilledButton(onPressed:(){if(formKey.currentState!.validate())Navigator.pop(dialogContext);},child:Text(l.actionSave)),
      ],
    ));
    amount.dispose();
  }
}
