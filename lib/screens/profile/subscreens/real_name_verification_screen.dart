import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/settings_provider.dart';
import '../../../widgets/interaction_utils.dart';

class RealNameVerificationScreen extends ConsumerStatefulWidget {
  const RealNameVerificationScreen({super.key});

  @override
  ConsumerState<RealNameVerificationScreen> createState() =>
      _RealNameVerificationScreenState();
}

class _RealNameVerificationScreenState
    extends ConsumerState<RealNameVerificationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final idCard = _idCardController.text.trim();
    if (name.isEmpty || idCard.isEmpty) {
      showAppToast(context, '请先填写姓名和身份证号');
      return;
    }

    ref.read(realNameAuthProvider.notifier).submit(name: name, idCard: idCard);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '实名认证',
          style: TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildInputRow(
                label: '姓名',
                hintText: '请输入姓名',
                controller: _nameController,
              ),
              const SizedBox(height: 16),
              _buildInputRow(
                label: '身份证号',
                hintText: '请输入身份证号',
                controller: _idCardController,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF88C7E8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    '认证',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow({
    required String label,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFBBBBBB),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
