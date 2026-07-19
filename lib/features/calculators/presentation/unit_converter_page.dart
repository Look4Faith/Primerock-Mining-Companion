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

enum _ConversionMode { mass, concentration }

class UnitConverterPage extends ConsumerStatefulWidget {
  const UnitConverterPage({super.key});

  @override
  ConsumerState<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends ConsumerState<UnitConverterPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  _ConversionMode _mode = _ConversionMode.mass;
  String _fromUnit = 'g';
  String _toUnit = 'kg';
  String? _resultText;
  List<CalcHistoryEntry> _history = [];

  List<String> get _activeUnits =>
      _mode == _ConversionMode.mass ? kMassUnits : kGradeUnits;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadHistory());
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    setState(() {
      _history = ref
          .read(calcHistoryServiceProvider)
          .forCalculator('units')
          .take(5)
          .toList();
    });
  }

  void _onModeChanged(Set<_ConversionMode> selection) {
    if (selection.isEmpty) return;
    final mode = selection.first;
    final units = mode == _ConversionMode.mass ? kMassUnits : kGradeUnits;
    setState(() {
      _mode = mode;
      _fromUnit = units.first;
      _toUnit = units.length > 1 ? units[1] : units.first;
    });
  }

  Future<void> _calculate() async {
    if (!_formKey.currentState!.validate()) return;

    final input = Validators.parse(_valueController.text);
    late double converted;
    late String result;

    if (_mode == _ConversionMode.mass) {
      converted = MiningMath.convertMass(value: input, from: _fromUnit, to: _toUnit);
      result = '${Formatters.number(converted)} $_toUnit';
    } else {
      if (_fromUnit == _toUnit) {
        converted = input;
      } else if (_fromUnit == 'ppm' && _toUnit == '%') {
        converted = MiningMath.ppmToPercent(input);
      } else {
        converted = MiningMath.percentToPpm(input);
      }
      result = '${Formatters.number(converted)} $_toUnit';
    }

    final entry = CalcHistoryEntry(
      id: const Uuid().v4(),
      calculatorId: 'units',
      title: calculatorById('units').title,
      inputs: {
        'Mode': _mode == _ConversionMode.mass ? 'Mass' : 'Concentration',
        'Value': '${Formatters.number(input)} $_fromUnit',
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
      title: calculatorById('units').title,
      explanation:
          'Convert between mass units (g, kg, t, oz) or concentration units (ppm, %). '
          'Mass conversions use standard troy ounce (31.1035 g).',
      form: Form(
        key: _formKey,
        child: calcFormCard(
          children: [
            SegmentedButton<_ConversionMode>(
              segments: const [
                ButtonSegment(
                  value: _ConversionMode.mass,
                  label: Text('Mass'),
                  icon: Icon(Icons.scale_outlined),
                ),
                ButtonSegment(
                  value: _ConversionMode.concentration,
                  label: Text('Conc.'),
                  icon: Icon(Icons.percent_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) => _onModeChanged(selection),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.black;
                  }
                  return AppColors.textSecondary(context);
                }),
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppColors.gold;
                  }
                  return AppColors.surfaceElevated;
                }),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: calcInputDecoration('Value', hint: 'e.g. 1000'),
              validator: (v) => Validators.nonNegativeNumber(v, field: 'Value'),
            ),
            const SizedBox(height: 12),
            calcUnitDropdown(
              context: context,
              label: 'From',
              value: _fromUnit,
              units: _activeUnits,
              onChanged: (v) {
                if (v != null) setState(() => _fromUnit = v);
              },
            ),
            const SizedBox(height: 12),
            calcUnitDropdown(
              context: context,
              label: 'To',
              value: _toUnit,
              units: _activeUnits,
              onChanged: (v) {
                if (v != null) setState(() => _toUnit = v);
              },
            ),
            calcCalculateButton(onPressed: _calculate),
          ],
        ),
      ),
      result: _resultText == null
          ? null
          : ResultBanner(label: 'Converted value', value: _resultText!),
      history: calcRecentHistory(context: context, entries: _history),
    );
  }
}
