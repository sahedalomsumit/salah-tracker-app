// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Stats)
final statsProvider = StatsProvider._();

final class StatsProvider extends $AsyncNotifierProvider<Stats, StatsState> {
  StatsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'statsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$statsHash();

  @$internal
  @override
  Stats create() => Stats();
}

String _$statsHash() => r'cc2eb7085b7635cce5b64f169393655b282f4ebd';

abstract class _$Stats extends $AsyncNotifier<StatsState> {
  FutureOr<StatsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<StatsState>, StatsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<StatsState>, StatsState>,
        AsyncValue<StatsState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
