import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey<String>('about.backButton'),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '关于我们',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 72),
            const _AppLogo(),
            const SizedBox(height: 18),
            const Text(
              key: ValueKey<String>('about.appName'),
              '越她 photomate',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 24,
                fontWeight: FontWeight.w600,
                height: 34 / 24,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              key: ValueKey<String>('about.version'),
              '版本：V1.0.2',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 20 / 14,
              ),
            ),
            const SizedBox(height: 48),
            _AboutLinksCard(
              children: [
                _AboutLinkItem(
                  key: const ValueKey<String>('about.userAgreement'),
                  title: '用户协议',
                  onTap: () => context.push('/agreement/user'),
                ),
                const _AboutDivider(),
                _AboutLinkItem(
                  key: const ValueKey<String>('about.privacyPolicy'),
                  title: '隐私政策',
                  onTap: () => context.push('/agreement/privacy'),
                ),
              ],
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: Text(
                'Copyright © 越她 photomate',
                style: TextStyle(
                  color: Color(0xFFC0C0C0),
                  fontSize: 12,
                  height: 17 / 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey<String>('about.appIcon'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          'assets/images/profile/app_logo.png',
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AboutLinksCard extends StatelessWidget {
  const _AboutLinksCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _AboutDivider extends StatelessWidget {
  const _AboutDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 16),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: Color(0xFFEDEDED),
      ),
    );
  }
}

class _AboutLinkItem extends StatelessWidget {
  const _AboutLinkItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 22 / 16,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFB8B8B8),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
