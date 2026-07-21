import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 用户协议 / 隐私政策腾讯文档地址
const String _userAgreementUrl = 'https://docs.qq.com/doc/DYlNaV0FacVFhU3dT';
const String _privacyAgreementUrl = 'https://docs.qq.com/doc/DYmtzTm5WQ2JnaHd3';

class AgreementScreen extends StatefulWidget {
  final String type;

  const AgreementScreen({super.key, required this.type});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  late final WebViewController _controller;
  int _progress = 0;

  bool get _isPrivacy => widget.type == 'privacy';

  @override
  void initState() {
    super.initState();
    final url = _isPrivacy ? _privacyAgreementUrl : _userAgreementUrl;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    final title = _isPrivacy ? '隐私政策' : '用户协议';

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
        child: Column(
          children: [
            if (_progress < 100)
              LinearProgressIndicator(
                value: _progress / 100,
                minHeight: 2,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
