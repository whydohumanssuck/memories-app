import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

enum DeviceMediaState { idle, loading, loaded, denied }

class DeviceMediaProvider extends ChangeNotifier {
  DeviceMediaState _state = DeviceMediaState.idle;
  List<AssetEntity> _assets = [];
  bool _isLoading = false;

  DeviceMediaState get state => _state;
  List<AssetEntity> get assets => List.unmodifiable(_assets);
  bool get isLoading => _isLoading;

  Future<void> loadMedia() async {
    if (_isLoading) return;
    _isLoading = true;
    _state = DeviceMediaState.loading;
    notifyListeners();

    try {
      final PermissionState permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        _state = DeviceMediaState.denied;
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        onlyAll: true,
      );

      if (paths.isEmpty) {
        _assets = [];
      } else {
        final AssetPathEntity all = paths.first;
        final List<AssetEntity> assets = await all.getAssetListPaged(
          page: 0,
          size: 400,
        );
        _assets = assets;
      }
      _state = DeviceMediaState.loaded;
    } catch (_) {
      _state = DeviceMediaState.denied;
    }
    _isLoading = false;
    notifyListeners();
  }
}
