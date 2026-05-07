import 'package:flutter/widgets.dart';

import 'static_page_shell.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticPageShell(
      eyebrow: 'TERMS OF SERVICE',
      title: '이용약관',
      sections: _sections,
    );
  }
}

const _sections = <StaticSection>[
  StaticSection(
    heading: '제1조 목적',
    body:
        '본 약관은 Fit-Log(이하 "앱")의 이용 조건과 절차, 이용자와 개발자의 권리와 의무를 규정함을 목적으로 합니다.',
  ),
  StaticSection(
    heading: '제2조 서비스 내용',
    body:
        '앱은 사용자가 매일의 옷차림을 같은 포즈로 기록하도록 돕는 카메라 도구를 제공합니다. 사진은 사용자의 기기에 저장되며 외부 서버로 전송되지 않습니다.',
  ),
  StaticSection(
    heading: '제3조 이용 자격',
    body:
        '앱은 만 14세 이상의 이용자를 대상으로 합니다. 미성년자는 보호자의 동의 하에 이용해 주세요.',
  ),
  StaticSection(
    heading: '제4조 이용자의 책임',
    body:
        '이용자는 자신이 촬영한 사진과 그 사용에 대한 책임을 집니다. 타인의 초상권, 저작권을 침해하는 사용은 금지됩니다.',
  ),
  StaticSection(
    heading: '제5조 면책',
    body:
        '앱은 현재 상태로 제공되며, 기기의 문제, OS 업데이트, 저장소 부족 등으로 인한 사진 손실에 대해 책임을 지지 않습니다. 중요한 사진은 별도로 백업해 주세요.',
  ),
  StaticSection(
    heading: '제6조 약관의 변경',
    body:
        '본 약관은 앱 업데이트와 함께 변경될 수 있습니다. 변경 사항은 앱 내 공지를 통해 안내합니다.',
  ),
  StaticSection(
    heading: '제7조 준거법',
    body: '본 약관은 대한민국 법률을 따릅니다.',
  ),
];
