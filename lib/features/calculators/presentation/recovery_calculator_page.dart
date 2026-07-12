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

class RecoveryCalculatorPage extends ConsumerStatefulWidget {
  const RecoveryCalculatorPage({super.key});

  @override
  ConsumerState<RecoveryCalculatorPage> createState() =>
      _RecoveryCalculatorPageState();
}

class _RecoveryCalculatorPageState extends ConsumerState<RecoveryCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _feedController = TextEditingController();
  final _tailController = TextEditingController();

  String _gradeUnit = 'ppm';
  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _feedController.dispose();
    _tailController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('recovery')
          .take(5)
          .toList();
    });
  }

  double _toBaseGrade(double value, String unit) {
    return unit == '%' ? MiningMath.percentToPpm(value) : value;
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final feed = _toBaseGrade(Validators.parse(_feedController.text), _gradeUnit);
    final tail = _toBaseGrade(Validators.parse(_tailController.text), _gradeUnit);

    if (tail > feed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tail grade cannot exceed feed grade')),
      );
      return;
    }

    final recovery = MiningMath.recoveryPercent(
      feedGrade: feed,
      tailGrade: tail,
    );

    final result = Formatters.percent(recovery);
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'recovery',
      title: calculatorById('recovery').title,
      inputs: {
        'Feed': '${_feedController.text.trim()} $_gradeUnit',
        'Tail': '${_tailController.text.trim()} $_gradeUnit',
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
      title: calculatorById('recovery').title,
      explanation:
          'Recovery % = (feed grade − tail grade) ÷ feed grade × 100. '
          'Use the same unit for feed and tail (ppm or %).',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _feedController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Feed grade', hint: 'e.g. 3.5'),
              validator: (v) => Validators.positiveNumber(v, field: 'Feed grade'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tailController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Tail grade', hint: 'e.g. 0.4'),
              validator: (v) => Validators.nonNegativeNumber(v, field: 'Tail grade'),
            ),
            const SizedBox(height: 12),
            calcUnitDropdown(
              label: 'Grade unit',
              value: _gradeUnit,
              units: kGradeUnits,
              onChanged: (v) {
                if (v != null) setState(() => _gradeUnit = v);
              },
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Metal recovery', value: _resultText!),
      history: calcRecentHistory(entries: _history),
    );
  }
}
