import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/triage_vitals.dart';
import '../bloc/triage_cubit.dart';
import '../triage_cubit_factory.dart';

class TriagePage extends StatelessWidget {
  const TriagePage({super.key,required this.appointmentId});
  final String appointmentId;
  @override
  Widget build(BuildContext context)=>BlocProvider(
    create:(_)=>buildTriageCubit(appointmentId)..load(),
    child:const _TriageView(),
  );
}

class _TriageView extends StatefulWidget {
  const _TriageView();
  @override State<_TriageView> createState()=>_TriageViewState();
}
class _TriageViewState extends State<_TriageView> {
  final _sys=TextEditingController(),_dia=TextEditingController(),_hr=TextEditingController(),
      _temp=TextEditingController(),_spo2=TextEditingController(),_weight=TextEditingController(),
      _height=TextEditingController(),_resp=TextEditingController(),_pain=TextEditingController(),
      _note=TextEditingController();
  bool urgent=false; bool initialized=false;
  @override void dispose(){for(final c in [_sys,_dia,_hr,_temp,_spo2,_weight,_height,_resp,_pain,_note]){c.dispose();}super.dispose();}
  void _fill(TriageVitals? v){
    if(initialized||v==null)return; initialized=true;
    _sys.text=v.bloodPressureSystolic?.toString()??''; _dia.text=v.bloodPressureDiastolic?.toString()??'';
    _hr.text=v.heartRate?.toString()??''; _temp.text=v.temperatureC?.toString()??'';
    _spo2.text=v.spo2?.toString()??''; _weight.text=v.weightKg?.toString()??'';
    _height.text=v.heightCm?.toString()??''; _resp.text=v.respiratoryRate?.toString()??'';
    _pain.text=v.painScore?.toString()??''; _note.text=v.note??''; urgent=v.urgent;
  }
  int? _i(TextEditingController c)=>int.tryParse(c.text.trim());
  double? _d(TextEditingController c)=>double.tryParse(c.text.trim());
  Future<void> _save(BuildContext context) async {
    final ok=await context.read<TriageCubit>().save(TriageVitals(
      bloodPressureSystolic:_i(_sys),bloodPressureDiastolic:_i(_dia),heartRate:_i(_hr),
      temperatureC:_d(_temp),spo2:_i(_spo2),weightKg:_d(_weight),heightCm:_d(_height),
      respiratoryRate:_i(_resp),painScore:_i(_pain),note:_note.text.trim().isEmpty?null:_note.text.trim(),urgent:urgent));
    if(ok&&context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(AppLocalizations.of(context).triageSaved)));
  }
  @override Widget build(BuildContext context){
    final l=AppLocalizations.of(context);
    return Scaffold(appBar:AppBar(title:Text(l.triageTitle)),body:BlocBuilder<TriageCubit,TriageState>(
      builder:(context,state){_fill(state.vitals);
        if(state.status==TriageStatus.loading&&state.vitals==null)return const LoadingView();
        if(state.status==TriageStatus.error&&state.vitals==null)return ErrorView(message:l.errorGeneric,onRetry:()=>context.read<TriageCubit>().load());
        final saving=state.status==TriageStatus.saving;
        return ListView(padding:const EdgeInsets.all(16),children:[
          Text(l.triageVitals,style:Theme.of(context).textTheme.titleLarge),const SizedBox(height:16),
          _row(l.bloodPressure,[_sys,_dia],const ['SYS','DIA']),_row(l.heartRate,[_hr],const ['bpm']),
          _row(l.temperature,[_temp],const ['°C']),_row(l.spo2,[_spo2],const ['%']),
          _row(l.weight,[_weight],const ['kg']),_row(l.height,[_height],const ['cm']),
          _row(l.respiratoryRate,[_resp],const ['/min']),_row(l.painScore,[_pain],const ['/10']),
          SwitchListTile(contentPadding:EdgeInsets.zero,title:Text(l.triageUrgent),value:urgent,onChanged:(v)=>setState(()=>urgent=v)),
          TextField(controller:_note,maxLines:3,decoration:InputDecoration(labelText:l.triageNote,border:const OutlineInputBorder())),
          const SizedBox(height:20),
          FilledButton.icon(onPressed:saving?null:()=>_save(context),icon:saving?const SizedBox.square(dimension:18,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.save_outlined),label:Text(l.actionSave)),
        ]);
      }));
  }
  Widget _row(String label,List<TextEditingController> cs,List<String> hints)=>Padding(
    padding:const EdgeInsets.only(bottom:12),child:Row(children:[
      for(var i=0;i<cs.length;i++)...[
        if(i>0)const SizedBox(width:8),Expanded(child:TextField(controller:cs[i],keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:InputDecoration(labelText:i==0?label:null,hintText:hints[i],border:const OutlineInputBorder()))),
      ],
    ]));
}
