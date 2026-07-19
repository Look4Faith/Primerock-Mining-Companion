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

class MoistureCalculatorPage extends ConsumerStatefulWidget {
  const MoistureCalculatorPage({super.key});

  @override
  ConsumerState<MoistureCalculatorPage> createState() =>
      _MoistureCalculatorPageState();
}

class _MoistureCalculatorPageState extends ConsumerState<MoistureCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _wetWeightController = TextEditingController();
  final _moistureController = TextEditingController();

  String _weightUnit = 'kg';
  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _wetWeightController.dispose();
    _moistureController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('moisture')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final wetWeight = Validators.parse(_wetWeightController.text);
    final moisturePercent = Validators.parse(_moistureController.text);

    final dry = MiningMath.dryWeight(
      wetWeight: wetWeight,
      moisturePercent: moisturePercent,
    );

    final result = '${Formatters.number(dry)} $_weightUnit (dry)';
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'moisture',
      title: calculatorById('moisture').title,
      inputs: {
        'Wet weight': '${Formatters.number(wetWeight)} $_weightUnit',
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
      title: calculatorById('moisture').title,
      explanation:
          'Corrects sample weight for moisture: dry weight = wet weight × (1 − moisture% ÷ 100).',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _wetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Wet weight', hint: 'e.g. 1050'),
              validator: (v) => Validators.positiveNumber(v, field: 'Wet weight'),
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
              controller: _moistureController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Moisture content (%)', hint: 'e.g. 12'),
              validator: (v) => Validators.range(v, min: 0, max: 100, field: 'Moisture'),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Dry weight', value: _resultText!),
      history: calcRecentHistory(context: context, entries: _history),
    );
  }
}
