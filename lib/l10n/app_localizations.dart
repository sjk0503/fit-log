import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
    Locale('zh'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Fit-Log',
      'splitMode': 'Split Mode',
      'overlayMode': 'Overlay Mode',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'layout': 'Layout',
      'save': 'Save',
      'delete': 'Delete',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'noPhotos': 'No photos yet',
      'takeFirstPhoto': 'Take your first Fit-Log photo!',
      'cameraPermissionRequired': 'Camera permission is required',
      'storagePermissionRequired': 'Storage permission is required',
      'goToSettings': 'Go to Settings',
      'deletePhotos': 'Delete Photos',
      'deleteSelectedPhotos': 'Delete {n} selected photos?',
      'nSelected': '{n} selected',
      'photoSaved': 'Photo saved',
      'failedToSavePhoto': 'Failed to save photo',
      'noPhotosAvailable': 'No photos available',
      'selectReferencePhoto': 'Select Reference Photo',
      'retry': 'Retry',
      'selectPhoto': 'Select Photo',
      'selectAtLeastOnePhoto': 'Please select at least one photo',
      'layoutSavedToGallery': 'Layout saved to gallery',
      'failedToSaveLayout': 'Failed to save layout',
      'createLayout': 'Create Layout',
      'background': 'Background',
      'useAsReference': 'Use as Reference',
      'deletePhoto': 'Delete Photo',
      'deleteThisPhoto': 'Delete this photo?',
      'selectReference': 'Select reference',
      'selectAReferencePhoto': 'Select a reference photo',
      'failedToLoadPhotos': 'Failed to load photos',
      'language': 'Language',
      'systemDefault': 'System Default',
      'tutorialChangeLanguage': 'You can change the app language here',
      'tutorialTakePhoto': 'Tap here to take a photo!',
      'tutorialSwitchMode': 'Switch between Split and Overlay modes',
      'tutorialCapture': 'Press this button to take a photo!',
      'tutorialSwapSides': 'Swap the left and right views',
      'tutorialSkip': 'Skip',
      'tutorialNext': 'Next',
      'tutorialDone': 'Got it!',
    },
    'ko': {
      'appName': 'Fit-Log',
      'splitMode': '스플릿 모드',
      'overlayMode': '오버레이 모드',
      'gallery': '갤러리',
      'camera': '카메라',
      'layout': '레이아웃',
      'save': '저장',
      'delete': '삭제',
      'cancel': '취소',
      'confirm': '확인',
      'noPhotos': '사진이 없습니다',
      'takeFirstPhoto': '첫 번째 Fit-Log 사진을 찍어보세요!',
      'cameraPermissionRequired': '카메라 권한이 필요합니다',
      'storagePermissionRequired': '저장소 권한이 필요합니다',
      'goToSettings': '설정으로 이동',
      'deletePhotos': '사진 삭제',
      'deleteSelectedPhotos': '선택한 {n}장의 사진을 삭제할까요?',
      'nSelected': '{n}장 선택됨',
      'photoSaved': '사진이 저장되었습니다',
      'failedToSavePhoto': '사진 저장에 실패했습니다',
      'noPhotosAvailable': '사용 가능한 사진이 없습니다',
      'selectReferencePhoto': '참조 사진 선택',
      'retry': '재시도',
      'selectPhoto': '사진 선택',
      'selectAtLeastOnePhoto': '최소 1장의 사진을 선택해주세요',
      'layoutSavedToGallery': '레이아웃이 갤러리에 저장되었습니다',
      'failedToSaveLayout': '레이아웃 저장에 실패했습니다',
      'createLayout': '레이아웃 만들기',
      'background': '배경',
      'useAsReference': '참조 사진으로 사용',
      'deletePhoto': '사진 삭제',
      'deleteThisPhoto': '이 사진을 삭제할까요?',
      'selectReference': '참조 사진 선택',
      'selectAReferencePhoto': '참조 사진을 선택하세요',
      'failedToLoadPhotos': '사진 불러오기에 실패했습니다',
      'language': '언어',
      'systemDefault': '시스템 기본',
      'tutorialChangeLanguage': '여기서 앱 언어를 변경할 수 있어요',
      'tutorialTakePhoto': '이 버튼을 눌러 사진을 찍어보세요!',
      'tutorialSwitchMode': '스플릿과 오버레이 모드를 전환할 수 있어요',
      'tutorialCapture': '이 버튼을 눌러 촬영하세요!',
      'tutorialSwapSides': '좌우 화면을 바꿀 수 있어요',
      'tutorialSkip': '건너뛰기',
      'tutorialNext': '다음',
      'tutorialDone': '확인!',
    },
    'ja': {
      'appName': 'Fit-Log',
      'splitMode': 'スプリットモード',
      'overlayMode': 'オーバーレイモード',
      'gallery': 'ギャラリー',
      'camera': 'カメラ',
      'layout': 'レイアウト',
      'save': '保存',
      'delete': '削除',
      'cancel': 'キャンセル',
      'confirm': '確認',
      'noPhotos': '写真がありません',
      'takeFirstPhoto': '最初のFit-Log写真を撮りましょう！',
      'cameraPermissionRequired': 'カメラの許可が必要です',
      'storagePermissionRequired': 'ストレージの許可が必要です',
      'goToSettings': '設定に移動',
      'deletePhotos': '写真を削除',
      'deleteSelectedPhotos': '選択した{n}枚の写真を削除しますか？',
      'nSelected': '{n}枚選択中',
      'photoSaved': '写真を保存しました',
      'failedToSavePhoto': '写真の保存に失敗しました',
      'noPhotosAvailable': '利用可能な写真がありません',
      'selectReferencePhoto': '参考写真を選択',
      'retry': '再試行',
      'selectPhoto': '写真を選択',
      'selectAtLeastOnePhoto': '少なくとも1枚の写真を選択してください',
      'layoutSavedToGallery': 'レイアウトをギャラリーに保存しました',
      'failedToSaveLayout': 'レイアウトの保存に失敗しました',
      'createLayout': 'レイアウト作成',
      'background': '背景',
      'useAsReference': '参考写真として使用',
      'deletePhoto': '写真を削除',
      'deleteThisPhoto': 'この写真を削除しますか？',
      'selectReference': '参考写真を選択',
      'selectAReferencePhoto': '参考写真を選択してください',
      'failedToLoadPhotos': '写真の読み込みに失敗しました',
      'language': '言語',
      'systemDefault': 'システムデフォルト',
      'tutorialChangeLanguage': 'ここでアプリの言語を変更できます',
      'tutorialTakePhoto': 'ここをタップして写真を撮りましょう！',
      'tutorialSwitchMode': 'スプリットとオーバーレイモードを切り替えられます',
      'tutorialCapture': 'このボタンを押して撮影しましょう！',
      'tutorialSwapSides': '左右の画面を入れ替えられます',
      'tutorialSkip': 'スキップ',
      'tutorialNext': '次へ',
      'tutorialDone': 'わかった！',
    },
    'zh': {
      'appName': 'Fit-Log',
      'splitMode': '分屏模式',
      'overlayMode': '叠加模式',
      'gallery': '相册',
      'camera': '相机',
      'layout': '布局',
      'save': '保存',
      'delete': '删除',
      'cancel': '取消',
      'confirm': '确认',
      'noPhotos': '暂无照片',
      'takeFirstPhoto': '拍摄你的第一张Fit-Log照片！',
      'cameraPermissionRequired': '需要相机权限',
      'storagePermissionRequired': '需要存储权限',
      'goToSettings': '前往设置',
      'deletePhotos': '删除照片',
      'deleteSelectedPhotos': '删除选中的{n}张照片？',
      'nSelected': '已选择{n}张',
      'photoSaved': '照片已保存',
      'failedToSavePhoto': '保存照片失败',
      'noPhotosAvailable': '没有可用的照片',
      'selectReferencePhoto': '选择参考照片',
      'retry': '重试',
      'selectPhoto': '选择照片',
      'selectAtLeastOnePhoto': '请至少选择一张照片',
      'layoutSavedToGallery': '布局已保存到相册',
      'failedToSaveLayout': '保存布局失败',
      'createLayout': '创建布局',
      'background': '背景',
      'useAsReference': '用作参考',
      'deletePhoto': '删除照片',
      'deleteThisPhoto': '删除这张照片？',
      'selectReference': '选择参考',
      'selectAReferencePhoto': '请选择参考照片',
      'failedToLoadPhotos': '加载照片失败',
      'language': '语言',
      'systemDefault': '跟随系统',
      'tutorialChangeLanguage': '在这里可以更改应用语言',
      'tutorialTakePhoto': '点击这里拍摄照片！',
      'tutorialSwitchMode': '可以切换分屏和叠加模式',
      'tutorialCapture': '按下此按钮拍照！',
      'tutorialSwapSides': '可以交换左右画面',
      'tutorialSkip': '跳过',
      'tutorialNext': '下一步',
      'tutorialDone': '知道了！',
    },
  };

  String _translate(String key) {
    final langCode = locale.languageCode;
    final translations = _localizedValues[langCode] ?? _localizedValues['en']!;
    return translations[key] ?? _localizedValues['en']![key] ?? key;
  }

  String get appName => _translate('appName');
  String get splitMode => _translate('splitMode');
  String get overlayMode => _translate('overlayMode');
  String get gallery => _translate('gallery');
  String get camera => _translate('camera');
  String get layout => _translate('layout');
  String get save => _translate('save');
  String get delete => _translate('delete');
  String get cancel => _translate('cancel');
  String get confirm => _translate('confirm');
  String get noPhotos => _translate('noPhotos');
  String get takeFirstPhoto => _translate('takeFirstPhoto');
  String get cameraPermissionRequired => _translate('cameraPermissionRequired');
  String get storagePermissionRequired =>
      _translate('storagePermissionRequired');
  String get goToSettings => _translate('goToSettings');
  String get deletePhotos => _translate('deletePhotos');
  String get photoSaved => _translate('photoSaved');
  String get failedToSavePhoto => _translate('failedToSavePhoto');
  String get noPhotosAvailable => _translate('noPhotosAvailable');
  String get selectReferencePhoto => _translate('selectReferencePhoto');
  String get retry => _translate('retry');
  String get selectPhoto => _translate('selectPhoto');
  String get selectAtLeastOnePhoto => _translate('selectAtLeastOnePhoto');
  String get layoutSavedToGallery => _translate('layoutSavedToGallery');
  String get failedToSaveLayout => _translate('failedToSaveLayout');
  String get createLayout => _translate('createLayout');
  String get background => _translate('background');
  String get useAsReference => _translate('useAsReference');
  String get deletePhoto => _translate('deletePhoto');
  String get deleteThisPhoto => _translate('deleteThisPhoto');
  String get selectReference => _translate('selectReference');
  String get selectAReferencePhoto => _translate('selectAReferencePhoto');
  String get failedToLoadPhotos => _translate('failedToLoadPhotos');
  String get language => _translate('language');
  String get systemDefault => _translate('systemDefault');
  String get tutorialChangeLanguage => _translate('tutorialChangeLanguage');
  String get tutorialTakePhoto => _translate('tutorialTakePhoto');
  String get tutorialSwitchMode => _translate('tutorialSwitchMode');
  String get tutorialCapture => _translate('tutorialCapture');
  String get tutorialSwapSides => _translate('tutorialSwapSides');
  String get tutorialSkip => _translate('tutorialSkip');
  String get tutorialNext => _translate('tutorialNext');
  String get tutorialDone => _translate('tutorialDone');

  String deleteSelectedPhotos(int n) =>
      _translate('deleteSelectedPhotos').replaceAll('{n}', n.toString());

  String nSelected(int n) =>
      _translate('nSelected').replaceAll('{n}', n.toString());
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ko', 'ja', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
