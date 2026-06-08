// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeFeedHash() => r'300055b04c85345d9d1189b700a918a08bc0eaeb';

/// See also [HomeFeed].
@ProviderFor(HomeFeed)
final homeFeedProvider =
    AutoDisposeNotifierProvider<HomeFeed, List<Post>>.internal(
  HomeFeed.new,
  name: r'homeFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$homeFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeFeed = AutoDisposeNotifier<List<Post>>;
String _$momentsFeedHash() => r'36010dc7f0f61dbd448b473dc37809e43ab241b0';

/// See also [MomentsFeed].
@ProviderFor(MomentsFeed)
final momentsFeedProvider =
    AutoDisposeNotifierProvider<MomentsFeed, List<Post>>.internal(
  MomentsFeed.new,
  name: r'momentsFeedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$momentsFeedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MomentsFeed = AutoDisposeNotifier<List<Post>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
