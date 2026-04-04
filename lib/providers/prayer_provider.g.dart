// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(prayerRepository)
final prayerRepositoryProvider = PrayerRepositoryProvider._();

final class PrayerRepositoryProvider extends $FunctionalProvider<
    PrayerRepository,
    PrayerRepository,
    PrayerRepository> with $Provider<PrayerRepository> {
  PrayerRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'prayerRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$prayerRepositoryHash();

  @$internal
  @override
  $ProviderElement<PrayerRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PrayerRepository create(Ref ref) {
    return prayerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrayerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrayerRepository>(value),
    );
  }
}

String _$prayerRepositoryHash() => r'b8c1c23da6ec0f02fc0311572c57c4e0f02609cb';

@ProviderFor(SelectedDate)
final selectedDateProvider = SelectedDateProvider._();

final class SelectedDateProvider
    extends $NotifierProvider<SelectedDate, DateTime> {
  SelectedDateProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedDateProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedDateHash();

  @$internal
  @override
  SelectedDate create() => SelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$selectedDateHash() => r'9342061434d0e7b232e031cc2df7d543941538c3';

abstract class _$SelectedDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<DateTime, DateTime>, DateTime, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DayPrayers)
final dayPrayersProvider = DayPrayersProvider._();

final class DayPrayersProvider
    extends $AsyncNotifierProvider<DayPrayers, List<PrayerRecord>> {
  DayPrayersProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dayPrayersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dayPrayersHash();

  @$internal
  @override
  DayPrayers create() => DayPrayers();
}

String _$dayPrayersHash() => r'3b6550597a96c752d2c2ec4d6f4cfd0c50c6f03f';

abstract class _$DayPrayers extends $AsyncNotifier<List<PrayerRecord>> {
  FutureOr<List<PrayerRecord>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<PrayerRecord>>, List<PrayerRecord>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<PrayerRecord>>, List<PrayerRecord>>,
        AsyncValue<List<PrayerRecord>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
