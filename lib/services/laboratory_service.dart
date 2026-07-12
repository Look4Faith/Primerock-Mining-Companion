import '../core/constants/app_constants.dart';
import '../models/lab_content.dart';
import 'offline_content_service.dart';

class LaboratoryService {
  LaboratoryService(this._content);

  final OfflineContentService _content;
  static const _cacheKey = 'lab_content_v2';

  Future<LabContent> load() async {
    final json = await _content.loadJson(
      cacheKey: _cacheKey,
      assetPath: AppConstants.labContentAsset,
      remotePath: AppConstants.remoteLabPath,
    );
    return LabContent.fromJson(json);
  }
}
