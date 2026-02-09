import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get hasMultipleCameras => _cameras.length > 1;

  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Prefer back camera
    _currentCameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );
    if (_currentCameraIndex == -1) _currentCameraIndex = 0;

    await _initializeController();
  }

  Future<void> _initializeController() async {
    _controller?.dispose();

    _controller = CameraController(
      _cameras[_currentCameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length <= 1) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    _isInitialized = false;
    await _initializeController();
  }

  Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    if (_controller!.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile xFile = await _controller!.takePicture();
      return File(xFile.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.setFlashMode(mode);
  }

  Future<void> setFocusPoint(Offset point) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFocusPoint(point);
      await _controller!.setExposurePoint(point);
      await _controller!.setFocusMode(FocusMode.auto);
    } catch (e) {
      debugPrint('Focus error: $e');
    }
  }

  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final minZoom = await _controller!.getMinZoomLevel();
    final maxZoom = await _controller!.getMaxZoomLevel();
    final clampedZoom = zoom.clamp(minZoom, maxZoom);
    await _controller!.setZoomLevel(clampedZoom);
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
