import 'package:get/get.dart';
import 'package:app_usage/app_usage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MonitoringController extends GetxController {
  // ── Observable state ────────────────────────────────────────
  var selectedFilter   = 'Minggu'.obs;
  var totalScreenTime  = '0j 0m'.obs;
  var todayScreenTime  = '0j 0m'.obs;
  var averageTime      = '0j 0m'.obs;

  var chartData        = <double>[0, 0, 0, 0, 0, 0, 0].obs;
  var chartLabels      = <String>['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].obs;
  var chartTimeLabels  = <String>['0m', '0m', '0m', '0m', '0m', '0m', '0m'].obs;

  var todayIndex       = 6.obs;
  var selectedBarIndex = (-1).obs;
  var isLoading        = false.obs;
  var isLoadingBarApps = false.obs;

  var appUsageData     = <Map<String, dynamic>>[].obs;
  var selectedBarApps  = <Map<String, dynamic>>[].obs;

  // ── Cache ────────────────────────────────────────────────────
  final Map<String, String>                      _appNamesCache  = {};
  final Map<String, List<Map<String, dynamic>>>  _appUsageCache  = {};
  // KEY: "startMs_period.endMs"  (stabil, tidak berubah tiap detik)
  // VALUE: SOT menit aktual sampai min(now, period.end)
  final Map<String, double>                      _sotCache       = {};

  static const _platformMethod = MethodChannel('minddriji/apps');
  static const String baseUrl = 'https://yarn-uncurled-arguable.ngrok-free.dev';

  DateTime? _lastUploadTime;
  final int _uploadCooldownMinutes = 15; // Jeda 15 menit antar upload

  List<_Period> _currentPeriods = [];

  @override
  void onInit() {
    super.onInit();
    fetchRealUsageData();
  }

  // ════════════════════════════════════════════════════════════
  //  PUBLIC API
  // ════════════════════════════════════════════════════════════

  void changeFilter(String newFilter) {
    selectedFilter.value = newFilter;
    selectedBarIndex.value = -1;
    selectedBarApps.clear();
    fetchRealUsageData();
  }

  Future<void> onBarTap(int index) async {
    // Toggle off
    if (selectedBarIndex.value == index) {
      selectedBarIndex.value = -1;
      selectedBarApps.clear();
      return;
    }

    selectedBarIndex.value = index;

    if (index < 0 || index >= _currentPeriods.length) return;

    final period = _currentPeriods[index];
    final now    = DateTime.now();

    if (period.start.isAfter(now)) {
      selectedBarApps.clear();
      return;
    }

    // ── FIX BUG 1: cache key pakai period.end (stabil) ────────
    final String stableKey = _sotKey(period);

    if (_appUsageCache.containsKey(stableKey)) {
      selectedBarApps.value = _appUsageCache[stableKey]!;
      return;
    }

    isLoadingBarApps.value = true;
    try {
      // periodSot pasti ketemu karena key-nya sama dengan saat fetch
      final double periodSot = _sotCache[stableKey] ?? 0.0;
      final DateTime batas   = period.end.isAfter(now) ? now : period.end;

      final apps = await _fetchAppsForPeriod(period.start, batas, periodSot);
      _appUsageCache[stableKey] = apps;
      selectedBarApps.value = apps;
    } catch (e) {
      debugPrint("onBarTap error: $e");
    } finally {
      isLoadingBarApps.value = false;
    }
  }

  // ── Cache key stabil: pakai period.end bukan DateTime.now() ──
  String _sotKey(_Period p) =>
      '${p.start.millisecondsSinceEpoch}_${p.end.millisecondsSinceEpoch}';

  // ════════════════════════════════════════════════════════════
  //  MASTER FETCH
  // ════════════════════════════════════════════════════════════

  Future<void> fetchRealUsageData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final DateTime now    = DateTime.now();
      final String   filter = selectedFilter.value;

      final List<_Period> periods = _buildPeriods(now, filter);
      _currentPeriods = periods;

      List<double> sotPerPeriode = [];

      // ────────────────────────────────────────────────────────
      // FILTER: HARI (Sesi Berdasarkan Jam)
      // ────────────────────────────────────────────────────────
      if (filter == 'Hari') {
        sotPerPeriode = await Future.wait(
          periods.map((p) async {
            if (p.start.isAfter(now)) return 0.0;
            final DateTime batas = p.end.isAfter(now) ? now : p.end;
            return (await _getRealScreenOnTime(p.start, batas)).toDouble();
          }),
        );

        double totalKotor = sotPerPeriode.fold(0.0, (s, v) => s + v);
        final DateTime startOfDay = DateTime(now.year, now.month, now.day);
        final double trueTotalMenit = (await _getRealScreenOnTime(startOfDay, now)).toDouble();

        // Scale internal jam agar pas dengan total hari ini
        if (totalKotor > 0 && trueTotalMenit > 0 && totalKotor != trueTotalMenit) {
          sotPerPeriode = sotPerPeriode.map((m) => (m / totalKotor) * trueTotalMenit).toList();
        }
        
        for (int i = 0; i < periods.length; i++) {
          _sotCache[_sotKey(periods[i])] = sotPerPeriode[i];
        }

        _updateTotalAndAverage(trueTotalMenit, filter, periods.length);
        _buildChart(sotPerPeriode, periods, now, filter);
        await _fetchAndScaleApps(startOfDay, now, trueTotalMenit);

      // ────────────────────────────────────────────────────────
      // FILTER: MINGGU (Pecah Per Hari Mandiri)
      // ────────────────────────────────────────────────────────
      } else if (filter == 'Minggu') {
        // Tiap hari panggil native masing-masing, hari ini otomatis dapat angka riil ter-update
        sotPerPeriode = await Future.wait(
          periods.map((p) async {
            if (p.start.isAfter(now)) return 0.0;
            final DateTime batas = p.end.isAfter(now) ? now : p.end;
            final double daySot = (await _getRealScreenOnTime(p.start, batas)).toDouble();
            
            _sotCache[_sotKey(p)] = daySot; // Cache untuk onBarTap
            return daySot;
          }),
        );

        double totalWeekMenit = sotPerPeriode.fold(0.0, (s, v) => s + v);

        _updateTotalAndAverage(totalWeekMenit, filter, periods.length);
        _buildChart(sotPerPeriode, periods, now, filter);
        await _fetchAndScaleApps(periods.first.start, periods.last.end.isAfter(now) ? now : periods.last.end, totalWeekMenit);

      // ────────────────────────────────────────────────────────
      // FILTER: BULAN (Gabungan Bata Harian)
      // ────────────────────────────────────────────────────────
      } else if (filter == 'Bulan') {
        // Eksekusi query 28 hari (4 minggu x 7 hari) sekaligus secara paralel biar super cepat
        final List<List<DateTime>> weeksDays = periods.map((weekPeriod) {
          return List.generate(7, (i) => weekPeriod.start.add(Duration(days: i)));
        }).toList();

        List<Future<double>> allDayQueries = [];
        for (var week in weeksDays) {
          for (var dayStart in week) {
            if (dayStart.isAfter(now)) {
              allDayQueries.add(Future.value(0.0));
            } else {
              final DateTime dayEnd = DateTime(dayStart.year, dayStart.month, dayStart.day + 1).subtract(const Duration(milliseconds: 1));
              final DateTime batas = dayEnd.isAfter(now) ? now : dayEnd;
              allDayQueries.add(_getRealScreenOnTime(dayStart, batas).then((v) => v.toDouble()));
            }
          }
        }

        final List<double> allDaysSot = await Future.wait(allDayQueries);

        // Satukan kembali per 7 hari menjadi total per minggu
        sotPerPeriode = [];
        for (int w = 0; w < periods.length; w++) {
          double weekTotal = 0.0;
          for (int d = 0; d < 7; d++) {
            weekTotal += allDaysSot[(w * 7) + d];
          }
          _sotCache[_sotKey(periods[w])] = weekTotal;
          sotPerPeriode.add(weekTotal);
        }

        double totalMonthMenit = sotPerPeriode.fold(0.0, (s, v) => s + v);

        _updateTotalAndAverage(totalMonthMenit, filter, periods.length);
        _buildChart(sotPerPeriode, periods, now, filter);
        await _fetchAndScaleApps(periods.first.start, periods.last.end.isAfter(now) ? now : periods.last.end, totalMonthMenit);
      }

      // 💡 FIX: Spasi di nama variabel awalHariIni sudah dibersihkan
      final DateTime skrg = DateTime.now();
      final DateTime awalHariIni = DateTime(skrg.year, skrg.month, skrg.day);
      final int menitHariIni = await _getRealScreenOnTime(awalHariIni, skrg);

      final int j = menitHariIni ~/ 60;
      final int m = menitHariIni % 60;
      todayScreenTime.value = '${j}j ${m}m';

    } catch (e) {
      debugPrint("fetchRealUsageData error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  //  PERIODE BUILDER
  //  FIX BUG 2 di sini: tab Bulan pakai ISO weeks, bukan tgl 1-7
  // ════════════════════════════════════════════════════════════

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day + 1).subtract(const Duration(milliseconds: 1));

  DateTime _endOfHour(DateTime d, int hour) =>
      DateTime(d.year, d.month, d.day, hour + 1).subtract(const Duration(milliseconds: 1));

  /// Kembalikan Senin (00:00:00) dari minggu ISO yang memuat [d].
  DateTime _seninDariHari(DateTime d) =>
      DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

  List<_Period> _buildPeriods(DateTime now, String filter) {
    if (filter == 'Hari') {
      final d = DateTime(now.year, now.month, now.day);
      return [
        _Period('Dini Hari', d,                                    _endOfHour(d, 5)),
        _Period('Pagi',      DateTime(d.year, d.month, d.day,  6), _endOfHour(d, 11)),
        _Period('Siang',     DateTime(d.year, d.month, d.day, 12), _endOfHour(d, 14)),
        _Period('Sore',      DateTime(d.year, d.month, d.day, 15), _endOfHour(d, 17)),
        _Period('Malam',     DateTime(d.year, d.month, d.day, 18), _endOfDay(d)),
      ];
    }

    if (filter == 'Bulan') {
      // ── FIX BUG 2 ──────────────────────────────────────────
      // Cari Senin pertama di/setelah tgl 1 bulan ini.
      // Lalu buat 4 blok 7-hari ISO → identik dengan range tab Minggu.
      final DateTime tgl1      = DateTime(now.year, now.month, 1);
      final DateTime senin1    = _seninDariHari(tgl1);
      // Kalau tgl 1 bukan Senin, senin1 mundur ke minggu sebelumnya.
      // Kita mau minggu PERTAMA yg masih ada hari di bulan ini:
      final DateTime seninAwal = senin1.month < now.month
          ? senin1.add(const Duration(days: 7))
          : senin1;

      return List.generate(4, (i) {
        final DateTime senin = seninAwal.add(Duration(days: 7 * i));
        final DateTime minggu = senin.add(const Duration(days: 6));
        return _Period(
          'Mng ${i + 1}',
          senin,
          _endOfDay(minggu),
        );
      });
    }

    // ── Tab Minggu (tidak berubah) ───────────────────────────
    final DateTime seninMingguIni = _seninDariHari(now);
    const labels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return List.generate(7, (i) {
      final DateTime hari = seninMingguIni.add(Duration(days: i));
      return _Period(
        labels[i],
        DateTime(hari.year, hari.month, hari.day, 0, 0, 0),
        _endOfDay(hari),
      );
    });
  }

  // ════════════════════════════════════════════════════════════
  //  TOTAL & RATA-RATA
  // ════════════════════════════════════════════════════════════

  void _updateTotalAndAverage(double totalMenit, String filter, int jumlahPeriode) {
    final int jam   = totalMenit ~/ 60;
    final int menit = (totalMenit % 60).toInt();
    totalScreenTime.value = '${jam}j ${menit}m';

    if (totalMenit == 0) { averageTime.value = '0m'; return; }

    if (filter == 'Hari') {
      final double rata = totalMenit / jumlahPeriode;
      final int rj = rata ~/ 60, rm = (rata % 60).round();
      averageTime.value = rj > 0 ? '${rj}j ${rm}m/sesi' : '${rm}m/sesi';
    } else if (filter == 'Bulan') {
      averageTime.value =
          '${((totalMenit / 60) / jumlahPeriode).toStringAsFixed(1)}j/minggu';
    } else {
      averageTime.value =
          '${((totalMenit / 60) / 7).toStringAsFixed(1)}j/hari';
    }
  }

  // ════════════════════════════════════════════════════════════
  //  CHART BUILDER
  // ════════════════════════════════════════════════════════════

  void _buildChart(List<double> sotArray, List<_Period> periods, DateTime now, String filter) {
    final double maxMenit =
        sotArray.isEmpty ? 0 : sotArray.reduce((a, b) => a > b ? a : b);

    chartLabels.value = periods.map((p) => p.label).toList();

    chartTimeLabels.value = sotArray.map((mins) {
      if (mins == 0) return '0m';
      final int j = mins ~/ 60, m = (mins % 60).toInt();
      if (j > 0) return m > 0 ? '${j}j ${m}m' : '${j}j';
      return '${m}m';
    }).toList();

    chartData.value = sotArray
        .map((m) => maxMenit > 0 ? (m / maxMenit) * 100 : 0.0)
        .toList();

    todayIndex.value = _activePeriodIndex(periods, now);
  }

  int _activePeriodIndex(List<_Period> periods, DateTime now) {
    for (int i = 0; i < periods.length; i++) {
      if (!now.isBefore(periods[i].start) && !now.isAfter(periods[i].end)) {
        return i;
      }
    }
    return periods.length - 1;
  }

  // ════════════════════════════════════════════════════════════
  //  APP USAGE — KESELURUHAN
  // ════════════════════════════════════════════════════════════

  Future<void> _fetchAndScaleApps(
      DateTime start, DateTime end, double trueSotMenit) async {
    try {
      final apps = await _fetchAppsForPeriod(start, end, trueSotMenit);
      appUsageData.value = apps;

      final payload = apps.map((a) => {
        'package_name'    : a['package'],
        'app_name'        : a['name'],
        'duration_minutes': _parseTimeToMinutes(a['time'] as String),
        'last_time_used'  : DateTime.now().toIso8601String(),
      }).toList();
      await _kirimLogKeBackendDenganPayload(payload);
    } catch (e) {
      debugPrint("_fetchAndScaleApps error: $e");
    }
  }

  // ════════════════════════════════════════════════════════════
  //  APP USAGE — CORE
  // ════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> _fetchAppsForPeriod(
    DateTime start,
    DateTime end,
    double trueSotMenit,
  ) async {
    final rawList = await AppUsage().getAppUsage(start, end);

    final activeApps = rawList
        .where((a) => a.usage.inMinutes > 1 && !_isSystemApp(a.packageName))
        .toList()
      ..sort((a, b) => b.usage.compareTo(a.usage));

    if (activeApps.isEmpty) return [];

    final double totalKotor =
        activeApps.fold(0.0, (s, a) => s + a.usage.inMinutes);

    final double maxScaledMenit = totalKotor > 0
        ? (activeApps.first.usage.inMinutes / totalKotor) * trueSotMenit
        : 0;

    final List<String> resolvedNames = await Future.wait(
      activeApps.map(_resolveAppName),
    );

    const colors = ['purple', 'blue', 'green', 'orange', 'red'];
    final result = <Map<String, dynamic>>[];

    for (int i = 0; i < activeApps.length; i++) {
      final app  = activeApps[i];
      final name = resolvedNames[i];

      double scaledMins = totalKotor > 0
          ? (app.usage.inMinutes / totalKotor) * trueSotMenit
          : 0;

      int appJam   = scaledMins ~/ 60;
      int appMenit = (scaledMins % 60).round();

      if (appJam == 0 && appMenit == 0 && app.usage.inMinutes > 0 && trueSotMenit > 0) {
        appMenit = 1;
      }
      if (appMenit == 60) { appJam++; appMenit = 0; }

      result.add({
        'name'    : name,
        'package' : app.packageName,
        'time'    : appJam > 0 ? '${appJam}j ${appMenit}m' : '${appMenit}m',
        'progress': maxScaledMenit > 0 ? scaledMins / maxScaledMenit : 0.0,
        'color'   : colors[i % colors.length],
      });
    }
    return result;
  }

  // ════════════════════════════════════════════════════════════
  //  BACKEND
  // ════════════════════════════════════════════════════════════

  Future<void> _kirimLogKeBackendDenganPayload(
      List<Map<String, dynamic>> payload) async {
    
    final DateTime now = DateTime.now();

    // 1. Cek apakah masih dalam masa cooldown
    if (_lastUploadTime != null && 
        now.difference(_lastUploadTime!).inMinutes < _uploadCooldownMinutes) {
      debugPrint("Upload ke Flask di-skip: Masih dalam masa cooldown ($_uploadCooldownMinutes menit).");
      return; 
    }

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/monitoring/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'device_id': 'user_hp_capstone_123', 'apps': payload}),
      );
      
      if (res.statusCode == 200) {
        debugPrint('Data monitoring sukses terkirim!');
        // 2. Jika sukses, catat waktu sekarang sebagai jadwal terakhir upload
        _lastUploadTime = now;
      } else {
        debugPrint('Backend error: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint("Gagal sync Flask: $e");
    }
  }

  // ════════════════════════════════════════════════════════════
  //  HELPERS
  // ════════════════════════════════════════════════════════════

  int _parseTimeToMinutes(String t) {
    int total = 0;
    final j = RegExp(r'(\d+)j').firstMatch(t);
    final m = RegExp(r'(\d+)m').firstMatch(t);
    if (j != null) total += int.parse(j.group(1)!) * 60;
    if (m != null) total += int.parse(m.group(1)!);
    return total;
  }

  Future<String> _resolveAppName(AppUsageInfo app) async {
    const overrides = {'com.ss.android.ugc.trill': 'TikTok'};
    if (overrides.containsKey(app.packageName)) return overrides[app.packageName]!;

    final fromNative = await getRealAppName(app.packageName);
    if (fromNative != app.packageName) return fromNative;

    final parts = app.packageName.split('.');
    String last = parts.last;
    if ((last == 'android' || last == 'urpblank') && parts.length > 1) {
      last = parts[parts.length - 2];
    }
    return last.isEmpty ? 'Aplikasi' : last[0].toUpperCase() + last.substring(1);
  }

  Future<String> getRealAppName(String packageName) async {
    if (_appNamesCache.containsKey(packageName)) return _appNamesCache[packageName]!;
    try {
      final name = await _platformMethod.invokeMethod<String>(
          'getAppName', {'packageName': packageName});
      if (name != null && name.isNotEmpty) {
        return _appNamesCache[packageName] = name;
      }
    } catch (e) {
      debugPrint("getAppName error $packageName: $e");
    }
    final fb = packageName.split('.').last;
    return _appNamesCache[packageName] =
        fb.length > 1 ? fb[0].toUpperCase() + fb.substring(1) : fb;
  }

  Future<int> _getRealScreenOnTime(DateTime start, DateTime end) async {
    try {
      return await _platformMethod.invokeMethod<int>('getScreenOnTime', {
            'startTime': start.millisecondsSinceEpoch,
            'endTime'  : end.millisecondsSinceEpoch,
          }) ??
          0;
    } catch (e) {
      debugPrint("getScreenOnTime error: $e");
      return 0;
    }
  }

  bool _isSystemApp(String pkg) {
    const kw = [
      'launcher','systemui','settings','provider','inputmethod',
      'overlay','keyguard','ims','service','wallpaper','hardware',
      'security','biometrics','camera360','bloatware','setupwizard',
    ];
    const bl = {
      'android','com.android.documentsui','com.google.android.packageinstaller',
      'com.google.android.gms','com.google.android.gsf',
      'com.google.android.tts','com.google.android.contacts',
    };
    if (bl.contains(pkg)) return true;
    final lower = pkg.toLowerCase();
    return kw.any((k) => lower.contains(k));
  }
}

class _Period {
  final String   label;
  final DateTime start;
  final DateTime end;
  const _Period(this.label, this.start, this.end);
}