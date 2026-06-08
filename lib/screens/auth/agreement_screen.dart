import 'package:flutter/material.dart';

import '../../core/constants/agreement_texts.dart';

class AgreementScreen extends StatelessWidget {
  final String type;

  const AgreementScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = type == 'privacy';
    final title = isPrivacy ? '隐私政策' : '用户协议';
    final content = isPrivacy ? privacyAgreementText : userAgreementText;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SelectableText(
            content,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}
