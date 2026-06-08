// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatListHash() => r'b6dbd1eeccdef524b0d21088e655deec30e751d5';

/// See also [ChatList].
@ProviderFor(ChatList)
final chatListProvider =
    AutoDisposeNotifierProvider<ChatList, List<ChatConversation>>.internal(
  ChatList.new,
  name: r'chatListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ChatList = AutoDisposeNotifier<List<ChatConversation>>;
String _$chatMessagesHash() => r'c0338df4e7485c5eb87436fd52f1e5b38acce534';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$ChatMessages
    extends BuildlessAutoDisposeNotifier<List<Message>> {
  late final String otherUserId;

  List<Message> build(
    String otherUserId,
  );
}

/// See also [ChatMessages].
@ProviderFor(ChatMessages)
const chatMessagesProvider = ChatMessagesFamily();

/// See also [ChatMessages].
class ChatMessagesFamily extends Family<List<Message>> {
  /// See also [ChatMessages].
  const ChatMessagesFamily();

  /// See also [ChatMessages].
  ChatMessagesProvider call(
    String otherUserId,
  ) {
    return ChatMessagesProvider(
      otherUserId,
    );
  }

  @override
  ChatMessagesProvider getProviderOverride(
    covariant ChatMessagesProvider provider,
  ) {
    return call(
      provider.otherUserId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessagesProvider';
}

/// See also [ChatMessages].
class ChatMessagesProvider
    extends AutoDisposeNotifierProviderImpl<ChatMessages, List<Message>> {
  /// See also [ChatMessages].
  ChatMessagesProvider(
    String otherUserId,
  ) : this._internal(
          () => ChatMessages()..otherUserId = otherUserId,
          from: chatMessagesProvider,
          name: r'chatMessagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMessagesHash,
          dependencies: ChatMessagesFamily._dependencies,
          allTransitiveDependencies:
              ChatMessagesFamily._allTransitiveDependencies,
          otherUserId: otherUserId,
        );

  ChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.otherUserId,
  }) : super.internal();

  final String otherUserId;

  @override
  List<Message> runNotifierBuild(
    covariant ChatMessages notifier,
  ) {
    return notifier.build(
      otherUserId,
    );
  }

  @override
  Override overrideWith(ChatMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessagesProvider._internal(
        () => create()..otherUserId = otherUserId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        otherUserId: otherUserId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ChatMessages, List<Message>>
      createElement() {
    return _ChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessagesProvider && other.otherUserId == otherUserId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, otherUserId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessagesRef on AutoDisposeNotifierProviderRef<List<Message>> {
  /// The parameter `otherUserId` of this provider.
  String get otherUserId;
}

class _ChatMessagesProviderElement
    extends AutoDisposeNotifierProviderElement<ChatMessages, List<Message>>
    with ChatMessagesRef {
  _ChatMessagesProviderElement(super.provider);

  @override
  String get otherUserId => (origin as ChatMessagesProvider).otherUserId;
}

String _$systemNotificationsHash() =>
    r'5b77cd3ff9c0c061774947e42a9bf446e3bbaae5';

/// See also [SystemNotifications].
@ProviderFor(SystemNotifications)
final systemNotificationsProvider = AutoDisposeNotifierProvider<
    SystemNotifications, List<SystemNotificationItem>>.internal(
  SystemNotifications.new,
  name: r'systemNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$systemNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SystemNotifications
    = AutoDisposeNotifier<List<SystemNotificationItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
