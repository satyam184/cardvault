class DetectorUtils {
  static bool isTitleCase(String text) {
    final words = text.split(' ');
    return words.every((word) {
      if (word.isEmpty) {
        return false;
      }
      return words[0] == word[0].toUpperCase();
    });
  }

  static bool containsCompanyKeyword(String text) {
    const keywords = [
      'PVT',
      'LTD',
      'LLP',
      'INC',
      'TECH',
      'SOLUTIONS',
      'SYSTEMS',
      'GROUP',
      'CORP',
    ];

    return keywords.any((e) => text.toUpperCase().contains(e));
  }

  static bool containsDesignation(String text) {
    const roles = [
      'ENGINEER',
      'DEVELOPER',
      'MANAGER',
      'CEO',
      'FOUNDER',
      'DIRECTOR',
      'CONSULTANT',
      'CTO',
      'COO',
      'CFO',
      'TEAM LEAD',
      'PROJECT MANAGER',
      'PRODUCT MANAGER',
      'DESIGNER',
      'GRAPHIC DESIGNER',
      'UI/UX DESIGNER',
      'MARKETING HEAD',
      'SALES EXECUTIVE',
      'BUSINESS ANALYST',
      'DATA SCIENTIST',
      'RESEARCHER',
      'TEACHER',
      'PROFESSOR',
      'DOCTOR',
      'LAWYER',
      'ACCOUNTANT',
      'HR MANAGER',
    ];

    return roles.any((e) => text.toUpperCase().contains(e));
  }

  static String? extractDomain(String? value) {
    if (value == null) return null;
    try {
      if (value.contains('@')) {
        return value.split('@').last.split('.').first.toLowerCase();
      }
      return value
          .replaceAll('https://', '')
          .replaceAll('http://', '')
          .replaceAll('www.', '')
          .split('.')
          .first
          .toLowerCase();
    } catch (e) {
      return null;
    }
  }
}
