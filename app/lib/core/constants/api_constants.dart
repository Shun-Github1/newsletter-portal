import 'package:flutter/foundation.dart';

enum Sector {
  politicsGovernment(1, 'Politics & Government', true),
  businessEconomy(2, 'Business & Economy', true),
  conflictMilitary(3, 'Conflict / Military', true),
  crimeJustice(4, 'Crime & Justice', true),
  technology(5, 'Technology', true),
  environmentClimate(6, 'Environment & Climate', true),
  weather(7, 'Weather', true),
  realEstate(8, 'Real Estate', true),
  science(9, 'Science', false),
  healthMedicine(10, 'Health & Medicine', false),
  education(11, 'Education', false),
  sports(12, 'Sports', false),
  artsEntertainment(13, 'Arts & Entertainment', false),
  lifestyleCulture(14, 'Lifestyle & Culture', false),
  religionEthics(15, 'Religion & Ethics', false),
  opinionCommentary(16, 'Opinion & Commentary', false);

  final int id;
  final String displayName;
  final bool isHard;

  const Sector(this.id, this.displayName, this.isHard);
}

enum AppRegion {
  hk('hk', 'Hong Kong SAR'),
  china('china', 'Mainland China'),
  uk('uk', 'United Kingdom'),
  us('usa', 'United States'),
  asiaOther('asia-others', 'Asia (others)'),
  europeOther('europe-others', 'Europe (others)');

  final String tag;
  final String displayName;

  const AppRegion(this.tag, this.displayName);
}

enum AppLanguage {
  en('en-UK'),
  zhHK('zh-HK'),
  zhCN('zh-CN');

  final String code;

  const AppLanguage(this.code);
}

enum SummaryMode {
  pointForm,
  paragraph
}

enum FeedSortBy {
  latest,
  popular,
  relevant
}

class ApiConstants {
  static const String productionBaseUrl = 'https://api.zonenews.io/dev/';

  /// Local proxy for Flutter web dev (see tool/dev_api_proxy.py).
  /// Host must match the page origin (`localhost` vs `127.0.0.1`) or
  /// browsers treat cookies as cross-site and login fails after success.
  static String get webDevProxyBaseUrl {
    final host = Uri.base.host;
    final proxyHost = (host == '127.0.0.1' || host == 'localhost') ? host : 'localhost';
    return 'http://$proxyHost:8081/';
  }

  static String get baseUrl {
    if (kIsWeb && kDebugMode) {
      return webDevProxyBaseUrl;
    }
    return productionBaseUrl;
  }
}
