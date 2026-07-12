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

class OreGradeCalculatorPage extends ConsumerStatefulWidget {
  const OreGradeCalculatorPage({super.key});

  @override
  ConsumerState<OreGradeCalculatorPage> createState() =>
      _OreGradeCalculatorPageState();
}

class _OreGradeCalculatorPageState extends ConsumerState<OreGradeCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _goldController = TextEditingController();
  final _tonnesController = TextEditingController();

  String _goldUnit = 'g';
  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _goldController.dispose();
    _tonnesController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('ore-grade')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final goldInput = Validators.parse(_goldController.text);
    final goldGrams = MiningMath.toGrams(goldInput, _goldUnit);
    final tonnes = Validators.parse(_tonnesController.text);

    final grade = MiningMath.oreGradeGpt(
      goldGrams: goldGrams,
      tonnes: tonnes,
    );

    final result = '${Formatters.number(grade)} g/t';
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'ore-grade',
      title: calculatorById('ore-grade').title,
      inputs: {
        'Gold': '${Formatters.number(goldInput)} $_goldUnit',
        'Tonnes': Formatters.number(tonnes),
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
      title: calculatorById('ore-grade').title,
      explanation:
          'Ore grade in grams per tonne (g/t) = gold recovered (grams) ÷ tonnes of ore processed.',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _goldController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Gold recovered', hint: 'e.g. 125'),
              validator: (v) => Validators.positiveNumber(v, field: 'Gold recovered'),
            ),
            const SizedBox(height: 12),
            calcUnitDropdown(
              label: 'Gold unit',
              value: _goldUnit,
              units: kMassUnits,
              onChanged: (v) {
                if (v != null) setState(() => _goldUnit = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tonnesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Tonnes processed', hint: 'e.g. 500'),
              validator: (v) => Validators.positiveNumber(v, field: 'Tonnes processed'),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Ore grade', value: _resultText!),
      history: calcRecentHistory(entries: _history),
    );
  }
}
