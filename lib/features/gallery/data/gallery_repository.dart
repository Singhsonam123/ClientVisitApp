import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/models/photo_model.dart';

/// Repository for the photo gallery using project feed endpoints.
///
/// ## API contract used
/// | Method | Path                                    | Auth   | Description               |
/// |--------|----------------------------------------|--------|---------------------------|
/// | POST   | /api/projects/{id}/feed/                | Bearer | Create post (upload photo)|
/// | GET    | /api/projects/{id}/feed/                | Bearer | List APPROVED posts       |
/// | PATCH  | /api/projects/{id}/feed/{post_id}/moderate/ | Bearer | Moderate post (Admin)  |
///
/// Posts are created with PENDING status and must be approved by admin.
/// Request format: { "image_url": "url", "caption": "text" }
class GalleryRepository {
  final Dio _dio = ApiClient.instance;
  final SharedPreferences _prefs;
  final String projectId;

  GalleryRepository(this._prefs, {required this.projectId});

  // ── Fetch photos ──────────────────────────────────────────────────────────

  /// Returns photos/posts from the project feed.
  /// Includes both APPROVED and PENDING posts (for users to see their own pending uploads).
  Future<List<PhotoModel>> fetchPhotos() async {
    try {
      final resp = await _dio.get('/projects/$projectId/feed/');
      final posts = _parseList(resp.data, 'results');
      
      final allPhotos = <PhotoModel>[];
      for (final post in posts) {
        final postMap = post as Map<String, dynamic>;
        
        // Extract uploader details from nested uploader_detail object
        final uploaderDetail = postMap['uploader_detail'] as Map<String, dynamic>? ?? {};
        final userId = uploaderDetail['user_id']?.toString() ?? postMap['uploader']?.toString() ?? '';
        final fullName = uploaderDetail['full_name'] as String? ?? 'Unknown';
        
        // Extract image URL from post (check both image_url and image fields)
        // Allow null/empty image URLs for pending posts
        final imageUrl = postMap['image_url'] as String? ??
                        postMap['image'] as String? ?? '';
        
        // Parse uploadedAt timestamp
        DateTime uploadedAt = DateTime.now();
        final createdAtStr = postMap['created_at'] as String?;
        if (createdAtStr != null) {
          try {
            uploadedAt = DateTime.parse(createdAtStr);
          } catch (_) {
            uploadedAt = DateTime.now();
          }
        }
        
        // Extract moderation status
        final moderationStatus = postMap['moderation_status'] as String? ?? 'APPROVED';
        
        // Extract project ID from response
        final photoProjectId = postMap['project']?.toString() ?? projectId;
        
        // Convert post to PhotoModel
        final photo = PhotoModel(
          id: postMap['post_id']?.toString() ?? '',
          projectId: photoProjectId,
          imagePath: imageUrl,
          caption: postMap['caption'] as String? ?? '',
          employeeId: userId,
          employeeName: fullName,
          dayLabel: 'General',
          uploadedAt: uploadedAt,
          likeCount: postMap['like_count'] as int? ?? 0,
          likedByCurrentUser: postMap['liked_by_current_user'] as bool? ?? false,
          moderationStatus: moderationStatus,
        );
        allPhotos.add(photo);
      }
      return allPhotos;
    } catch (e) {
      print('[GalleryRepository] Error fetching photos: $e');
      rethrow;
    }
  }

  // ── Upload photo ──────────────────────────────────────────────────────────

  /// Uploads a post to the project feed.
  ///
  /// The API expects multipart/form-data:
  /// POST /api/projects/{project_id}/feed/
  /// - image: File (multipart)
  /// - caption: String (form field)
  ///
  /// At least one of image or caption is required.
  Future<PhotoModel> uploadPhoto({
    required String filePath,
    required String employeeId,
    required String employeeName,
    required String caption,
  }) async {
    try {
      // Create multipart form data with the image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'caption': caption,
      });

      // Send the multipart form data to the feed endpoint
      // Note: Don't set Content-Type header - Dio will set it automatically to multipart/form-data
      final response = await _dio.post(
        '/projects/$projectId/feed/',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final postData = _extractObject(response.data, 'data');
      
      // Extract uploader details from nested uploader_detail object
      final uploaderDetail = postData['uploader_detail'] as Map<String, dynamic>? ?? {};
      final userId = uploaderDetail['user_id']?.toString() ?? postData['uploader']?.toString() ?? employeeId;
      final fullName = uploaderDetail['full_name'] as String? ?? employeeName;
      
      // Parse uploadedAt timestamp
      DateTime uploadedAt = DateTime.now();
      final createdAtStr = postData['created_at'] as String?;
      if (createdAtStr != null) {
        try {
          uploadedAt = DateTime.parse(createdAtStr);
        } catch (_) {
          uploadedAt = DateTime.now();
        }
      }
      
      // Extract image URL from response
      final responseImageUrl = postData['image_url'] as String? ??
                              postData['image'] as String? ?? filePath;
      
      // Extract moderation status
      final moderationStatus = postData['moderation_status'] as String? ?? 'PENDING';
      
      // Extract project ID from response
      final photoProjectId = postData['project']?.toString() ?? projectId;
      
      // Convert response to PhotoModel
      final photo = PhotoModel(
        id: postData['post_id']?.toString() ?? '',
        projectId: photoProjectId,
        imagePath: responseImageUrl,
        caption: postData['caption'] as String? ?? caption,
        employeeId: userId,
        employeeName: fullName,
        dayLabel: 'General',
        uploadedAt: uploadedAt,
        likeCount: postData['like_count'] as int? ?? 0,
        likedByCurrentUser: false,
        moderationStatus: moderationStatus,
      );
      
      return photo;
    } catch (e) {
      print('[GalleryRepository] Error uploading photo: $e');
      rethrow;
    }
  }

  // ── Delete photo ──────────────────────────────────────────────────────────

  /// Deletes [photoId] permanently. Only the uploader should call this.
  Future<void> deletePhoto(String photoId) async {
    try {
      await _dio.delete('/projects/$projectId/feed/$photoId/');
    } catch (e) {
      print('[GalleryRepository] Error deleting photo: $e');
      rethrow;
    }
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────────

  /// Likes [photoId]. Returns the updated like summary.
  /// A 409 (already liked) is handled gracefully.
  Future<Map<String, dynamic>> likePhoto(String photoId) async {
    try {
      final resp = await _dio.post('/projects/$projectId/feed/$photoId/like/');
      return _extractObject(resp.data, 'data');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {
          'photoId': photoId,
          'likeCount': (e.response?.data as Map?)?['like_count'] ?? 1,
          'likedByCurrentUser': true,
        };
      }
      rethrow;
    }
  }

  /// Unlikes [photoId].
  Future<Map<String, dynamic>> unlikePhoto(String photoId) async {
    try {
      final resp = await _dio.delete('/projects/$projectId/feed/$photoId/like/');
      return _extractObject(resp.data, 'data');
    } catch (e) {
      print('[GalleryRepository] Error unliking photo: $e');
      rethrow;
    }
  }

  // ── Moderation (Admin only) ────────────────────────────────────────────────

  /// Moderates a post (Admin only).
  /// [status] should be 'APPROVED' or 'REJECTED'
  Future<Map<String, dynamic>> moderatePost(
    String postId,
    String status,
  ) async {
    try {
      final resp = await _dio.patch(
        '/projects/$projectId/feed/$postId/moderate/',
        data: {'moderation_status': status},
      );
      return _extractObject(resp.data, 'data');
    } catch (e) {
      print('[GalleryRepository] Error moderating post: $e');
      rethrow;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<dynamic> _parseList(dynamic data, String key) {
    if (data is List) return data;
    if (data is Map) {
      if (data[key] is List) return data[key] as List;
      if (data['data'] is List) return data['data'] as List;
      if (data['results'] is List) return data['results'] as List;
    }
    return [];
  }

  Map<String, dynamic> _extractObject(dynamic data, String key) {
    if (data is Map<String, dynamic>) {
      if (data[key] is Map) return data[key] as Map<String, dynamic>;
      if (data['data'] is Map) return data['data'] as Map<String, dynamic>;
      return data;
    }
    return {};
  }
}
