import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ImageStorageDataSource {
  Future<String> uploadLessonImage(String filePath);
}

class SupabaseImageStorageDataSource implements ImageStorageDataSource {
  static const _bucket = 'lesson-images';

  final SupabaseClient _client;

  SupabaseImageStorageDataSource(this._client);

  @override
  Future<String> uploadLessonImage(String filePath) async {
    final file = File(filePath);
    final extension = filePath.split('.').last;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.hashCode}.$extension';

    await _client.storage.from(_bucket).upload(fileName, file);

    return _client.storage.from(_bucket).getPublicUrl(fileName);
  }
}
