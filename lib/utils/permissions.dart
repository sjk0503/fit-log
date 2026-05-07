import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  static Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> checkStoragePermission() async {
    final status = await Permission.photos.status;
    return status.isGranted || status.isLimited;
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    final camera = await requestCameraPermission();
    final storage = await requestStoragePermission();
    return {
      'camera': camera,
      'storage': storage,
    };
  }

  /// Opens the system app settings page so the user can grant denied
  /// permissions. Wraps permission_handler's top-level openAppSettings().
  static Future<bool> openSystemSettings() async {
    return await openAppSettings();
  }
}
