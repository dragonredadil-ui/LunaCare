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
                    const Icon(Icons.error_outline,
                        size: 52, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'LunaCare startup error',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(snapshot.error.toString()),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () =>
                          setState(() => initialization = _initialize()),
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

const strings = {
  'ar': {
    'home': 'الرئيسية',
    'calendar': 'التقويم',
    'symptoms': 'الأعراض',
    'profile': 'الإعدادات',
    'hello': 'مرحباً بكِ',
    'subtitle': 'اعتني بصحتك على راحتك.',
    'next': 'الدورة القادمة المتوقعة',
    'add': 'تسجيل بداية الدورة',
    'history': 'سجل الدورات',
    'empty': 'لا توجد بيانات بعد.',
    'cycle': 'طول الدورة المعتاد',
    'days': 'يوماً',
    'estimate': 'توقع تقريبي وليس موعداً مؤكداً.',
    'countdown': 'الوقت المتبقي تقريباً',
    'dueToday': 'التاريخ المتوقع هو اليوم',
    'overdue': 'تجاوز التاريخ المتوقع بـ',
    'logday': 'تسجيل يومي',
    'mood': 'المزاج',
    'pain': 'مستوى الألم',
    'symptom': 'الأعراض',
    'notes': 'ملاحظات',
    'save': 'حفظ',
    'saved': 'تم الحفظ',
    'privacy': 'بياناتك تبقى على هذا الجهاز.',
    'period': 'الدورة',
    'predicted': 'موعد متوقع',
    'flow': 'تدفق الدورة',
    'low': 'خفيف',
    'medium': 'متوسط',
    'high': 'غزير',
    'calm': 'هادئ',
    'happy': 'سعيدة',
    'tired': 'متعبة',
    'anxious': 'قلقة',
    'sad': 'حزينة',
    'cramps': 'تقلصات',
    'headache': 'صداع',
    'bloating': 'انتفاخ',
    'acne': 'حب الشباب',
    'tender': 'حساسية الثدي',
    'none': 'لا شيء',
    'reminder': 'التذكيرات',
    'reminderInfo':
        'إعداد التذكيرات سيُفعّل بعد ضبط صلاحيات الإشعارات على الجهاز.',
    'export': 'تصدير البيانات',
    'exportInfo':
        'يمكن إضافة تصدير PDF ونسخة احتياطية مشفرة في مرحلة لاحقة.',
    'markStart': 'تحديد بداية الدورة',
    'markEnd': 'تحديد نهاية الدورة',
    'startSaved': 'تم تسجيل بداية الدورة.',
    'endSaved': 'تم تسجيل نهاية الدورة.',
    'noOpenPeriod': 'سجلي بداية الدورة أولاً قبل تحديد نهايتها.',
    'endBeforeStart': 'تاريخ النهاية لا يمكن أن يسبق تاريخ البداية.',
    'alreadyStart': 'هذا التاريخ مسجل كبداية دورة بالفعل.',
    'alreadyEnd': 'هذا التاريخ مسجل كنهاية دورة بالفعل.',
  },

  'fr': {
    'home': 'Accueil',
    'calendar': 'Calendrier',
    'symptoms': 'Symptômes',
    'profile': 'Paramètres',
    'hello': 'Bonjour',
    'subtitle': 'Prenez soin de vous, à votre rythme.',
    'next': 'Prochaines règles estimées',
    'add': 'Enregistrer le début des règles',
    'history': 'Historique',
    'empty': 'Aucune donnée pour le moment.',
    'cycle': 'Durée habituelle du cycle',
    'days': 'jours',
    'estimate': 'Estimation indicative, pas une date certaine.',
    'countdown': 'Temps restant estimé',
    'dueToday': 'La date estimée est aujourd’hui',
    'overdue': 'Date estimée dépassée de',
    'logday': 'Journal quotidien',
    'mood': 'Humeur',
    'pain': 'Niveau de douleur',
    'symptom': 'Symptômes',
    'notes': 'Notes',
    'save': 'Enregistrer',
    'saved': 'Enregistré',
    'privacy': 'Vos données restent sur cet appareil.',
    'period': 'Règles',
    'predicted': 'Date estimée',
    'flow': 'Flux',
    'low': 'Léger',
    'medium': 'Moyen',
    'high': 'Abondant',
    'calm': 'Calme',
    'happy': 'Heureuse',
    'tired': 'Fatiguée',
    'anxious': 'Anxieuse',
    'sad': 'Triste',
    'cramps': 'Crampes',
    'headache': 'Mal de tête',
    'bloating': 'Ballonnements',
    'acne': 'Acné',
    'tender': 'Sensibilité des seins',
    'none': 'Aucun',
    'reminder': 'Rappels',
    'reminderInfo':
        'Les rappels seront activés après configuration des autorisations de notification.',
    'export': 'Exporter les données',
    'exportInfo':
        'L’export PDF et la sauvegarde chiffrée seront ajoutés ultérieurement.',
    'markStart': 'Marquer le début des règles',
    'markEnd': 'Marquer la fin des règles',
    'startSaved': 'Début des règles enregistré.',
    'endSaved': 'Fin des règles enregistrée.',
    'noOpenPeriod': 'Enregistrez d’abord un début de règles.',
    'endBeforeStart': 'La fin ne peut pas précéder le début.',
    'alreadyStart': 'Cette date est déjà enregistrée comme début.',
    'alreadyEnd': 'Cette date est déjà enregistrée comme fin.',
  },

  'en': {
    'home': 'Home',
    'calendar': 'Calendar',
    'symptoms': 'Symptoms',
    'profile': 'Settings',
    'hello': 'Hello',
    'subtitle': 'Care for yourself, at your own pace.',
    'next': 'Next period estimate',
    'add': 'Log period start',
    'history': 'Cycle history',
    'empty': 'No data yet.',
    'cycle': 'Usual cycle length',
    'days': 'days',
    'estimate': 'An estimate only, not a confirmed date.',
    'countdown': 'Estimated time remaining',
    'dueToday': 'The estimated date is today',
    'overdue': 'Estimated date passed by',
    'logday': 'Daily log',
    'mood': 'Mood',
    'pain': 'Pain level',
    'symptom': 'Symptoms',
    'notes': 'Notes',
    'save': 'Save',
    'saved': 'Saved',
    'privacy': 'Your data stays on this device.',
    'period': 'Period',
    'predicted': 'Estimated',
    'flow': 'Flow',
    'low': 'Light',
    'medium': 'Medium',
    'high': 'Heavy',
    'calm': 'Calm',
    'happy': 'Happy',
    'tired': 'Tired',
    'anxious': 'Anxious',
    'sad': 'Sad',
    'cramps': 'Cramps',
    'headache': 'Headache',
    'bloating': 'Bloating',
    'acne': 'Acne',
    'tender': 'Breast tenderness',
    'none': 'None',
    'reminder': 'Reminders',
    'reminderInfo':
        'Reminders can be enabled after device notification permissions are configured.',
    'export': 'Export data',
    'exportInfo':
        'PDF export and encrypted backup can be added in a later release.',
    'markStart': 'Mark period start',
    'markEnd': 'Mark period end',
    'startSaved': 'Period start saved.',
    'endSaved': 'Period end saved.',
    'noOpenPeriod': 'Record a period start before recording its end.',
    'endBeforeStart': 'The end date cannot be before the start date.',
    'alreadyStart': 'This date is already recorded as a start.',
    'alreadyEnd': 'This date is already recorded as an end.',
  },
};
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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: rose),
          scaffoldBackgroundColor: const Color(0xFFFFF8FB),
        ),
        home: Home(
          language: language,
          onLanguage: (v) => setState(() => language = v),
        ),
      );
}

class Home extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguage;

  const Home({
    super.key,
    required this.language,
    required this.onLanguage,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<DateTime> starts = [];
  List<DateTime> ends = [];

  Map<String, Map<String, dynamic>> logs = {};

  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected = DateTime.now();

  int tab = 0;

  final SecureVault vault = SecureVault();
  final BiometricService biometric = BiometricService();
  final ReminderService reminders = ReminderService();
  final PdfReportService pdfReports = PdfReportService();

  bool notificationsReady = false;

  String get lang => widget.language;
  String t(String k) => strings[lang]?[k] ?? strings['en']![k]!;

  DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    load();

    reminders.initialize().then((_) {
      if (mounted) setState(() => notificationsReady = true);
    }).catchError((_) {});
  }

  String key(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> load() async {
    try {
      final data = await vault.readJson();

      if (data.isNotEmpty) {
        starts = (data['starts'] as List? ?? [])
            .map((v) => dateOnly(DateTime.parse(v.toString())))
            .toList()
          ..sort((a, b) => b.compareTo(a));

        // Compatibility with older saved data.
        ends = (data['ends'] as List? ?? [])
            .map((v) => dateOnly(DateTime.parse(v.toString())))
            .toList()
          ..sort((a, b) => a.compareTo(b));

        final rawLogs = data['logs'] as Map? ?? {};
        logs = rawLogs.map(
          (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
        );
      } else {
        final p = await SharedPreferences.getInstance();

        starts = (p.getStringList('period_starts_v2') ?? [])
            .map((v) => dateOnly(DateTime.parse(v)))
            .toList()
          ..sort((a, b) => b.compareTo(a));

        ends = [];

        final raw = p.getString('daily_logs_v2');

        if (raw != null) {
          try {
            logs = (jsonDecode(raw) as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, Map<String, dynamic>.from(v)),
            );
          } catch (_) {}
        }

        if (starts.isNotEmpty || logs.isNotEmpty) {
          await persist();
        }

        await p.remove('period_starts_v2');
        await p.remove('daily_logs_v2');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read saved data.'),
          ),
        );
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> persist() async {
    await vault.saveJson({
      'starts': starts.map((d) => d.toIso8601String()).toList(),
      'ends': ends.map((d) => d.toIso8601String()).toList(),
      'logs': logs,
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> markSelectedStart() async {
    final d = dateOnly(selected);

    if (starts.any((x) => key(x) == key(d))) {
      showMessage(t('alreadyStart'));
      return;
    }

    starts.add(d);
    starts.sort((a, b) => b.compareTo(a));

    await persist();

    if (mounted) {
      setState(() {});
      showMessage(t('startSaved'));
    }
  }

  Future<void> markSelectedEnd() async {
    final d = dateOnly(selected);

    final previousStarts = starts
        .where((s) => !dateOnly(s).isAfter(d))
        .map(dateOnly)
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (previousStarts.isEmpty) {
      showMessage(t('noOpenPeriod'));
      return;
    }

    final matchingStart = previousStarts.first;

    if (d.isBefore(matchingStart)) {
      showMessage(t('endBeforeStart'));
      return;
    }

    if (ends.any((x) => key(x) == key(d))) {
      showMessage(t('alreadyEnd'));
      return;
    }

    final laterStarts = starts
        .map(dateOnly)
        .where((s) => s.isAfter(matchingStart))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    if (laterStarts.isNotEmpty &&
        !d.isBefore(laterStarts.first)) {
      showMessage(t('endBeforeStart'));
      return;
    }

    final oldEnd = periodEndFor(matchingStart);

    if (oldEnd != null) {
      ends.removeWhere((x) => key(x) == key(oldEnd));
    }

    ends.add(d);
    ends.sort((a, b) => a.compareTo(b));

    await persist();

    if (mounted) {
      setState(() {});
      showMessage(t('endSaved'));
    }
  }

  DateTime? periodEndFor(DateTime start) {
    final s = dateOnly(start);

    final laterStarts = starts
        .map(dateOnly)
        .where((x) => x.isAfter(s))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    final nextStart =
        laterStarts.isEmpty ? null : laterStarts.first;

    final matchingEnds = ends
        .map(dateOnly)
        .where((e) =>
            !e.isBefore(s) &&
            (nextStart == null || e.isBefore(nextStart)))
        .toList()
      ..sort((a, b) => a.compareTo(b));

    return matchingEnds.isEmpty ? null : matchingEnds.first;
  }

  Future<void> askForReminder() async {
    final allowed = await reminders.requestPermission();

    if (!allowed) {
      showMessage('Notification permission was not granted.');
      return;
    }

    final estimate = next;

    if (estimate == null) {
      showMessage('Record at least one period start first.');
      return;
    }

    final when = DateTime(
      estimate.year,
      estimate.month,
      estimate.day,
      9,
    );

    if (when.isBefore(DateTime.now())) return;

    await reminders.scheduleReminder(
      id: 1,
      localDateTime: when,
      title: 'LunaCare',
      body: 'Your cycle estimate is approaching.',
    );

    showMessage('Reminder scheduled on this device.');
  }

  Future<void> unlockWithBiometrics() async {
    final available = await biometric.isAvailable();
    final ok = available && await biometric.authenticate();

    if (mounted) {
      showMessage(
        ok
            ? 'Authentication successful.'
            : 'Biometric authentication is unavailable or was not completed.',
      );
    }
  }

  Future<void> exportPdf() async {
    await pdfReports.previewReport(
      periodStarts: starts,
      dailyLogs: logs,
      language: lang,
    );
  }

  int get avg {
    if (starts.length < 2) return 28;

    final a = starts.reversed.toList();
    final gaps = <int>[];

    for (int i = 1; i < a.length; i++) {
      final n =
          dateOnly(a[i]).difference(dateOnly(a[i - 1])).inDays;

      if (n >= 15 && n <= 60) gaps.add(n);
    }

    return gaps.isEmpty
        ? 28
        : (gaps.reduce((x, y) => x + y) / gaps.length).round();
  }

  DateTime? get next {
    if (starts.isEmpty) return null;

    final today = dateOnly(DateTime.now());

    var estimate = dateOnly(starts.first).add(Duration(days: avg));

    while (estimate.isBefore(today)) {
      estimate = estimate.add(Duration(days: avg));
    }

    return estimate;
  }

  int? get daysUntilNext {
    final estimate = next;
    if (estimate == null) return null;

    return dateOnly(estimate)
        .difference(dateOnly(DateTime.now()))
        .inDays;
  }

  // Homepage button: unchanged behavior.
  Future<void> addPeriod() async {
    final now = DateTime.now();

    final d = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 4),
      lastDate: DateTime(now.year + 1),
    );

    if (d == null) return;

    final v = dateOnly(d);

    if (starts.any((x) => key(x) == key(v))) {
      showMessage(t('alreadyStart'));
      return;
    }

    starts.add(v);
    starts.sort((a, b) => b.compareTo(a));

    await persist();

    if (mounted) setState(() {});
  }

  bool isPeriod(DateTime d) {
    final day = dateOnly(d);

    for (final start in starts) {
      final s = dateOnly(start);
      final end = periodEndFor(s);

      if (end != null) {
        if (!day.isBefore(s) && !day.isAfter(end)) {
          return true;
        }
      } else {
        // Keep the original five-day estimate if no end was recorded.
        if (!day.isBefore(s) &&
            day.isBefore(s.add(const Duration(days: 5)))) {
          return true;
        }
      }
    }

    return false;
  }

  bool isPredicted(DateTime d) {
    final estimate = next;
    if (estimate == null) return false;

    final day = dateOnly(d);
    final start = dateOnly(estimate);

    return !day.isBefore(start) &&
        day.isBefore(start.add(const Duration(days: 5)));
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: lang == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text('LunaCare'),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: tab,
          children: [
            dashboard(),
            calendarPage(),
            symptomsPage(),
            settingsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (index) {
            setState(() => tab = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: t('home'),
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: t('calendar'),
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: t('symptoms'),
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: t('settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboard() {
    final latestStart = starts.isEmpty ? null : starts.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('welcome'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.favorite, size: 38, color: Colors.pink),
                const SizedBox(height: 12),
                Text(
                  latestStart == null
                      ? t('noPeriod')
                      : '${t('lastPeriod')}: ${DateFormat.yMd(lang).format(latestStart)}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: addPeriod,
                    icon: const Icon(Icons.add),
                    label: Text(t('logPeriod')),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.pink),
            title: Text(t('calendar')),
            subtitle: Text(t('calendarDescription')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => tab = 1),
          ),
        ),

        Card(
          child: ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.pink),
            title: Text(t('symptoms')),
            subtitle: Text(t('symptomsDescription')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => tab = 2),
          ),
        ),

        const SizedBox(height: 16),
        Text(
          t('history'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),

        if (starts.isEmpty)
          Text(t('noHistory'))
        else
          ...starts.map(
            (date) => Card(
              child: ListTile(
                leading: const Icon(Icons.water_drop, color: Colors.pink),
                title: Text(DateFormat.yMMMMd(lang).format(date)),
                subtitle: Text(
                  periodEndFor(date) == null
                      ? t('endNotRecorded')
                      : '${t('periodEnd')}: ${DateFormat.yMd(lang).format(periodEndFor(date)!)}',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget calendarPage() {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final offset = firstDay.weekday % 7;

    final weekdays = lang == 'ar'
        ? ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س']
        : lang == 'fr'
            ? ['L', 'M', 'M', 'J', 'V', 'S', 'D']
            : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  month = DateTime(month.year, month.month - 1);
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat.yMMMM(lang).format(month),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  month = DateTime(month.year, month.month + 1);
                });
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),

        const SizedBox(height: 12),

        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: weekdays
              .map(
                (day) => Center(
                  child: Text(
                    day,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
              .toList(),
        ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: offset + daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox();

            final day = index - offset + 1;
            final date = DateTime(month.year, month.month, day);
            final selected = DateUtils.isSameDay(date, selectedDate);
            final period = isPeriod(date);
            final predicted = isPredicted(date);

            return GestureDetector(
              onTap: () => setState(() => selectedDate = date),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.pink
                      : period
                          ? Colors.pink.shade100
                          : predicted
                              ? Colors.purple.shade100
                              : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: selected
                      ? Border.all(color: Colors.pink.shade900, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight:
                          selected || period ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        legend(),

        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DateFormat.yMMMMd(lang).format(selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: markSelectedStart,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(t('markStart')),
                ),

                const SizedBox(height: 8),

                OutlinedButton.icon(
                  onPressed: markSelectedEnd,
                  icon: const Icon(Icons.stop),
                  label: Text(t('markEnd')),
                ),

                const SizedBox(height: 8),

                FilledButton.icon(
                  onPressed: () => setState(() => tab = 2),
                  icon: const Icon(Icons.edit_note),
                  label: Text(t('logSymptoms')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget legend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _legendItem(Colors.pink.shade100, t('periodDays')),
        _legendItem(Colors.purple.shade100, t('predictedDays')),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget symptomsPage() {
    final dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('symptoms'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(DateFormat.yMMMMd(lang).format(selectedDate)),
        const SizedBox(height: 16),
        SymptomEditor(
          initialData: logs[dateKey] ?? {},
          onChanged: (data) {
            logs[dateKey] = data;
            persist();
          },
          lang: lang,
        ),
      ],
    );
  }

  Widget settingsPage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          t('settings'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),

        SwitchListTile(
          title: Text(t('reminders')),
          value: remindersEnabled,
          onChanged: (value) async {
            setState(() => remindersEnabled = value);
            await saveReminderSettings();
          },
        ),

        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(t('exportPdf')),
          onTap: exportPdf,
        ),

        ListTile(
          leading: const Icon(Icons.fingerprint),
          title: Text(t('biometricLock')),
          subtitle: Text(t('biometricDescription')),
          onTap: checkBiometrics,
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: Text(t('privacy')),
          subtitle: Text(t('localDataPrivacy')),
        ),

        ListTile(
          leading: const Icon(Icons.language),
          title: Text(t('language')),
          subtitle: Text(lang.toUpperCase()),
          onTap: changeLanguage,
        ),
      ],
    );
  }
}

class SymptomEditor extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String lang;

  const SymptomEditor({
    super.key,
    required this.initialData,
    required this.onChanged,
    required this.lang,
  });

  @override
  State<SymptomEditor> createState() => _SymptomEditorState();
}

class _SymptomEditorState extends State<SymptomEditor> {
  late Map<String, dynamic> data;

  @override
  void initState() {
    super.initState();
    data = Map<String, dynamic>.from(widget.initialData);
  }

  String tr(String key) {
    const translations = {
      'ar': {
        'mood': 'المزاج',
        'pain': 'الألم',
        'energy': 'الطاقة',
        'notes': 'ملاحظات',
        'save': 'حفظ',
      },
      'fr': {
        'mood': 'Humeur',
        'pain': 'Douleur',
        'energy': 'Énergie',
        'notes': 'Notes',
        'save': 'Enregistrer',
      },
      'en': {
        'mood': 'Mood',
        'pain': 'Pain',
        'energy': 'Energy',
        'notes': 'Notes',
        'save': 'Save',
      },
    };

    return translations[widget.lang]?[key] ??
        translations['en']![key]!;
  }

  void update(String key, dynamic value) {
    setState(() => data[key] = value);
    widget.onChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(tr('mood')),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: data['mood'] as String?,
          items: ['Good', 'Normal', 'Low']
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ),
              )
              .toList(),
          onChanged: (value) => update('mood', value),
        ),

        const SizedBox(height: 16),
        Text(tr('pain')),
        Slider(
          value: (data['pain'] as num?)?.toDouble() ?? 0,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${data['pain'] ?? 0}',
          onChanged: (value) => update('pain', value.round()),
        ),

        const SizedBox(height: 16),
        Text(tr('energy')),
        Slider(
          value: (data['energy'] as num?)?.toDouble() ?? 5,
          min: 0,
          max: 10,
          divisions: 10,
          label: '${data['energy'] ?? 5}',
          onChanged: (value) => update('energy', value.round()),
        ),

        const SizedBox(height: 16),
        Text(tr('notes')),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: data['notes'] as String? ?? '',
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => update('notes', value),
        ),

        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => widget.onChanged(data),
          child: Text(tr('save')),
        ),
      ],
    );
  }
}