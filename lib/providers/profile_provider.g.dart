// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileUserHash() => r'1eed173f8de594bdd0cb8575001184096973e214';

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

abstract class _$ProfileUser extends BuildlessAutoDisposeNotifier<User> {
  late final String userId;

  User build(
    String userId,
  );
}

/// See also [ProfileUser].
@ProviderFor(ProfileUser)
const profileUserProvider = ProfileUserFamily();

/// See also [ProfileUser].
class ProfileUserFamily extends Family<User> {
  /// See also [ProfileUser].
  const ProfileUserFamily();

  /// See also [ProfileUser].
  ProfileUserProvider call(
    String userId,
  ) {
    return ProfileUserProvider(
      userId,
    );
  }

  @override
  ProfileUserProvider getProviderOverride(
    covariant ProfileUserProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'profileUserProvider';
}

/// See also [ProfileUser].
class ProfileUserProvider
    extends AutoDisposeNotifierProviderImpl<ProfileUser, User> {
  /// See also [ProfileUser].
  ProfileUserProvider(
    String userId,
  ) : this._internal(
          () => ProfileUser()..userId = userId,
          from: profileUserProvider,
          name: r'profileUserProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileUserHash,
          dependencies: ProfileUserFamily._dependencies,
          allTransitiveDependencies:
              ProfileUserFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfileUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  User runNotifierBuild(
    covariant ProfileUser notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(ProfileUser Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfileUserProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProfileUser, User> createElement() {
    return _ProfileUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileUserProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileUserRef on AutoDisposeNotifierProviderRef<User> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileUserProviderElement
    extends AutoDisposeNotifierProviderElement<ProfileUser, User>
    with ProfileUserRef {
  _ProfileUserProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileUserProvider).userId;
}

String _$profilePostsHash() => r'd89265bf5fd34d1d7c81b1913ef809903e816089';

abstract class _$ProfilePosts extends BuildlessAutoDisposeNotifier<List<Post>> {
  late final String userId;

  List<Post> build(
    String userId,
  );
}

/// See also [ProfilePosts].
@ProviderFor(ProfilePosts)
const profilePostsProvider = ProfilePostsFamily();

/// See also [ProfilePosts].
class ProfilePostsFamily extends Family<List<Post>> {
  /// See also [ProfilePosts].
  const ProfilePostsFamily();

  /// See also [ProfilePosts].
  ProfilePostsProvider call(
    String userId,
  ) {
    return ProfilePostsProvider(
      userId,
    );
  }

  @override
  ProfilePostsProvider getProviderOverride(
    covariant ProfilePostsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'profilePostsProvider';
}

/// See also [ProfilePosts].
class ProfilePostsProvider
    extends AutoDisposeNotifierProviderImpl<ProfilePosts, List<Post>> {
  /// See also [ProfilePosts].
  ProfilePostsProvider(
    String userId,
  ) : this._internal(
          () => ProfilePosts()..userId = userId,
          from: profilePostsProvider,
          name: r'profilePostsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profilePostsHash,
          dependencies: ProfilePostsFamily._dependencies,
          allTransitiveDependencies:
              ProfilePostsFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfilePostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  List<Post> runNotifierBuild(
    covariant ProfilePosts notifier,
  ) {
    return notifier.build(
      userId,
    );
  }

  @override
  Override overrideWith(ProfilePosts Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProfilePostsProvider._internal(
        () => create()..userId = userId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ProfilePosts, List<Post>> createElement() {
    return _ProfilePostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfilePostsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfilePostsRef on AutoDisposeNotifierProviderRef<List<Post>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfilePostsProviderElement
    extends AutoDisposeNotifierProviderElement<ProfilePosts, List<Post>>
    with ProfilePostsRef {
  _ProfilePostsProviderElement(super.provider);

  @override
  String get userId => (origin as ProfilePostsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
