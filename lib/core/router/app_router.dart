import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/assistant/presentation/assistant_page.dart';
import '../../features/booking/presentation/booking_page.dart';
import '../../features/calculators/presentation/calculators_hub_page.dart';
import '../../features/calculators/presentation/cyanide_calculator_page.dart';
import '../../features/calculators/presentation/gold_value_calculator_page.dart';
import '../../features/calculators/presentation/moisture_calculator_page.dart';
import '../../features/calculators/presentation/ore_grade_calculator_page.dart';
import '../../features/calculators/presentation/ph_adjustment_calculator_page.dart';
import '../../features/calculators/presentation/recovery_calculator_page.dart';
import '../../features/calculators/presentation/slurry_density_calculator_page.dart';
import '../../features/calculators/presentation/unit_converter_page.dart';
import '../../features/contact/presentation/contact_page.dart';
import '../../features/gold_prices/presentation/gold_prices_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/knowledge/presentation/article_detail_page.dart';
import '../../features/knowledge/presentation/knowledge_hub_page.dart';
import '../../features/laboratory/presentation/laboratory_page.dart';
import '../../features/mining_records/presentation/record_form_page.dart';
import '../../features/news/presentation/news_detail_page.dart';
import '../../features/news/presentation/news_page.dart';
import '../../features/mining_records/presentation/records_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/settings/presentation/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/gold-prices',
        builder: (context, state) => const GoldPricesPage(),
      ),
      GoRoute(
        path: '/calculators',
        builder: (context, state) => const CalculatorsHubPage(),
        routes: [
          GoRoute(
            path: 'gold-value',
            builder: (context, state) => const GoldValueCalculatorPage(),
          ),
          GoRoute(
            path: 'recovery',
            builder: (context, state) => const RecoveryCalculatorPage(),
          ),
          GoRoute(
            path: 'ore-grade',
            builder: (context, state) => const OreGradeCalculatorPage(),
          ),
          GoRoute(
            path: 'cyanide',
            builder: (context, state) => const CyanideCalculatorPage(),
          ),
          GoRoute(
            path: 'slurry',
            builder: (context, state) => const SlurryDensityCalculatorPage(),
          ),
          GoRoute(
            path: 'ph',
            builder: (context, state) => const PhAdjustmentCalculatorPage(),
          ),
          GoRoute(
            path: 'moisture',
            builder: (context, state) => const MoistureCalculatorPage(),
          ),
          GoRoute(
            path: 'units',
            builder: (context, state) => const UnitConverterPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/knowledge',
        builder: (context, state) => const KnowledgeHubPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ArticleDetailPage(articleId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/news',
        builder: (context, state) => const NewsPage(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return NewsDetailPage(newsId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/assistant',
        builder: (context, state) => const AssistantPage(),
      ),
      GoRoute(
        path: '/records',
        builder: (context, state) => const RecordsPage(),
        routes: [
          GoRoute(
            path: 'form',
            builder: (context, state) => const RecordFormPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return RecordFormPage(recordId: id);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/laboratory',
        builder: (context, state) => const LaboratoryPage(),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const BookingPage(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
