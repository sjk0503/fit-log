# Fit-Log

매일의 패션을 일관된 포즈로 기록하는 OOTD 전용 카메라 앱

## 프로젝트 개요

같은 옷이라도 어제 어떻게 찍었는지 기억하기 어렵고, 매일의 변화를 비교하려면 일관된 구도로 찍는 것이 중요합니다. Fit-Log는 **이전 사진을 기준 삼아 같은 포즈·같은 구도로 오늘의 OOTD를 촬영**하도록 돕는 카메라 앱입니다.

### 핵심 기능

1. **분할 모드 촬영** — 화면을 50:50으로 세로 분할. 한쪽에는 이전 사진, 반대쪽에는 실시간 카메라 프리뷰. 분할선이 정렬 가이드 역할을 한다.
2. **오버레이 모드 촬영** — 이전 사진을 카메라 프리뷰 위에 반투명으로 겹쳐 보여 같은 포즈로 따라 찍을 수 있게 한다. 투명도는 슬라이더로 실시간 조절.
3. **레이아웃 합성** — 여러 OOTD 사진을 2x2, 3x3, 3x2, 4x2 그리드로 합쳐 한 장의 이미지로 저장.

## 기술 스택

**Flutter (Dart)** — 단일 코드베이스로 iOS / Android 동시 지원.

### 디자인 원칙: Material 위젯 사용 금지

Flutter를 선택하되, **Material / Cupertino 위젯에 의존하지 않는다.** 디자인은 별도 디자인 에이전트가 산출한 디자인 시스템에 따라 **처음부터 직접 그리는 것을 원칙**으로 한다 — 이 앱의 시각적 정체성은 어떤 플랫폼 디자인 언어(Material, HIG)에도 묶이지 않아야 한다.

| 영역 | 방침 |
| --- | --- |
| 레이아웃 | `Container`, `Stack`, `Row`/`Column`, `SizedBox`, `Padding`, `Align` 등 원시 위젯만 사용 |
| 그리기 | 비표준 모양·그라데이션·셰이더는 `CustomPaint` / `ShaderMask` / `BackdropFilter` 로 직접 구현 |
| 입력 | `GestureDetector` / `Listener` 기반으로 자체 인터랙션 구현 (기성 `Button`, `Slider`, `AppBar`, `Scaffold`의 디자인된 부분 사용 금지) |
| 텍스트 | `Text` + 명시적 `TextStyle` (디자인 시스템에서 정의된 토큰만 참조) |
| 다이얼로그·시트 | 자체 오버레이로 구현, `showDialog` / `showModalBottomSheet`의 디폴트 모양 의존 금지 |

> 예외: `MaterialApp` / `CupertinoApp` 자체는 라우팅·로컬리제이션 기반으로 사용해도 된다 (시각 요소가 아니므로). 다만 그 안에서 **렌더되는 모든 시각 요소는 자체 디자인 시스템 컴포넌트로 대체**한다.

### 핵심 패키지
- `camera` — 카메라 제어
- `path_provider`, `path` — 파일 저장 경로
- `permission_handler` — 카메라 / 갤러리 권한
- `image_picker`, `image` — 이미지 선택 / 처리
- `image_gallery_saver` — 시스템 갤러리 저장
- `shared_preferences` — 설정 영속화
- `intl`, `uuid`

### 환경
- Flutter SDK 최신 stable
- iOS 13.0+ / Android 8.0+ (minSdkVersion 26)
- 화면 회전: 세로 모드 고정

## 프로젝트 구조

```
fit-log/
├── lib/
│   ├── main.dart
│   ├── design/              # 디자인 시스템 (토큰, 자체 컴포넌트)
│   │   ├── tokens/          # 컬러·타이포·간격·라운딩 토큰
│   │   └── components/      # 자체 구현 버튼/슬라이더/시트 등
│   ├── models/              # 데이터 모델
│   ├── screens/             # 화면 (Home, Camera, Layout, PhotoViewer)
│   ├── widgets/             # 카메라 / 그리드 / 합성 위젯
│   ├── services/            # 카메라·저장·로케일·튜토리얼 서비스
│   ├── l10n/                # 다국어 (en, ko, ja, zh)
│   └── utils/               # 권한·상수
├── ios/                     # iOS 플랫폼 설정
├── android/                 # Android 플랫폼 설정
├── docs/                    # 디자인 산출물 (디자인 에이전트 input)
└── test/
```

## 개발 단계별 가이드

### Phase 1: 디자인 시스템 셋업
1. 디자인 에이전트 산출물(컬러·타이포·간격·컴포넌트 명세)을 `docs/`에 정리
2. `lib/design/tokens/`에 디자인 토큰을 Dart 상수로 옮김
3. `lib/design/components/`에 자체 버튼·슬라이더·시트·다이얼로그·앱바 등 핵심 컴포넌트 구현 (Material 위젯 사용 금지)

### Phase 2: 카메라 기능
1. 기본 카메라 초기화·세션 관리
2. 분할 모드 — 50:50 분할, 한쪽 이전 사진, 좌우 전환, 분할선 가이드
3. 오버레이 모드 — 이전 사진을 프리뷰 위에 반투명 합성, 슬라이더로 0~100% 투명도 조절
4. 사진 촬영 → 앱 내부 저장 + 시스템 갤러리 자동 저장

### Phase 3: 라이브러리 / 관리
1. 홈 화면 OOTD 사진 목록 (날짜 내림차순)
2. 사진 상세 보기
3. 다중 선택 → 삭제 / 레이아웃 합성 진입
4. 선택한 사진을 새 촬영의 레퍼런스로 지정

### Phase 4: 레이아웃 합성
1. 다중 사진 선택 UI
2. 2x2 / 3x3 / 3x2 / 4x2 레이아웃 옵션
3. 각 셀 정사각 크롭, 부족한 셀은 배경색으로 채움
4. 고해상도(>= 2000x2000px) 합성 이미지로 저장 + 갤러리 저장

### Phase 5: 마감
1. iOS / Android 양 플랫폼 검증
2. 권한 거부 / 저장소 부족 등 예외 처리
3. 메모리 사용 검증 (고해상도 이미지 처리)

## 권한 설정

### iOS (`ios/Runner/Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>OOTD 사진을 촬영하기 위해 카메라 접근이 필요합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>사진 라이브러리에서 이전 사진을 불러오기 위해 필요합니다</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>촬영한 사진을 갤러리에 저장하기 위해 권한이 필요합니다</string>
```

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

`android/app/build.gradle` 의 `minSdkVersion` 26 (Android 8.0).

## 시작하기

```bash
flutter pub get
flutter run
```

테스트 / 정적 분석:
```bash
flutter analyze
flutter test
```

## 주요 기능 상세 명세

### 1. 분할 모드
- 화면 50:50 세로 분할
- 한쪽: 선택한 이전 사진 / 반대쪽: 실시간 카메라 프리뷰
- 좌우 전환 토글
- 분할선 가이드 표시
- 이전 사진 선택 / 변경 가능

### 2. 오버레이 모드
- 이전 사진을 카메라 프리뷰 위에 중앙 정렬로 반투명 합성
- 슬라이더로 투명도 실시간 조절 (0~100%)
- 사진 크기는 화면 대비 고정 비율
- 이전 사진 선택 / 변경 가능

### 3. 레이아웃 합성
- 지원 레이아웃: 2x2 (4장), 3x3 (9장), 3x2 (6장), 4x2 (8장)
- 각 셀 정사각 크롭
- 사진이 부족할 경우 빈 셀은 배경색으로 채움
- 고해상도(>= 2000x2000px) 합성 저장

### 4. 저장 방식
- 촬영 즉시 앱 내부 저장소에 저장 (날짜 기반 파일명)
- 동시에 시스템 갤러리에 자동 저장
- 레이아웃 합성 이미지도 동일

## 개발 시 주의사항

1. **카메라 권한** — 첫 실행 시 점진 요청, 거부 시 설정 앱 이동 가이드
2. **메모리 관리** — 고해상도 이미지 합성 시 다운샘플링 / 스트리밍
3. **화면 회전** — 세로 모드 고정 (`SystemChrome.setPreferredOrientations`)
4. **비율 일관성** — 다양한 디바이스 해상도에서 분할 / 오버레이 비율 유지
5. **저장 실패 처리** — 저장소 공간 부족, 권한 거부 등 예외 처리
6. **Material 위젯 금지 원칙 유지** — 새 화면·컴포넌트 추가 시 Material/Cupertino 위젯의 시각 요소를 끌어다 쓰지 않는다 (사용 시 디자인 일관성이 무너짐)

## 다음 단계 (추후 검토)

- [ ] 사진 편집 (필터, 밝기 조정)
- [ ] 태그 / 카테고리
- [ ] 캘린더 뷰
- [ ] SNS 공유
- [ ] 추가 레이아웃 옵션
- [ ] 클라우드 백업

> 디자인 시스템(컬러, 타이포그래피, 컴포넌트)의 구체적 정의는 별도 디자인 산출물(`docs/`)에서 관리한다. 본 문서는 제품 스펙·기술 방침만 담는다.
