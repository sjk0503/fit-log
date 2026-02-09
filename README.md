# OOTD Camera App

매일의 패션을 일관된 포즈로 기록하는 OOTD 전용 카메라 앱

## 프로젝트 개요

### 핵심 기능
1. **분할 모드 촬영**: 화면을 50:50으로 세로 분할하여 이전 사진과 비교하며 촬영
2. **오버레이 모드 촬영**: 이전 사진을 투명하게 겹쳐 보며 같은 포즈로 촬영 (투명도 조절 가능)
3. **레이아웃 저장**: 여러 OOTD 사진을 2x2, 3x3, 3x2, 4x2 그리드로 합성하여 저장

### 기술 스택
- **Framework**: Flutter
- **플랫폼**: iOS / Android
- **주요 패키지**:
    - `camera`: 카메라 제어
    - `path_provider`: 파일 저장 경로 관리
    - `permission_handler`: 카메라/갤러리 권한 관리
    - `image_picker`: 이미지 선택
    - `image`: 이미지 처리 및 합성
    - `gallery_saver` 또는 `image_gallery_saver`: 갤러리 저장

## 프로젝트 구조

```
lib/
├── main.dart
├── models/
│   └── ootd_photo.dart              # OOTD 사진 데이터 모델
├── screens/
│   ├── home_screen.dart              # 메인 화면 (사진 갤러리)
│   ├── camera_screen.dart            # 카메라 촬영 화면
│   └── layout_screen.dart            # 레이아웃 합성 화면
├── widgets/
│   ├── split_camera_view.dart        # 분할 모드 카메라 위젯
│   ├── overlay_camera_view.dart      # 오버레이 모드 카메라 위젯
│   ├── photo_grid.dart               # 사진 그리드 위젯
│   └── layout_composer.dart          # 레이아웃 합성 위젯
├── services/
│   ├── camera_service.dart           # 카메라 제어 서비스
│   ├── storage_service.dart          # 로컬 저장 서비스
│   └── image_service.dart            # 이미지 처리 서비스
└── utils/
    ├── constants.dart                # 상수 (색상, 레이아웃 설정 등)
    └── permissions.dart              # 권한 처리 유틸
```

## 개발 단계별 가이드

### Phase 1: 프로젝트 셋업 및 기본 구조
1. Flutter 프로젝트 생성
2. 필요한 패키지 추가 (pubspec.yaml)
3. iOS/Android 권한 설정
4. 기본 화면 라우팅 구조 구현
5. 보라색 테마 설정

### Phase 2: 카메라 기능 구현
1. 기본 카메라 초기화 및 제어
2. 분할 모드 구현
    - 50:50 화면 분할
    - 이전 사진 표시 (왼쪽/오른쪽 선택 가능)
    - 현재 카메라 프리뷰
3. 오버레이 모드 구현
    - 이전 사진 투명도 오버레이
    - 슬라이더로 투명도 조절 (0~100%)
    - 이전 사진 선택 기능
4. 사진 촬영 및 저장
    - 앱 내부 저장
    - 갤러리 자동 저장

### Phase 3: 갤러리 및 관리 기능
1. 홈 화면 - OOTD 사진 목록 표시
2. 날짜별 정렬
3. 사진 선택 및 삭제 기능
4. 사진 상세 보기

### Phase 4: 레이아웃 합성 기능
1. 여러 사진 선택 UI
2. 레이아웃 옵션 선택 (2x2, 3x3, 3x2, 4x2)
3. 이미지 합성 처리
4. 합성된 이미지 저장 및 갤러리 저장

### Phase 5: UI/UX 개선 및 테스트
1. 보라색 테마 일관성 적용
2. 애니메이션 및 전환 효과
3. iOS/Android 테스트
4. 예외 처리 및 에러 핸들링

## 시작하기

### 필수 요구사항
- Flutter SDK (최신 stable 버전)
- Xcode (iOS 개발용, macOS만)
- Android Studio 또는 Android SDK
- iOS 13.0+ / Android 8.0+ 타겟

### 초기 설정

1. **프로젝트 생성**
```bash
flutter create ootd_camera
cd ootd_camera
```

2. **pubspec.yaml에 의존성 추가**
```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+5
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  image_picker: ^1.0.4
  image: ^4.1.3
  image_gallery_saver: ^2.0.3
  intl: ^0.18.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

3. **iOS 권한 설정** (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>OOTD 사진을 촬영하기 위해 카메라 접근이 필요합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>촬영한 사진을 저장하기 위해 갤러리 접근이 필요합니다</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>촬영한 사진을 갤러리에 저장하기 위해 권한이 필요합니다</string>
```

4. **Android 권한 설정** (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

5. **Android minSdkVersion 설정** (`android/app/build.gradle`)
```gradle
android {
    defaultConfig {
        minSdkVersion 26  // Android 8.0
    }
}
```

### 실행
```bash
flutter pub get
flutter run
```

## 주요 기능 상세 명세

### 1. 분할 모드
- 화면을 정확히 50:50 세로 분할
- 한쪽에는 선택한 이전 사진, 다른 쪽에는 실시간 카메라 프리뷰
- UI 버튼으로 이전 사진 위치 전환 (왼쪽 ↔ 오른쪽)
- 분할선 표시로 정렬 가이드 제공

### 2. 오버레이 모드
- 이전 사진을 현재 카메라 뷰 위에 중앙 정렬로 반투명 표시
- 슬라이더로 투명도 실시간 조절 (0~100%)
- 사진 크기는 화면 대비 고정 비율로 유지
- 이전 사진 선택 기능

### 3. 레이아웃 합성
- 지원 레이아웃: 2x2 (4장), 3x3 (9장), 3x2 (6장), 4x2 (8장)
- 각 셀은 정사각형으로 크롭
- 사진이 부족하면 빈 셀은 배경색으로 채움
- 고해상도 이미지로 합성 (예: 2000x2000px 이상)

### 4. 저장 방식
- 촬영 즉시 앱 내부 저장소에 저장 (날짜 기반 파일명)
- 동시에 기기 갤러리에 자동 저장
- 레이아웃 합성 이미지도 동일하게 저장

## 디자인 가이드

### 컬러 테마 (보라색 계열)
```dart
// Primary Colors
Primary: #7C3AED (보라)
Primary Light: #A78BFA
Primary Dark: #5B21B6

// Background
Background: #F9FAFB
Surface: #FFFFFF

// Accent
Accent: #EC4899 (핑크)

// Text
Text Primary: #1F2937
Text Secondary: #6B7280
```

### 주요 UI 컴포넌트
- **촬영 버튼**: 큰 원형 버튼 (Primary 색상)
- **모드 전환**: 아이콘 기반 토글 버튼
- **투명도 슬라이더**: 최소한의 디자인, Primary 색상 트랙
- **레이아웃 선택**: 그리드 미리보기 카드

## 개발 시 주의사항

1. **카메라 권한**: 앱 첫 실행 시 권한 요청, 거부 시 설정 앱으로 이동 가이드
2. **메모리 관리**: 고해상도 이미지 처리 시 메모리 효율적 처리 (이미지 압축, 스트림 처리)
3. **화면 회전**: 세로 모드 고정 권장
4. **비율 유지**: 다양한 디바이스 해상도에서 일관된 비율 유지
5. **저장 실패 처리**: 저장소 공간 부족, 권한 거부 등 예외 상황 핸들링

## 다음 단계 (추후 검토)

- [ ] 사진 편집 기능 (필터, 밝기 조정)
- [ ] 태그/카테고리 시스템
- [ ] 캘린더 뷰
- [ ] SNS 공유 기능
- [ ] 추가 레이아웃 옵션
- [ ] 클라우드 백업