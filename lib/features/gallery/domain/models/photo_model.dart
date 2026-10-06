import 'package:equatable/equatable.dart';

class PhotoModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  /// For local photos this is the file path; for server photos this is the URL.
  final String imagePath;
  final String caption;
  final String dayLabel;
  final DateTime uploadedAt;
  final int likeCount;
  final bool likedByCurrentUser;

  const PhotoModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.imagePath,
    required this.caption,
    required this.dayLabel,
    required this.uploadedAt,
    this.likeCount = 0,
    this.likedByCurrentUser = false,
  });

  /// Construct from MongoDB API response JSON.
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      // Priority: imageUrl → url → imagePath (handles all API shape variants)
      imagePath: json['imageUrl'] as String? ??
          json['url'] as String? ??
          json['imagePath'] as String? ??
          '',
      // Server stores caption under 'title'; 'caption' kept as fallback.
      caption: json['title'] as String? ??
               json['caption'] as String? ?? '',
      dayLabel: json['dayLabel'] as String? ?? '',
      uploadedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      likeCount: json['likeCount'] as int? ?? 0,
      likedByCurrentUser: json['likedByCurrentUser'] as bool? ?? false,
    );
  }

  /// Returns a copy with updated fields (used for optimistic like updates).
  PhotoModel copyWith({
    int? likeCount,
    bool? likedByCurrentUser,
  }) {
    return PhotoModel(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      imagePath: imagePath,
      caption: caption,
      dayLabel: dayLabel,
      uploadedAt: uploadedAt,
      likeCount: likeCount ?? this.likeCount,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
    );
  }

  @override
  List<Object?> get props =>
      [id, employeeId, imagePath, caption, dayLabel, uploadedAt,
       likeCount, likedByCurrentUser];
}