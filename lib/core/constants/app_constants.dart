/// App-wide constants. Swap [remoteDataBaseUrl] when you host free JSON updates
/// (e.g. GitHub Pages / raw.githubusercontent.com) — zero monthly cost.
class AppConstants {
  AppConstants._();

  static const String appName = 'Primerock Mining Companion';
  static const String companyName = 'Primerock Solutions';
  static const String appVersion = '1.1.0';

  /// Free GitHub raw host for offline-first refresh on Wi‑Fi/data.
  /// Falls back to bundled assets if unreachable (still $0/month).
  /// Override at build time:
  ///   flutter run --dart-define=REMOTE_DATA_URL=https://raw.githubusercontent.com/YOU/REPO/main/hosted-data
  static const String remoteDataBaseUrl = String.fromEnvironment(
    'REMOTE_DATA_URL',
    defaultValue:
        'https://raw.githubusercontent.com/Look4Faith/Primerock-Mining-Companion/main/hosted-data',
  );

  /// Official FGR pages (opened in browser — not scraped by the app).
  static const String fgrHomeUrl = 'https://fgr.co.zw/';
  static const String fgrGoldOperationsUrl =
      'https://fgr.co.zw/gold-operations/gold-buying-and-gold-refining-operations/';

  static const String goldPricesAsset = 'assets/data/gold_prices.json';
  static const String miningAnswersAsset = 'assets/data/mining_answers.json';
  static const String articlesAsset = 'assets/articles/articles.json';
  static const String labContentAsset = 'assets/data/lab_content.json';
  static const String newsAsset = 'assets/data/news.json';

  static const String remoteGoldPricesPath = '/gold_prices.json';
  static const String remoteArticlesPath = '/articles.json';
  static const String remoteAnswersPath = '/mining_answers.json';
  static const String remoteLabPath = '/lab_content.json';
  static const String remoteNewsPath = '/news.json';

  static const String logoAsset = 'assets/images/logo.png';

  static const String contactPhone = '+263771437248';
  static const String contactWhatsApp = '+263771437248';
  static const String contactEmail = 'primerocksolutions@gmail.com';
  static const String contactAddress =
      '3 Milton Road, Fairbridge Park, Mutare, Zimbabwe';
  static const String contactMapsQuery =
      '3+Milton+Road+Fairbridge+Park+Mutare';

  static const Duration remoteTimeout = Duration(seconds: 15);
}
