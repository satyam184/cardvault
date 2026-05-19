class ConfidenceCalculator {
  static double calculate(Map<String, dynamic> data) {
    double score = 0;
    if (data['name'] != null) {
      score += 30;
    }
    if (data['company'] != null) {
      score += 30;
    }
    if (data['email'] != null) {
      score += 10;
    }

    if (data['phone'] != null) {
      score += 10;
    }

    if (data['jobTitle'] != null) {
      score += 5;
    }

    if (data['website'] != null) {
      score += 5;
    }

    if (data['linkedin'] != null) {
      score += 5;
    }

    if (data['address'] != null) {
      score += 5;
    }
    return score;
  }
}
