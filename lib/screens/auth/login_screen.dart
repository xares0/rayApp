import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/interaction_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const String _defaultCode = '5389';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  Timer? _timer;
  int _countdown = 0;
  bool _agreed = true;

  bool get _isCountingDown => _countdown > 0;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _countdown = 0;
        });
        return;
      }
      setState(() {
        _countdown -= 1;
      });
    });
  }

  void _handleGetCode() {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\d{11}$').hasMatch(phone)) {
      showAppToast(context, '请输入11位手机号');
      return;
    }
    if (_isCountingDown) return;

    _startCountdown();
    showAppToast(context, '验证码已发送');
  }

  Future<void> _handleLogin() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (!RegExp(r'^\d{11}$').hasMatch(phone)) {
      showAppToast(context, '请输入11位手机号');
      return;
    }
    if (code.length != 4) {
      showAppToast(context, '请输入4位验证码');
      return;
    }
    if (!_agreed) {
      showAppToast(context, '请先阅读并勾选协议');
      return;
    }
    if (code != _defaultCode) {
      showAppToast(context, '验证码错误');
      return;
    }

    await ref.read(authProvider.notifier).login('u1');
    if (!mounted) return;
    context.go('/profile_setup');
  }

  @override
  Widget build(BuildContext context) {
    final canLogin = _phoneController.text.trim().length == 11 &&
        _codeController.text.trim().length == 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),
              const Text(
                '欢迎来到photomate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '验证码登录',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 36),
              _buildPhoneInput(),
              const SizedBox(height: 14),
              _buildCodeInput(),
              const SizedBox(height: 20),
              _buildAgreementRow(context),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: canLogin ? _handleLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    disabledBackgroundColor: const Color(0xFFD9C8FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(23),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _phoneController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '请输入11位手机号',
          hintStyle: TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '请输入4位验证码',
                hintStyle: TextStyle(color: Color(0xFFB7B7B7), fontSize: 14),
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleGetCode,
            behavior: HitTestBehavior.opaque,
            child: Text(
              _isCountingDown ? '$_countdown秒后重新获取' : '获取验证码',
              style: TextStyle(
                color: _isCountingDown
                    ? const Color(0xFF9A9A9A)
                    : const Color(0xFF8B5CF6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _agreed = !_agreed;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              _agreed ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color:
                  _agreed ? const Color(0xFF8B5CF6) : const Color(0xFFBEBEBE),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                '我已阅读并同意',
                style: TextStyle(
                  color: Color(0xFF8D8D8D),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/agreement/user'),
                child: const Text(
                  '《用户协议》',
                  style: TextStyle(
                    color: Color(0xFF4D7CFF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const Text(
                '和',
                style: TextStyle(
                  color: Color(0xFF8D8D8D),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/agreement/privacy'),
                child: const Text(
                  '《隐私政策》',
                  style: TextStyle(
                    color: Color(0xFF4D7CFF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
