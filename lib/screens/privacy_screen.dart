import 'package:flutter/widgets.dart';

import 'static_page_shell.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageShell(
      eyebrow: 'PRIVACY POLICY',
      title: '개인정보 처리방침',
      sections: _sections,
    );
  }
}

const _sections = <StaticSection>[
  StaticSection(
    heading: '한 줄 요약',
    body:
        'Fit-Log는 어떠한 개인정보도 외부 서버로 전송하지 않습니다. 촬영된 사진과 메타데이터(촬영 시각, 노트)는 사용자의 기기 안에만 저장됩니다.',
  ),
  StaticSection(
    heading: '수집하는 정보',
    body:
        '아래 정보는 모두 사용자의 기기에 한정해서 처리합니다.\n\n'
        '카메라로 촬영한 사진\n'
        '사진의 촬영 시각과 사용자가 직접 입력한 노트\n'
        '앱 사용 설정 값(예: 언어 선택)\n\n'
        '이름, 이메일, 전화번호, 위치 정보, 광고 식별자 등 어떤 식별 정보도 수집하지 않습니다.',
  ),
  StaticSection(
    heading: '저장 위치',
    body:
        '촬영된 사진은 두 위치에 저장됩니다.\n\n'
        '앱 내부 저장소: 앱을 삭제하면 함께 사라집니다.\n'
        '시스템 사진 라이브러리: 사용자가 직접 관리할 수 있도록 휴대전화 갤러리에도 동일한 사진이 저장됩니다.\n\n'
        '앱은 외부 클라우드, 분석 서버, 광고 네트워크에 어떤 데이터도 보내지 않습니다.',
  ),
  StaticSection(
    heading: '권한',
    body:
        '카메라: OOTD 사진을 촬영하기 위해 필요합니다.\n'
        '사진 라이브러리: 레퍼런스로 사용할 사진을 불러오고 촬영 결과를 저장하기 위해 필요합니다.\n\n'
        '권한은 사용자가 시스템 설정에서 언제든 회수할 수 있습니다. 권한이 거부되어도 앱은 정상적으로 종료되며, 해당 기능만 비활성화됩니다.',
  ),
  StaticSection(
    heading: '제3자 제공',
    body: '어떤 제3자에게도 사용자 데이터를 제공하거나 판매하지 않습니다.',
  ),
  StaticSection(
    heading: '아동의 개인정보',
    body:
        'Fit-Log는 만 14세 미만 아동을 대상으로 하지 않으며, 아동의 개인정보를 의도적으로 수집하지 않습니다.',
  ),
  StaticSection(
    heading: '문의',
    body:
        '개인정보 처리방침에 대한 문의는 앱 내 도움말 화면의 안내를 통해 보내실 수 있습니다.',
  ),
  StaticSection(
    heading: '변경 이력',
    body: '이 문서는 앱 업데이트와 함께 갱신될 수 있으며, 변경 시 앱 내 공지를 통해 안내드립니다.',
  ),
];
