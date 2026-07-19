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

class GoldValueCalculatorPage extends ConsumerStatefulWidget {
  const GoldValueCalculatorPage({super.key});

  @override
  ConsumerState<GoldValueCalculatorPage> createState() =>
      _GoldValueCalculatorPageState();
}

class _GoldValueCalculatorPageState
    extends ConsumerState<GoldValueCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _purityController = TextEditingController();
  final _priceController = TextEditingController();

  String _weightUnit = 'g';
  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _purityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('gold-value')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = Validators.parse(_weightController.text);
    final purityPercent = Validators.parse(_purityController.text);
    final pricePerGram = Validators.parse(_priceController.text);
    final weightGrams = MiningMath.toGrams(weight, _weightUnit);
    final purityFraction = purityPercent / 100;

    final value = MiningMath.goldValue(
      weightGrams: weightGrams,
      purityFraction: purityFraction,
      pricePerGram: pricePerGram,
    );

    final result = Formatters.usd(value);
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'gold-value',
      title: calculatorById('gold-value').title,
      inputs: {
        'Weight': '${Formatters.number(weight)} $_weightUnit',
        'Purity': '${Formatters.number(purityPercent)}%',
        'Price/g': Formatters.usd(pricePerGram),
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
      title: calculatorById('gold-value').title,
      explanation:
          'Estimates melt value: weight (converted to grams) × purity fraction × price per gram. '
          'Enter purity as 0–100%.',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Weight', hint: 'e.g. 15.5'),
              validator: (v) => Validators.positiveNumber(v, field: 'Weight'),
            ),
            const SizedBox(height: 12),
            calcUnitDropdown(
              context: context,
              label: 'Weight unit',
              value: _weightUnit,
              units: kMassUnits,
              onChanged: (v) {
                if (v != null) setState(() => _weightUnit = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _purityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Purity (%)', hint: 'e.g. 91.6'),
              validator: (v) => Validators.range(v, min: 0, max: 100, field: 'Purity'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Price per gram (USD)', hint: 'e.g. 75.20'),
              validator: (v) => Validators.positiveNumber(v, field: 'Price per gram'),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Estimated gold value', value: _resultText!),
      history: calcRecentHistory(context: context, entries: _history),
    );
  }
}
