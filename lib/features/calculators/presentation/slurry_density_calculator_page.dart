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

class SlurryDensityCalculatorPage extends ConsumerStatefulWidget {
  const SlurryDensityCalculatorPage({super.key});

  @override
  ConsumerState<SlurryDensityCalculatorPage> createState() =>
      _SlurryDensityCalculatorPageState();
}

class _SlurryDensityCalculatorPageState
    extends ConsumerState<SlurryDensityCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _dryMassController = TextEditingController();
  final _totalMassController = TextEditingController();

  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _dryMassController.dispose();
    _totalMassController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('slurry')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final dryMass = Validators.parse(_dryMassController.text);
    final totalMass = Validators.parse(_totalMassController.text);

    if (dryMass > totalMass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dry mass cannot exceed total slurry mass')),
      );
      return;
    }

    final percentSolids = MiningMath.slurryPercentSolids(
      dryMass: dryMass,
      totalMass: totalMass,
    );

    final result = Formatters.percent(percentSolids);
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'slurry',
      title: calculatorById('slurry').title,
      inputs: {
        'Dry mass': Formatters.number(dryMass),
        'Total mass': Formatters.number(totalMass),
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
      title: calculatorById('slurry').title,
      explanation:
          'Slurry % solids = dry mass ÷ total slurry mass × 100. '
          'Use consistent mass units (kg recommended).',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _dryMassController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Dry mass', hint: 'e.g. 450'),
              validator: (v) => Validators.positiveNumber(v, field: 'Dry mass'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _totalMassController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Total slurry mass', hint: 'e.g. 1200'),
              validator: (v) => Validators.positiveNumber(v, field: 'Total mass'),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Percent solids', value: _resultText!),
      history: calcRecentHistory(context: context, entries: _history),
    );
  }
}
