// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      portfolioImages: (json['portfolioImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      remarkName: json['remarkName'] as String?,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isFollowing: json['isFollowing'] as bool? ?? false,
      gender: json['gender'] as String? ?? 'male',
      birthday: json['birthday'] as String?,
      isProfileCompleted: json['isProfileCompleted'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'bio': instance.bio,
      'portfolioImages': instance.portfolioImages,
      'remarkName': instance.remarkName,
      'followersCount': instance.followersCount,
      'followingCount': instance.followingCount,
      'isFollowing': instance.isFollowing,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'isProfileCompleted': instance.isProfileCompleted,
    };
