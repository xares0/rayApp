import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/post.dart';
import '../repositories/app_repository.dart';
import 'blocked_users_provider.dart';

part 'feed_provider.g.dart';

@riverpod
class HomeFeed extends _$HomeFeed {
  static const int _pageSize = 6;
  List<Post> _allPosts = <Post>[];
  int _loadedCount = 0;

  @override
  List<Post> build() {
    final blockedUsers = ref.watch(blockedUsersProvider);
    _allPosts = _loadPosts(blockedUsers);
    _loadedCount = _initialLoadCount();
    return _visiblePosts();
  }

  bool get hasMore => _loadedCount < _allPosts.length;

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _allPosts = _loadPosts(ref.read(blockedUsersProvider));
    _loadedCount = _initialLoadCount();
    state = _visiblePosts();
  }

  Future<bool> loadMore() async {
    if (!hasMore) return false;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _loadedCount = (_loadedCount + _pageSize).clamp(0, _allPosts.length);
    state = _visiblePosts();
    return true;
  }

  void toggleLike(String postId) {
    final repoPosts = AppRepository.instance.posts;
    final index = repoPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = repoPosts[index];
    final isLiked = post.isLiked;
    repoPosts[index] = post.copyWith(
      isLiked: !isLiked,
      likesCount: post.likesCount + (isLiked ? -1 : 1),
    );

    _allPosts = _loadPosts(ref.read(blockedUsersProvider));
    _loadedCount = _loadedCount.clamp(0, _allPosts.length);
    state = _visiblePosts();
    ref.invalidate(momentsFeedProvider);
  }

  Post createPost({
    required String userId,
    required String content,
    required List<String> images,
    String? videoUrl,
    String? category,
  }) {
    final created = AppRepository.instance.addPost(
      userId: userId,
      content: content,
      images: images,
      videoUrl: videoUrl,
      category: category,
    );
    _allPosts = _loadPosts(ref.read(blockedUsersProvider));
    _loadedCount = (_loadedCount + 1).clamp(1, _allPosts.length);
    if (_loadedCount < _pageSize) {
      _loadedCount = _initialLoadCount();
    }
    state = _visiblePosts();
    return _populateAuthor(created);
  }

  int _initialLoadCount() {
    if (_allPosts.isEmpty) return 0;
    return _allPosts.length < _pageSize ? _allPosts.length : _pageSize;
  }

  List<Post> _visiblePosts() {
    final end = _loadedCount.clamp(0, _allPosts.length);
    return _allPosts.take(end).toList();
  }

  List<Post> _loadPosts(Set<String> blockedUsers) {
    final allPosts = AppRepository.instance.getAllPosts().where((post) {
      return !blockedUsers.contains(post.userId);
    }).toList();
    return _populateAuthors(allPosts);
  }

  Post _populateAuthor(Post post) {
    final author = AppRepository.instance.getUser(post.userId);
    return post.copyWith(author: author);
  }

  List<Post> _populateAuthors(List<Post> posts) {
    return posts.map((p) {
      final author = AppRepository.instance.getUser(p.userId);
      return p.copyWith(author: author);
    }).toList();
  }
}

@riverpod
class MomentsFeed extends _$MomentsFeed {
  @override
  List<Post> build() {
    final blockedUsers = ref.watch(blockedUsersProvider);
    final posts = AppRepository.instance.getAllPosts().where((post) {
      return !blockedUsers.contains(post.userId);
    }).toList();
    return _populateAuthors(posts);
  }

  List<Post> _populateAuthors(List<Post> posts) {
    return posts.map((p) {
      final author = AppRepository.instance.getUser(p.userId);
      return p.copyWith(author: author);
    }).toList();
  }
}
