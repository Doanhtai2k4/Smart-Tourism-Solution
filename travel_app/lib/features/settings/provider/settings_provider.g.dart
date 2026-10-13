// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, ThemeMode> {
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'46b619416717b93c86dd6547aa81bd4b276cdb56';

abstract class _$ThemeModeNotifier extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(LanguageNotifier)
final languageProvider = LanguageNotifierProvider._();

final class LanguageNotifierProvider
    extends $AsyncNotifierProvider<LanguageNotifier, Locale> {
  LanguageNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageNotifierHash();

  @$internal
  @override
  LanguageNotifier create() => LanguageNotifier();
}

String _$languageNotifierHash() => r'6b0755f6ada517d1200f83b45a9ac1cb7901e7cd';

abstract class _$LanguageNotifier extends $AsyncNotifier<Locale> {
  FutureOr<Locale> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale>, Locale>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale>, Locale>,
              AsyncValue<Locale>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PreferenceNotifier)
final preferenceProvider = PreferenceNotifierProvider._();

final class PreferenceNotifierProvider
    extends $AsyncNotifierProvider<PreferenceNotifier, Map<String, bool>> {
  PreferenceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferenceNotifierHash();

  @$internal
  @override
  PreferenceNotifier create() => PreferenceNotifier();
}

String _$preferenceNotifierHash() =>
    r'd72fb1e269746fa7cebba514aa3f791cd0207c8b';

abstract class _$PreferenceNotifier extends $AsyncNotifier<Map<String, bool>> {
  FutureOr<Map<String, bool>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, bool>>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, bool>>, Map<String, bool>>,
              AsyncValue<Map<String, bool>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
