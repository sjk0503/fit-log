import 'package:flutter/widgets.dart';

import 'static_page_shell.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageShell(
      eyebrow: 'HELP',
      title: '도움말',
      sections: _sections,
    );
  }
}

const _sections = <StaticSection>[
  StaticSection(
    heading: '분할 모드는 무엇인가요?',
    body:
        '화면을 50:50으로 나눠 한쪽엔 어제(또는 골라둔) 사진, 다른 한쪽엔 카메라 라이브 화면을 보여줍니다. 가운데 분할선을 가이드 삼아 같은 자리에서 같은 포즈로 서면 비교하기 좋은 사진이 나옵니다.',
  ),
  StaticSection(
    heading: '오버레이 모드는 무엇인가요?',
    body:
        '예전 사진을 카메라 화면 위에 반투명으로 겹쳐서 보여 줍니다. 슬라이더로 투명도를 조절해 어깨선과 발 위치를 정확히 맞춘 뒤 셔터를 누르면 됩니다.',
  ),
  StaticSection(
    heading: '연속 일자(streak)는 어떻게 계산되나요?',
    body:
        '오늘부터 거꾸로 거슬러 올라가며 사진이 있는 연속된 날의 수를 세요. 하루라도 비면 0으로 초기화됩니다.',
  ),
  StaticSection(
    heading: '레이아웃 합성은 무엇인가요?',
    body:
        '여러 OOTD 사진을 2x2, 3x3, 3x2, 4x2 그리드로 묶어 한 장의 이미지로 저장합니다. 시간이 흐른 모습을 한눈에 볼 때 유용해요.',
  ),
  StaticSection(
    heading: '사진은 어디에 저장되나요?',
    body:
        '앱 내부 저장소와 휴대전화의 사진 라이브러리에 동시에 저장됩니다. 외부 서버나 클라우드로는 절대 전송되지 않습니다.',
  ),
  StaticSection(
    heading: '권한 요청을 거부했어요',
    body:
        '카메라나 사진 권한이 없으면 해당 기능을 사용할 수 없어요. 시스템 설정 앱에서 Fit-Log를 찾아 권한을 다시 켜 주세요. 앱 내에서 "설정 열기" 버튼으로 바로 이동할 수 있습니다.',
  ),
  StaticSection(
    heading: '사진을 잘못 찍었어요',
    body:
        '라이브러리에서 사진을 길게 누르면 선택 모드로 들어가고, 거기서 한 장 또는 여러 장을 선택해 삭제할 수 있습니다. 시스템 갤러리에서도 함께 삭제됩니다.',
  ),
  StaticSection(
    heading: '온보딩을 다시 보고 싶어요',
    body: '설정 화면에서 "온보딩 다시 보기"를 눌러 주세요.',
  ),
  StaticSection(
    heading: '문의',
    body:
        '문제가 해결되지 않거나 의견이 있으시면 앱 정보 화면의 연락처를 통해 알려 주세요. 빠르게 반영하겠습니다.',
  ),
];
