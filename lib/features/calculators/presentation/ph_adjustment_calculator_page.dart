import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/mining_math.dart';
import '../../../core/utils/validators.dart';
import '../../../models/mining_record.dart';
import '../../../services/providers.dart';
import '../../../widgets/calculator_scaffold.dart';
import '../domain/calculator_definitions.dart';
import 'calc_page_common.dart';

class PhAdjustmentCalculatorPage extends ConsumerStatefulWidget {
  const PhAdjustmentCalculatorPage({super.key});

  @override
  ConsumerState<PhAdjustmentCalculatorPage> createState() =>
      _PhAdjustmentCalculatorPageState();
}

class _PhAdjustmentCalculatorPageState
    extends ConsumerState<PhAdjustmentCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPhController = TextEditingController(text: '10.5');
  final _targetPhController = TextEditingController(text: '10.0');
  final _volumeController = TextEditingController();
  final _strengthController = TextEditingController(text: '1.0');

  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _currentPhController.dispose();
    _targetPhController.dispose();
    _volumeController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('ph')
          .take(5)
          .toList();
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPh = Validators.parse(_currentPhController.text);
    final targetPh = Validators.parse(_targetPhController.text);
    final volume = Validators.parse(_volumeController.text);
    final strength = Validators.parse(_strengthController.text);

    if (currentPh == targetPh) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current and target pH must differ')),
      );
      return;
    }

    final litres = MiningMath.phAdjustmentVolumeLitres(
      currentPh: currentPh,
      targetPh: targetPh,
      slurryVolumeM3: volume,
      strengthFactor: strength,
    );

    final direction = targetPh > currentPh ? 'base' : 'acid';
    final result = '${Formatters.number(litres)} L $direction (est.)';
    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'ph',
      title: calculatorById('ph').title,
      inputs: {
        'Current pH': Formatters.number(currentPh),
        'Target pH': Formatters.number(targetPh),
        'Volume': '${Formatters.number(volume)} m³',
        'Strength': Formatters.number(strength),
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
      title: calculatorById('ph').title,
      explanation:
          'Simplified plant estimate: |target − current| × slurry volume (m³) × strength factor. '
          'Strength factor defaults to 1.0 — increase for stronger reagents or denser slurry, '
          'decrease for weaker solutions.',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            TextFormField(
              controller: _currentPhController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Current pH', hint: 'e.g. 10.5'),
              validator: (v) => Validators.range(v, min: 0, max: 14, field: 'Current pH'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _targetPhController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Target pH', hint: 'e.g. 10.0'),
              validator: (v) => Validators.range(v, min: 0, max: 14, field: 'Target pH'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _volumeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Slurry volume (m³)', hint: 'e.g. 25'),
              validator: (v) => Validators.positiveNumber(v, field: 'Slurry volume'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _strengthController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration(
                'Strength factor',
                hint: 'Default 1.0',
              ),
              validator: (v) => Validators.positiveNumber(v, field: 'Strength factor'),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Strength factor 1.0 = standard lab reagent strength. '
                'Adjust up/down based on your plant reagent concentration.',
                style: TextStyle(color: AppColors.white70, fontSize: 12, height: 1.35),
              ),
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Reagent volume', value: _resultText!),
      history: calcRecentHistory(entries: _history),
    );
  }
}
