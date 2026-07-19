import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/mining_math.dart';
import '../../../core/utils/validators.dart';
import '../../../models/mining_record.dart';
import '../../../services/providers.dart';
import '../../../widgets/calculator_scaffold.dart';
import '../domain/calculator_definitions.dart';
import 'calc_page_common.dart';

class CyanideCalculatorPage extends ConsumerStatefulWidget {
  const CyanideCalculatorPage({super.key});

  @override
  ConsumerState<CyanideCalculatorPage> createState() =>
      _CyanideCalculatorPageState();
}

class _CyanideCalculatorPageState extends ConsumerState<CyanideCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _targetPpmController = TextEditingController();
  final _moistureController = TextEditingController();

  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _targetPpmController.dispose();
    _moistureController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('cyanide')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final targetPpm = Validators.parse(_targetPpmController.text);
    final moisturePercent = Validators.parse(_moistureController.text);
    final moistureFraction = moisturePercent / 100;

    final dosage = MiningMath.cyanideDosageKgPerTonne(
      targetPpm: targetPpm,
      moistureFraction: moistureFraction,
    );

    final result = '${Formatters.number(dosage)} kg NaCN / t ore';
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'cyanide',
      title: calculatorById('cyanide').title,
      inputs: {
        'Target': '${Formatters.number(targetPpm)} ppm',
        'Moisture': '${Formatters.number(moisturePercent)}%',
      },
      result: result,
      timestamp: DateTime.now(),
    );

    await ref.read(calcHistoryServiceProvider).add(entry);

    setState(() => _resultText = result);
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: calculatorById('cyanide').title,
      explanation:
          'Approximate sodium cyanide dosage (kg/t ore) from target solution concentration (ppm) '
          'and ore moisture content. Higher moisture increases solution volume factor.',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _targetPpmController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Target concentration (ppm)', hint: 'e.g. 500'),
              validator: (v) => Validators.positiveNumber(v, field: 'Target ppm'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _moistureController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Ore moisture (%)', hint: 'e.g. 8'),
              validator: (v) => Validators.range(v, min: 0, max: 100, field: 'Moisture'),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Cyanide dosage', value: _resultText!),
      history: calcRecentHistory(context: context, entries: _history),
    );
  }
}
