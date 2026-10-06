import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../domain/models/photo_model.dart';

/// Repository for the photo gallery.
///
/// ## API contract used
/// | Method | Path                          | Auth   | Description               |
/// |--------|-------------------------------|--------|---------------------------|
/// | POST   | /albums                       | Bearer | Create album              |
/// | GET    | /albums                       | Bearer | List all albums           |
/// | POST   | /albums/{albumId}/photos      | Bearer | Upload photo (key: file)  |
/// | GET    | /albums/{albumId}/photos      | Bearer | List album photos         |
/// | DELETE | /photos/{photoId}             | Bearer | Delete a photo            |
/// | POST   | /photos/{photoId}/likes       | Bearer | Like a photo (201)        |
/// | DELETE | /photos/{photoId}/likes       | Bearer | Unlike a photo (200)      |
///
/// Albums are created on demand by name and cached in SharedPreferences
/// under the key `album_id_{sanitised_album_name}`.
class GalleryRepository {
  final Dio _dio = ApiClient.instance;
  final SharedPreferences _prefs;

  GalleryRepository(this._prefs);

  // ── Album management ──────────────────────────────────────────────────────

  /// Returns the ID of the album called [albumName], creating it if needed.
  /// Results are cached so repeat calls are instant.
  Future<String> _resolveAlbumId(String albumName) async {
    final cacheKey =
        'album_id_${albumName.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}';
    final cached = _prefs.getString(cacheKey) ?? '';
    if (cached.isNotEmpty) return cached;

    // Try to find an existing album with the same name.
    try {
      final resp = await _dio.get('/albums');
      final albums = _parseList(resp.data, 'albums');
      for (final a in albums) {
        final albumMap = a as Map<String, dynamic>;
        if ((albumMap['name'] as String? ?? '') == albumName) {
          final id =
              albumMap['_id'] as String? ?? albumMap['id'] as String? ?? '';
          if (id.isNotEmpty) {
            await _prefs.setString(cacheKey, id);
            return id;
          }
        }
      }
    } catch (_) {
      // GET /albums failed — proceed to create.
    }

    // Create a new album.
    final createResp = await _dio.post(
      '/albums',
      data: {
        'name': albumName,
        'description': '${AppConstants.eventAlbumDescription} · $albumName',
      },
    );
    final albumData = _extractObject(createResp.data, 'album');
    final newId =
        albumData['_id'] as String? ?? albumData['id'] as String? ?? '';
    if (newId.isNotEmpty) {
      await _prefs.setString(cacheKey, newId);
    }
    return newId;
  }

  // ── Fetch photos ──────────────────────────────────────────────────────────

  /// Returns photos from **all** albums on the server, merged into one list.
  /// Each photo's [PhotoModel.dayLabel] is set to its album name for display.
  Future<List<PhotoModel>> fetchPhotos() async {
    final resp = await _dio.get('/albums');
    final albums = _parseList(resp.data, 'albums');
    if (albums.isEmpty) return [];

    final allPhotos = <PhotoModel>[];
    for (final a in albums) {
      final albumMap = a as Map<String, dynamic>;
      final albumId =
          albumMap['_id'] as String? ?? albumMap['id'] as String? ?? '';
      final albumName = albumMap['name'] as String? ?? '';
      if (albumId.isEmpty) continue;
      try {
        final photoResp = await _dio.get('/albums/$albumId/photos');
        final list = _parseList(photoResp.data, 'photos');
        for (final e in list) {
          final map = Map<String, dynamic>.from(e as Map);
          // Inject albumName so the card badge shows the album name.
          map.putIfAbsent('dayLabel', () => albumName);
          allPhotos.add(PhotoModel.fromJson(map));
        }
      } catch (_) {
        // Skip albums we can't access.
      }
    }
    return allPhotos;
  }

  // ── Upload photo ──────────────────────────────────────────────────────────

  /// Uploads [filePath] into the album called [albumName] (created if needed).
  Future<PhotoModel> uploadPhoto({
    required String filePath,
    required String employeeId,
    required String employeeName,
    required String caption,
    required String albumName,
  }) async {
    final albumId = await _resolveAlbumId(albumName);

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
      ),
      'title': caption,       // server field for caption/title
      'caption': caption,     // kept for backward compat
      'dayLabel': albumName,
      'employeeId': employeeId,
      'employeeName': employeeName,
    });

    final response = await _dio.post(
      '/albums/$albumId/photos',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final photoData = _extractObject(response.data, 'photo');
    photoData.putIfAbsent('albumId', () => albumId);
    photoData.putIfAbsent('employeeId', () => employeeId);
    photoData.putIfAbsent('employeeName', () => employeeName);
    photoData.putIfAbsent('caption', () => caption);
    photoData.putIfAbsent('dayLabel', () => albumName);
    return PhotoModel.fromJson(photoData);
  }

  // ── Delete photo ──────────────────────────────────────────────────────────

  /// Deletes [photoId] permanently. Only the uploader should call this.
  Future<void> deletePhoto(String photoId) async {
    await _dio.delete('/photos/$photoId');
  }

  // ── Like / Unlike ─────────────────────────────────────────────────────────

  /// Likes [photoId]. Returns the updated like summary.
  /// A 409 (already liked) is handled gracefully.
  Future<Map<String, dynamic>> likePhoto(String photoId) async {
    try {
      final resp = await _dio.post('/photos/$photoId/likes');
      return _extractObject(resp.data, 'like');
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {
          'photoId': photoId,
          'likeCount': (e.response?.data as Map?)?['likeCount'] ?? 1,
          'likedByCurrentUser': true,
        };
      }
      rethrow;
    }
  }

  /// Unlikes [photoId] using DELETE /photos/{photoId}/likes.
  Future<Map<String, dynamic>> unlikePhoto(String photoId) async {
    final resp = await _dio.delete('/photos/$photoId/likes');
    return _extractObject(resp.data, 'like');
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