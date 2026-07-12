import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/mining_record.dart';
import '../../../services/providers.dart';
import '../../../widgets/glass_card.dart';
import '../providers/records_provider.dart';

class RecordFormPage extends ConsumerStatefulWidget {
  const RecordFormPage({super.key, this.recordId});

  final String? recordId;

  @override
  ConsumerState<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends ConsumerState<RecordFormPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late TextEditingController _productionCtrl;
  late TextEditingController _oreCtrl;
  late TextEditingController _goldCtrl;
  late TextEditingController _expensesCtrl;
  late TextEditingController _salesCtrl;
  late TextEditingController _notesCtrl;
  bool _saving = false;

  bool get _isEditing => widget.recordId != null;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
    _productionCtrl = TextEditingController();
    _oreCtrl = TextEditingController();
    _goldCtrl = TextEditingController();
    _expensesCtrl = TextEditingController();
    _salesCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  void _loadExisting(MiningRecord? existing) {
    if (existing == null || _loaded) return;
    _loaded = true;
    _date = existing.date;
    _productionCtrl.text = existing.productionQuantity.toString();
    _oreCtrl.text = existing.oreProcessed.toString();
    _goldCtrl.text = existing.goldRecovered.toString();
    _expensesCtrl.text = existing.expenses.toString();
    _salesCtrl.text = existing.sales.toString();
    _notesCtrl.text = existing.notes;
  }

  bool _loaded = false;

  @override
  void dispose() {
    _productionCtrl.dispose();
    _oreCtrl.dispose();
    _goldCtrl.dispose();
    _expensesCtrl.dispose();
    _salesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double _parse(TextEditingController c) =>
      double.tryParse(c.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  MiningRecord _buildRecord() {
    return MiningRecord(
      id: widget.recordId ?? const Uuid().v4(),
      date: _date,
      productionQuantity: _parse(_productionCtrl),
      oreProcessed: _parse(_oreCtrl),
      goldRecovered: _parse(_goldCtrl),
      expenses: _parse(_expensesCtrl),
      sales: _parse(_salesCtrl),
      notes: _notesCtrl.text.trim(),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final service = ref.read(miningRecordsServiceProvider);
    final record = _buildRecord();

    try {
      if (_isEditing) {
        await service.update(record);
      } else {
        await service.create(record);
      }
      refreshRecords(ref);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true || widget.recordId == null) return;

    await ref.read(miningRecordsServiceProvider).delete(widget.recordId!);
    refreshRecords(ref);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      final existing = ref.watch(recordByIdProvider(widget.recordId!));
      _loadExisting(existing);
      if (existing == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Record')),
          body: const Center(child: Text('Record not found')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'New Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                onTap: _pickDate,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.gold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date', style: TextStyle(color: AppColors.white38)),
                          Text(
                            Formatters.date(_date),
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit, color: AppColors.white38, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _NumberField(label: 'Production quantity', controller: _productionCtrl),
              const SizedBox(height: 12),
              _NumberField(label: 'Ore processed (tonnes)', controller: _oreCtrl),
              const SizedBox(height: 12),
              _NumberField(label: 'Gold recovered (grams)', controller: _goldCtrl),
              const SizedBox(height: 12),
              _NumberField(label: 'Expenses (USD)', controller: _expensesCtrl),
              const SizedBox(height: 12),
              _NumberField(label: 'Sales (USD)', controller: _salesCtrl),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Update Record' : 'Save Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (double.tryParse(v.trim()) == null) return 'Enter a valid number';
        return null;
      },
    );
  }
}
