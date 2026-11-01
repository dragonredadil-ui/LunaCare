import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/secure_vault.dart';
import 'services/biometric_service.dart';
import 'services/reminder_service.dart';
import 'services/pdf_report_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  runApp(const LunaCareBootstrap());
}

// Shows startup errors on-screen instead of leaving a blank page.
class LunaCareBootstrap extends StatefulWidget {
  const LunaCareBootstrap({super.key});
  @override
  State<LunaCareBootstrap> createState() => _LunaCareBootstrapState();
}

class _LunaCareBootstrapState extends State<LunaCareBootstrap> {
  late Future<void> initialization;

  @override
  void initState() {
    super.initState();
    initialization = _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([
      initializeDateFormatting('ar'),
      initializeDateFormatting('fr'),
      initializeDateFormatting('en'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<void>(
        future: initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: const Color(0xFFFFF8FB),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: ListView(children: [
                    const Icon(Icons.error_outline, size: 52, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('LunaCare startup error',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SelectableText(snapshot.error.toString()),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => setState(() { initialization = _initialize(); }),
                      child: const Text('Try again'),
                    ),
                  ]),
                ),
              ),
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              backgroundColor: Color(0xFFFFF8FB),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const LunaCareApp();
        },
      ),
    );
  }
}

const rose = Color(0xFFD96B9B);
const blush = Color(0xFFF7DCE8);
const lavender = Color(0xFFEAE4F8);
const plum = Color(0xFF68445E);
const ink = Color(0xFF382D38);

class LunaCareApp extends StatefulWidget {
  const LunaCareApp({super.key});
  @override
  State<LunaCareApp> createState() => _LunaCareAppState();
}

class _LunaCareAppState extends State<LunaCareApp> {
  String language = 'ar';
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'LunaCare',
    theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: rose),
      scaffoldBackgroundColor: const Color(0xFFFFF8FB)),
    home: Home(language: language, onLanguage: (v)=>setState(()=>language=v)),
  );
}

const strings = {
'ar': {'home':'الرئيسية','calendar':'التقويم','symptoms':'الأعراض','profile':'الإعدادات',
'hello':'مرحباً بكِ','subtitle':'اعتني بصحتك على راحتك.','next':'الدورة القادمة المتوقعة',
'add':'تسجيل بداية الدورة','history':'سجل الدورات','empty':'لا توجد بيانات بعد.',
'cycle':'طول الدورة المعتاد','days':'يوماً','estimate':'توقع تقريبي وليس موعداً مؤكداً.',
'logday':'تسجيل يومي','mood':'المزاج','pain':'مستوى الألم','symptom':'الأعراض',
'notes':'ملاحظات','save':'حفظ','saved':'تم الحفظ','privacy':'بياناتك تبقى على هذا الجهاز.',
'period':'الدورة','predicted':'موعد متوقع','flow':'تدفق الدورة','low':'خفيف','medium':'متوسط','high':'غزير',
'calm':'هادئ','happy':'سعيدة','tired':'متعبة','anxious':'قلقة','sad':'حزينة',
'cramps':'تقلصات','headache':'صداع','bloating':'انتفاخ','acne':'حب الشباب','tender':'حساسية الثدي',
'none':'لا شيء','reminder':'التذكيرات','reminderInfo':'إعداد التذكيرات سيُفعّل بعد ضبط صلاحيات الإشعارات على الجهاز.',
'export':'تصدير البيانات','exportInfo':'يمكن إضافة تصدير PDF ونسخة احتياطية مشفرة في مرحلة لاحقة.',
'stats':'إحصائيات الدورة','monthly':'بدايات الدورة هذا الشهر','recorded':'الفواصل المسجلة','trend':'تغيّر طول الدورة','notEnough':'سجّلي بداية دورتين على الأقل لعرض الرسم البياني.'},
'fr': {'home':'Accueil','calendar':'Calendrier','symptoms':'Symptômes','profile':'Paramètres',
'hello':'Bonjour','subtitle':'Prenez soin de vous, à votre rythme.','next':'Prochaines règles estimées',
'add':'Enregistrer le début des règles','history':'Historique','empty':'Aucune donnée pour le moment.',
'cycle':'Durée habituelle du cycle','days':'jours','estimate':'Estimation indicative, pas une date certaine.',
'logday':'Journal quotidien','mood':'Humeur','pain':'Niveau de douleur','symptom':'Symptômes',
'notes':'Notes','save':'Enregistrer','saved':'Enregistré','privacy':'Vos données restent sur cet appareil.',
'period':'Règles','predicted':'Date estimée','flow':'Flux','low':'Léger','medium':'Moyen','high':'Abondant',
'calm':'Calme','happy':'Heureuse','tired':'Fatiguée','anxious':'Anxieuse','sad':'Triste',
'cramps':'Crampes','headache':'Mal de tête','bloating':'Ballonnements','acne':'Acné','tender':'Sensibilité des seins',
'none':'Aucun','reminder':'Rappels','reminderInfo':'Les rappels seront activés après configuration des autorisations de notification.',
'export':'Exporter les données','exportInfo':'L’export PDF et la sauvegarde chiffrée seront ajoutés ultérieurement.',
'stats':'Statistiques du cycle','monthly':'Débuts des règles ce mois-ci','recorded':'Intervalles enregistrés','trend':'Évolution de la durée du cycle','notEnough':'Enregistrez au moins deux débuts de règles pour afficher le graphique.'},
'en': {'home':'Home','calendar':'Calendar','symptoms':'Symptoms','profile':'Settings',
'hello':'Hello','subtitle':'Care for yourself, at your own pace.','next':'Next period estimate',
'add':'Log period start','history':'Cycle history','empty':'No data yet.',
'cycle':'Usual cycle length','days':'days','estimate':'An estimate only, not a confirmed date.',
'logday':'Daily log','mood':'Mood','pain':'Pain level','symptom':'Symptoms',
'notes':'Notes','save':'Save','saved':'Saved','privacy':'Your data stays on this device.',
'period':'Period','predicted':'Estimated','flow':'Flow','low':'Light','medium':'Medium','high':'Heavy',
'calm':'Calm','happy':'Happy','tired':'Tired','anxious':'Anxious','sad':'Sad',
'cramps':'Cramps','headache':'Headache','bloating':'Bloating','acne':'Acne','tender':'Breast tenderness',
'none':'None','reminder':'Reminders','reminderInfo':'Reminders can be enabled after device notification permissions are configured.',
'export':'Export data','exportInfo':'PDF export and encrypted backup can be added in a later release.',
'stats':'Cycle statistics','monthly':'Period starts this month','recorded':'Recorded intervals','trend':'Cycle length trend','notEnough':'Log at least two period starts to display the chart.'}
};

class Home extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguage;
  const Home({super.key, required this.language, required this.onLanguage});
  @override
  State<Home> createState()=>_HomeState();
}

class _HomeState extends State<Home> {
  List<DateTime> starts=[];
  Map<String, Map<String,dynamic>> logs={};
  DateTime month=DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected=DateTime.now();
  int tab=0;
  final SecureVault vault = SecureVault();
  final BiometricService biometric = BiometricService();
  final ReminderService reminders = ReminderService();
  final PdfReportService pdfReports = PdfReportService();
  bool notificationsReady = false;
  String get lang=>widget.language;
  String t(String k)=>strings[lang]?[k]??strings['en']![k]!;

  @override
  void initState(){
    super.initState();
    load();
    reminders.initialize().then((_) {
      if (mounted) setState(() => notificationsReady = true);
    }).catchError((_) {});
  }
  Future<void> load() async {
    try {
      final data = await vault.readJson();
      if (data.isNotEmpty) {
        starts = (data['starts'] as List? ?? [])
            .map((v) => DateTime.parse(v.toString())).toList()
          ..sort((a,b)=>b.compareTo(a));
        final rawLogs = data['logs'] as Map? ?? {};
        logs = rawLogs.map((k,v)=>MapEntry(k, Map<String,dynamic>.from(v as Map)));
      } else {
        // One-time migration from the previous unencrypted starter version.
        final p = await SharedPreferences.getInstance();
        starts = (p.getStringList('period_starts_v2') ?? [])
            .map(DateTime.parse).toList()..sort((a,b)=>b.compareTo(a));
        final raw = p.getString('daily_logs_v2');
        if (raw != null) {
          try {
            logs = (jsonDecode(raw) as Map<String,dynamic>)
                .map((k,v)=>MapEntry(k,Map<String,dynamic>.from(v)));
          } catch (_) {}
        }
        if (starts.isNotEmpty || logs.isNotEmpty) await persist();
        await p.remove('period_starts_v2');
        await p.remove('daily_logs_v2');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read saved data.')),
        );
      }
    }
    if(mounted)setState((){});
  }
  String key(DateTime d)=>DateFormat('yyyy-MM-dd').format(d);
  Future<void> persist() async {
    await vault.saveJson({
      'starts': starts.map((d)=>d.toIso8601String()).toList(),
      'logs': logs,
    });
  }
  Future<void> askForReminder() async {
    final allowed = await reminders.requestPermission();
    if (!allowed) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification permission was not granted.')),
      );
      return;
    }
    final estimate = next;
    if (estimate == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record at least one period start first.')),
      );
      return;
    }
    final when = DateTime(estimate.year, estimate.month, estimate.day, 9);
    if (when.isBefore(DateTime.now())) return;
    await reminders.scheduleReminder(
      id: 1, localDateTime: when,
      title: 'LunaCare', body: 'Your cycle estimate is approaching.',
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder scheduled on this device.')),
    );
  }
  Future<void> unlockWithBiometrics() async {
    final available = await biometric.isAvailable();
    final ok = available && await biometric.authenticate();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Authentication successful.' :
        'Biometric authentication is unavailable or was not completed.')),
    );
  }
  Future<void> exportPdf() async {
    await pdfReports.previewReport(
      periodStarts: starts, dailyLogs: logs, language: lang,
    );
  }
  int get avg {
    if(starts.length<2)return 28;
    final a=starts.reversed.toList(); final gaps=<int>[];
    for(int i=1;i<a.length;i++){final n=a[i].difference(a[i-1]).inDays;if(n>=15&&n<=60)gaps.add(n);}
    return gaps.isEmpty?28:(gaps.reduce((x,y)=>x+y)/gaps.length).round();
  }
  DateTime? get next=>starts.isEmpty?null:starts.first.add(Duration(days:avg));

  List<int> get cycleLengths {
    final chronological = starts.toList()..sort((a,b)=>a.compareTo(b));
    final values = <int>[];
    for (var i = 1; i < chronological.length; i++) {
      final days = chronological[i].difference(chronological[i-1]).inDays;
      if (days >= 15 && days <= 60) values.add(days);
    }
    return values.length > 6 ? values.sublist(values.length - 6) : values;
  }

  int get startsThisMonth => starts.where((d) =>
    d.year == DateTime.now().year && d.month == DateTime.now().month).length;
  Future<void> addPeriod() async {
    final now=DateTime.now();
    final d=await showDatePicker(context:context,initialDate:now,firstDate:DateTime(now.year-4),lastDate:DateTime(now.year+1));
    if(d==null)return;
    final v=DateTime(d.year,d.month,d.day);
    if(!starts.any((x)=>key(x)==key(v))){starts.add(v);starts.sort((a,b)=>b.compareTo(a));await persist();setState((){});}
  }
  bool isPeriod(DateTime d)=>starts.any((s)=>!d.isBefore(s)&&d.difference(s).inDays<5);
  bool isPredicted(DateTime d) {
    final estimate = next;
    if (estimate == null) return false;
    final day = DateTime(d.year, d.month, d.day);
    final start = DateTime(estimate.year, estimate.month, estimate.day);
    return !day.isBefore(start) && day.isBefore(start.add(const Duration(days: 5)));
  }

  @override
  Widget build(BuildContext context)=>Directionality(
    textDirection:lang=='ar'?ui.TextDirection.rtl:ui.TextDirection.ltr,
    child:Scaffold(
      appBar:AppBar(title:const Text('🌙 LunaCare',style:TextStyle(fontWeight:FontWeight.w800,color:plum)),
        actions:[PopupMenuButton<String>(onSelected:widget.onLanguage,itemBuilder:(_)=>const [
          PopupMenuItem(value:'ar',child:Text('العربية')),PopupMenuItem(value:'fr',child:Text('Français')),PopupMenuItem(value:'en',child:Text('English'))],
          child:const Padding(padding:EdgeInsets.symmetric(horizontal:16),child:Icon(Icons.language)))]),
      body:IndexedStack(index:tab,children:[dashboard(),calendarPage(),symptomsPage(),settingsPage()]),
      bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:[
        NavigationDestination(icon:const Icon(Icons.home_outlined),label:t('home')),
        NavigationDestination(icon:const Icon(Icons.calendar_month_outlined),label:t('calendar')),
        NavigationDestination(icon:const Icon(Icons.favorite_border),label:t('symptoms')),
        NavigationDestination(icon:const Icon(Icons.settings_outlined),label:t('profile')),
      ]),
    ),
  );

  Widget dashboard()=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(t('hello'),style:const TextStyle(fontSize:28,fontWeight:FontWeight.w800,color:ink)),
    Text(t('subtitle'),style:const TextStyle(color:Colors.black54)),
    const SizedBox(height:20),
    Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(
      gradient:const LinearGradient(colors:[blush,lavender]),borderRadius:BorderRadius.circular(26)),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(t('next'),style:const TextStyle(color:plum,fontWeight:FontWeight.w700)),
        const SizedBox(height:10),
        Text(next==null?'—':DateFormat('d MMMM yyyy',lang).format(next!),style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:plum)),
        const SizedBox(height:8),Text(t('estimate'),style:const TextStyle(color:plum)),
      ])),
    const SizedBox(height:14),
    Card(elevation:0,color:Colors.white,child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${t('cycle')}: $avg ${t('days')}',style:const TextStyle(fontWeight:FontWeight.w700)),
      const SizedBox(height:12),SizedBox(width:double.infinity,child:FilledButton.icon(
        style:FilledButton.styleFrom(backgroundColor:rose),onPressed:addPeriod,icon:const Icon(Icons.add),label:Text(t('add')))),
    ]))),
    const SizedBox(height:10),
    Card(elevation:0,color:Colors.white,child:ListTile(leading:const Icon(Icons.lock_outline,color:rose),title:Text(t('privacy')))),
    const SizedBox(height:12),Text(t('history'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
    if(starts.isEmpty)Text(t('empty')),
    ...starts.take(4).map((d)=>ListTile(leading:const Icon(Icons.water_drop_outlined,color:rose),title:Text(DateFormat('d MMM yyyy',lang).format(d)))),
    const SizedBox(height:18),
    Text(t('stats'),style:const TextStyle(fontSize:18,fontWeight:FontWeight.bold,color:plum)),
    const SizedBox(height:8),
    Card(elevation:0,color:Colors.white,child:Padding(padding:const EdgeInsets.all(16),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
        _statLine(t('monthly'), startsThisMonth.toString()),
        const Divider(height:20),
        _statLine(t('recorded'), cycleLengths.length.toString()),
        const SizedBox(height:16),
        Text(t('trend'),style:const TextStyle(fontWeight:FontWeight.w700,color:plum)),
        const SizedBox(height:12),
        if (cycleLengths.isEmpty)
          Text(t('notEnough'),style:const TextStyle(color:Colors.black54))
        else
          SizedBox(height:170,width:double.infinity,child:CycleTrendChart(values:cycleLengths)),
        const SizedBox(height:8),
        Text(t('estimate'),style:const TextStyle(fontSize:11,color:Colors.black54)),
      ],
    ))),
  ]);

  Widget _statLine(String label, String value) => Row(
    mainAxisAlignment:MainAxisAlignment.spaceBetween,
    children:[Expanded(child:Text(label)),Text(value,style:const TextStyle(fontWeight:FontWeight.bold,color:plum))],
  );

  Widget calendarPage(){
    final first=DateTime(month.year,month.month,1);
    final offset=(first.weekday-1);
    final count=DateTime(month.year,month.month+1,0).day;
    final cells=<Widget>[];
    for(int i=0;i<offset;i++)cells.add(const SizedBox());
    for(int day=1;day<=count;day++){
      final d=DateTime(month.year,month.month,day);
      final p=isPeriod(d), pred=isPredicted(d), chosen=key(d)==key(selected);
      cells.add(InkWell(onTap:()=>setState(()=>selected=d),borderRadius:BorderRadius.circular(14),
        child:Container(margin:const EdgeInsets.all(3),decoration:BoxDecoration(
          color:chosen?plum:p?rose.withOpacity(.22):pred?lavender:Colors.white,
          borderRadius:BorderRadius.circular(13),border:chosen?Border.all(color:rose,width:2):null),
          child:Center(child:Text('$day',style:TextStyle(fontWeight:FontWeight.w700,color:chosen?Colors.white:ink))))));
    }
    final weekdays=lang=='ar'?['ن','ث','ر','خ','ج','س','ح']:lang=='fr'?['L','M','M','J','V','S','D']:['M','T','W','T','F','S','S'];
    return ListView(padding:const EdgeInsets.all(16),children:[
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
        IconButton(onPressed:()=>setState(()=>month=DateTime(month.year,month.month-1)),icon:const Icon(Icons.chevron_left)),
        Text(DateFormat('MMMM yyyy',lang).format(month),style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold,color:plum)),
        IconButton(onPressed:()=>setState(()=>month=DateTime(month.year,month.month+1)),icon:const Icon(Icons.chevron_right)),
      ]),
      GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:7,children:[
        ...weekdays.map((x)=>Center(child:Text(x,style:const TextStyle(fontWeight:FontWeight.bold,color:plum)))),
        ...cells,
      ]),
      const SizedBox(height:14),
      Wrap(spacing:12,runSpacing:8,children:[
        legend(rose,t('period')),legend(lavender,t('predicted')),
      ]),
      const SizedBox(height:16),
      Card(elevation:0,color:Colors.white,child:ListTile(title:Text(DateFormat('d MMMM yyyy',lang).format(selected)),
        subtitle:Text(logs[key(selected)]?['notes']?.toString()??t('logday')))),
      FilledButton(onPressed:()=>setState(()=>tab=2),style:FilledButton.styleFrom(backgroundColor:rose),child:Text(t('logday'))),
    ]);
  }
  Widget legend(Color c,String s)=>Row(mainAxisSize:MainAxisSize.min,children:[
    Container(width:12,height:12,decoration:BoxDecoration(color:c,borderRadius:BorderRadius.circular(4))),
    const SizedBox(width:5),Text(s,style:const TextStyle(fontSize:12)),
  ]);

  Widget symptomsPage()=>SymptomEditor(language:lang,selected:selected,initial:logs[key(selected)]??{},
    onSave:(v)async{logs[key(selected)]=v;await persist();if(mounted){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t('saved'))));setState((){});}});

  Widget settingsPage()=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(t('profile'),style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:ink)),
    Card(elevation:0,color:Colors.white,child:Column(children:[
      ListTile(leading:const Icon(Icons.language,color:rose),title:const Text('Language'),trailing:DropdownButton<String>(
        value:lang,items:const [DropdownMenuItem(value:'ar',child:Text('العربية')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'en',child:Text('English'))],
        onChanged:(v){if(v!=null)widget.onLanguage(v);})),
      ListTile(leading:const Icon(Icons.notifications_none,color:rose),title:Text(t('reminder')),subtitle:Text(t('reminderInfo')),onTap:askForReminder),
      ListTile(leading:const Icon(Icons.file_download_outlined,color:rose),title:Text(t('export')),subtitle:Text(t('exportInfo')),onTap:exportPdf),
      ListTile(leading:const Icon(Icons.fingerprint,color:rose),title:const Text('Biometric check'),subtitle:const Text('Test device authentication'),onTap:unlockWithBiometrics),
      ListTile(leading:const Icon(Icons.shield_outlined,color:rose),title:Text(t('privacy'))),
    ])),
    const SizedBox(height:12),
    const Text('LunaCare ne remplace pas un avis médical. Les prévisions du cycle ne sont pas une méthode contraceptive.',style:TextStyle(color:Colors.black54,fontSize:12)),
  ]);
}

class CycleTrendChart extends StatelessWidget {
  final List<int> values;
  const CycleTrendChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      painter: _CycleTrendPainter(values),
      child: const SizedBox.expand(),
    );
  }
}

class _CycleTrendPainter extends CustomPainter {
  final List<int> values;
  _CycleTrendPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;
    const minDays = 15.0;
    const maxDays = 60.0;
    final left = 24.0;
    final right = size.width - 12.0;
    final top = 12.0;
    final bottom = size.height - 18.0;
    final gridPaint = Paint()..color = const Color(0xFFEFE7ED)..strokeWidth = 1;
    final linePaint = Paint()..color = rose..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final dotPaint = Paint()..color = rose..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      final y = top + (bottom - top) * i / 3;
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? (left + right) / 2
          : left + (right - left) * i / (values.length - 1);
      final bounded = values[i].clamp(minDays.toInt(), maxDays.toInt()).toDouble();
      final y = bottom - (bounded - minDays) / (maxDays - minDays) * (bottom - top);
      points.add(Offset(x, y));
    }
    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) { path.lineTo(point.dx, point.dy); }
      canvas.drawPath(path, linePaint);
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, dotPaint);
      final label = TextPainter(
        text: TextSpan(text: '${values[i]}', style: const TextStyle(fontSize:10,color:plum,fontWeight:FontWeight.w600)),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelX = (points[i].dx - label.width / 2).clamp(0.0, size.width - label.width);
      final labelY = (points[i].dy - 19).clamp(0.0, size.height - label.height);
      label.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _CycleTrendPainter oldDelegate) => oldDelegate.values != values;
}

class SymptomEditor extends StatefulWidget {
  final String language;
  final DateTime selected;
  final Map<String,dynamic> initial;
  final ValueChanged<Map<String,dynamic>> onSave;
  const SymptomEditor({super.key,required this.language,required this.selected,required this.initial,required this.onSave});
  @override
  State<SymptomEditor> createState()=>_SymptomEditorState();
}
class _SymptomEditorState extends State<SymptomEditor>{
  late String mood;
  late double pain;
  late String flow;
  late Set<String> symptoms;
  late TextEditingController notes;
  String t(String k)=>strings[widget.language]?[k]??strings['en']![k]!;
  final symptomKeys=['cramps','headache','bloating','acne','tender'];
  @override
  void initState(){super.initState();mood=widget.initial['mood']??'calm';pain=(widget.initial['pain']??0).toDouble();flow=widget.initial['flow']??'none';symptoms=Set<String>.from(widget.initial['symptoms']??[]);notes=TextEditingController(text:widget.initial['notes']??'');}
  @override
  void dispose(){notes.dispose();super.dispose();}
  @override
  Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
    Text(t('logday'),style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold,color:ink)),
    const SizedBox(height:4),Text(DateFormat('d MMMM yyyy',widget.language).format(widget.selected),style:const TextStyle(color:plum)),
    const SizedBox(height:18),Text(t('mood'),style:const TextStyle(fontWeight:FontWeight.bold)),
    const SizedBox(height:8),Wrap(spacing:8,children:['calm','happy','tired','anxious','sad'].map((m)=>ChoiceChip(
      label:Text(t(m)),selected:mood==m,onSelected:(_)=>setState(()=>mood=m),selectedColor:blush)).toList()),
    const SizedBox(height:18),Text('${t('pain')}: ${pain.round()}/5',style:const TextStyle(fontWeight:FontWeight.bold)),
    Slider(value:pain,min:0,max:5,divisions:5,activeColor:rose,onChanged:(v)=>setState(()=>pain=v)),
    const SizedBox(height:8),Text(t('flow'),style:const TextStyle(fontWeight:FontWeight.bold)),
    Wrap(spacing:8,children:['none','low','medium','high'].map((f)=>ChoiceChip(label:Text(t(f)),selected:flow==f,onSelected:(_)=>setState(()=>flow=f),selectedColor:blush)).toList()),
    const SizedBox(height:18),Text(t('symptom'),style:const TextStyle(fontWeight:FontWeight.bold)),
    ...symptomKeys.map((s)=>CheckboxListTile(contentPadding:EdgeInsets.zero,dense:true,title:Text(t(s)),value:symptoms.contains(s),activeColor:rose,
      onChanged:(v)=>setState(()=>v==true?symptoms.add(s):symptoms.remove(s)))),
    const SizedBox(height:10),Text(t('notes'),style:const TextStyle(fontWeight:FontWeight.bold)),
    TextField(controller:notes,maxLines:3,decoration:InputDecoration(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),
    const SizedBox(height:18),FilledButton(style:FilledButton.styleFrom(backgroundColor:rose,padding:const EdgeInsets.all(15)),
      onPressed:()=>widget.onSave({'mood':mood,'pain':pain.round(),'flow':flow,'symptoms':symptoms.toList(),'notes':notes.text}),child:Text(t('save'))),
  ]);
}
