import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/prayer_record.dart';
import '../data/repositories/prayer_repository.dart';
import '../core/utils/date_utils.dart';
import '../core/constants/app_constants.dart';
import 'auth_provider.dart';

part 'prayer_provider.g.dart';

@riverpod
PrayerRepository prayerRepository(Ref ref) {
  final user = ref.watch(sessionUserProvider);
  // Default to a guest ID if not logged in, but repository normally needs a real ID
  return PrayerRepository(user?.id ?? 'guest_user');
}

@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  void goToToday() {
    state = DateTime.now();
  }
}

@riverpod
class DayPrayers extends _$DayPrayers {
  @override
  FutureOr<List<PrayerRecord>> build() async {
    final date = ref.watch(selectedDateProvider);
    final repository = ref.watch(prayerRepositoryProvider);
    return repository.getDayRecords(SalahDateUtils.toKey(date));
  }

  Future<void> updateStatus(String prayerName, PrayerStatus status) async {
    final date = ref.read(selectedDateProvider);
    final repository = ref.read(prayerRepositoryProvider);
    
    await repository.updateStatus(
      date: SalahDateUtils.toKey(date),
      prayerName: prayerName,
      status: status,
    );
    
    // Refresh the data
    ref.invalidateSelf();
  }

  void nextDay() => ref.read(selectedDateProvider.notifier).nextDay();
  void previousDay() => ref.read(selectedDateProvider.notifier).previousDay();
  void goToToday() => ref.read(selectedDateProvider.notifier).goToToday();
}
