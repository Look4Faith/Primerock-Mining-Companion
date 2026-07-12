import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/mining_record.dart';
import '../../../widgets/glass_card.dart';

Widget calcFormCard({required List<Widget> children}) {
  return GlassCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

Widget calcCalculateButton({required VoidCallback onPressed}) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.calculate_outlined),
      label: const Text('Calculate'),
    ),
  );
}

InputDecoration calcInputDecoration(String label, {String? hint}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
  );
}

Widget calcUnitDropdown({
  required String label,
  required String value,
  required List<String> units,
  required ValueChanged<String?> onChanged,
}) {
  return DropdownButtonFormField<String>(
    key: ValueKey('$label-$value'),
    initialValue: value,
    decoration: calcInputDecoration(label),
    dropdownColor: AppColors.surfaceElevated,
    items: units
        .map(
          (u) => DropdownMenuItem(
            value: u,
            child: Text(u, style: const TextStyle(color: AppColors.white)),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
}

Widget calcRecentHistory({
  required List<CalcHistoryEntry> entries,
}) {
  if (entries.isEmpty) {
    return GlassCard(
      child: Text(
        'No calculations yet. Run your first calculation above.',
        style: TextStyle(color: AppColors.white70.withValues(alpha: 0.9)),
      ),
    );
  }

  return Column(
    children: entries.map((entry) {
      final inputSummary = entry.inputs.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(' · ');
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.result,
                      style: const TextStyle(
                        color: AppColors.goldLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.dateShort(entry.timestamp),
                    style: const TextStyle(
                      color: AppColors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              if (inputSummary.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  inputSummary,
                  style: const TextStyle(color: AppColors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      );
    }).toList(),
  );
}
