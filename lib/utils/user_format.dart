// 用户信息展示相关的格式化工具（第四次迭代「用户信息字段显示」）。
// 统一规则：字段为 null / 空 时返回 null，由调用方决定「不显示」。

/// 根据生日字符串估算年龄（mock 容错，默认 25，区间 18~80）。
int ageFromBirthday(String? birthday) {
  if (birthday == null || birthday.isEmpty) return 25;
  final parsed = DateTime.tryParse(birthday);
  if (parsed == null) return 25;
  final now = DateTime.now();
  int age = now.year - parsed.year;
  final hasHadBirthday = now.month > parsed.month ||
      (now.month == parsed.month && now.day >= parsed.day);
  if (!hasHadBirthday) age -= 1;
  return age.clamp(18, 80);
}

/// 身高展示文本，如 176 → "176cm"；null 返回 null（不显示）。
String? formatHeight(int? heightCm) =>
    (heightCm == null || heightCm <= 0) ? null : '${heightCm}cm';

/// 体重展示文本，如 60 → "60kg"；null 返回 null（不显示）。
String? formatWeight(int? weightKg) =>
    (weightKg == null || weightKg <= 0) ? null : '${weightKg}kg';

/// 国籍国旗 emoji（mock：按中文国名映射常见几个，未命中返回 null）。
String? nationalityFlag(String? nationality) {
  if (nationality == null || nationality.trim().isEmpty) return null;
  const flags = <String, String>{
    '中国': '🇨🇳',
    '越南': '🇻🇳',
    '泰国': '🇹🇭',
    '韩国': '🇰🇷',
    '日本': '🇯🇵',
    '美国': '🇺🇸',
    '马来西亚': '🇲🇾',
    '菲律宾': '🇵🇭',
  };
  return flags[nationality.trim()];
}
