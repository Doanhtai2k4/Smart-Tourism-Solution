// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupChatRepository)
final groupChatRepositoryProvider = GroupChatRepositoryProvider._();

final class GroupChatRepositoryProvider
    extends
        $FunctionalProvider<
          GroupChatRepository,
          GroupChatRepository,
          GroupChatRepository
        >
    with $Provider<GroupChatRepository> {
  GroupChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupChatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupChatRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupChatRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GroupChatRepository create(Ref ref) {
    return groupChatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupChatRepository>(value),
    );
  }
}

String _$groupChatRepositoryHash() =>
    r'1f7d66282a389b6bf0d7091509d421bf571a7177';

@ProviderFor(groupMessages)
final groupMessagesProvider = GroupMessagesFamily._();

final class GroupMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MessageModel>>,
          List<MessageModel>,
          Stream<List<MessageModel>>
        >
    with
        $FutureModifier<List<MessageModel>>,
        $StreamProvider<List<MessageModel>> {
  GroupMessagesProvider._({
    required GroupMessagesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupMessagesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupMessagesHash();

  @override
  String toString() {
    return r'groupMessagesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MessageModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<MessageModel>> create(Ref ref) {
    final argument = this.argument as String;
    return groupMessages(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMessagesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupMessagesHash() => r'd9c5c412b3a3de84d37181bfe3da365f5a28cf62';

final class GroupMessagesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MessageModel>>, String> {
  GroupMessagesFamily._()
    : super(
        retry: null,
        name: r'groupMessagesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GroupMessagesProvider call(String tripId) =>
      GroupMessagesProvider._(argument: tripId, from: this);

  @override
  String toString() => r'groupMessagesProvider';
}
