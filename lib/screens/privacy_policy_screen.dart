import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              '개인정보 처리방침',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. 수집 목적',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '- 사용자 운동 기록 분석 및 맞춤형 운동 추천 제공.\n'
                  '- 자세 교정을 위한 AI 분석.\n'
                  '- 사용자 맞춤형 식단 제안.\n'
                  '- 알림 설정 및 개인화된 경험 제공.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '2. 수집 데이터',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '- 이름, 이메일, 키, 몸무게.\n'
                  '- 운동 기록 및 AI 분석 데이터.\n'
                  '- 앱 사용 환경(설정, 알림 상태 등).\n'
                  '- IP 주소 및 기기 정보.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '3. 데이터 보관 및 삭제',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '- 수집된 데이터는 암호화된 상태로 안전하게 보관됩니다.\n'
                  '- 데이터는 서비스 제공 목적이 달성된 후 삭제됩니다.\n'
                  '- 사용자는 언제든지 \'설정 -> 데이터 삭제 요청\'을 통해 데이터를 삭제할 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '4. 제3자 제공',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '- 사용자의 개인정보는 제3자에게 제공되지 않습니다.\n'
                  '- 단, 법적 요구 사항에 따라 필요한 경우 제한적으로 제공될 수 있습니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '5. 사용자 권리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '- 사용자는 자신의 개인정보 열람, 수정, 삭제를 요청할 수 있습니다.\n'
                  '- 개인정보 처리에 대한 동의를 철회할 권리가 있습니다.\n'
                  '- 문의 사항은 아래 연락처로 접수 가능합니다.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              '6. 문의처',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '개인정보와 관련된 문의는 아래로 연락 주세요.\n'
                  '이메일: itowe4321@gmail.com\n',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
