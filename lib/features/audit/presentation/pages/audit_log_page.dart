import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/result.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/audit_entry.dart';
import '../../domain/repositories/audit_repository.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});
  @override State<AuditLogPage> createState()=>_AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage>{
  late Future<Result<List<AuditEntry>>> _future;

  @override void initState(){super.initState();_reload();}

  void _reload()=>_future=getIt<AuditRepository>().getEntries();

  @override Widget build(BuildContext context){
    final l=AppLocalizations.of(context);
    return Scaffold(
      appBar:AppBar(title:Text(l.settingsAuditLog),actions:[
        IconButton(onPressed:()=>setState(_reload),icon:const Icon(Icons.refresh_outlined)),
      ]),
      body:FutureBuilder<Result<List<AuditEntry>>>(
        future:_future,
        builder:(context,snapshot){
          if(!snapshot.hasData)return const Center(child:CircularProgressIndicator.adaptive());
          final result=snapshot.data!;
          return switch(result){
            Ok(value:final entries) when entries.isEmpty=>Center(child:Text(l.stateEmpty)),
            Ok(value:final entries)=>RefreshIndicator(
              onRefresh:()async{setState(_reload);await _future;},
              child:ListView.separated(
                padding:const EdgeInsets.all(16),
                itemCount:entries.length,
                separatorBuilder:(_,__)=>const SizedBox(height:8),
                itemBuilder:(context,index){
                  final e=entries[index];
                  return Card(child:ListTile(
                    leading:const CircleAvatar(child:Icon(Icons.history_outlined)),
                    title:Text(e.action),
                    subtitle:Text(e.entityType+' · '+e.entityId+'\n'+DateFormat.yMd(Localizations.localeOf(context).toLanguageTag()).add_jm().format(e.occurredAt.toLocal())),
                    isThreeLine:true,
                    trailing:Text(e.outcome),
                  ));
                },
              ),
            ),
            Err()=>Center(child:Padding(
              padding:const EdgeInsets.all(24),
              child:Text(l.errorGeneric,textAlign:TextAlign.center),
            )),
          };
        },
      ),
    );
  }
}
