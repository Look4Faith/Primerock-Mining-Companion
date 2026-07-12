import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/booking_request.dart';
import '../../../services/contact_launcher.dart';
import '../../../services/providers.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/section_header.dart';

const bookingServices = [
  'Gold Assay',
  'Cyanide Testing',
  'pH Testing',
  'Moisture Analysis',
  'Particle Size',
  'Activated Carbon',
  'CIL/CIP Review',
  'General Consultation',
];

final bookingsRefreshProvider = StateProvider<int>((ref) => 0);

final bookingsListProvider = Provider<List<BookingRequest>>((ref) {
  ref.watch(bookingsRefreshProvider);
  return ref.watch(bookingServiceProvider).getAll();
});

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _notesCtrl;
  String _service = bookingServices.first;
  DateTime? _preferredDate;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  BookingRequest _buildRequest() {
    return BookingRequest(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      serviceInterest: _service,
      preferredDate: _preferredDate,
      notes: _notesCtrl.text.trim(),
    );
  }

  String _whatsappMessage(BookingRequest booking) {
    final buffer = StringBuffer('Hello Primerock Solutions,\n\n')
      ..writeln('I would like to book a consultation:')
      ..writeln()
      ..writeln('Name: ${booking.name}')
      ..writeln('Phone: ${booking.phone}')
      ..writeln('Service: ${booking.serviceInterest}');

    if (booking.preferredDate != null) {
      buffer.writeln('Preferred date: ${Formatters.date(booking.preferredDate!)}');
    }

    if (booking.notes.isNotEmpty) {
      buffer.writeln('Notes: ${booking.notes}');
    }

    return buffer.toString();
  }

  Future<void> _sendViaWhatsApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _sending = true);

    try {
      final service = ref.read(bookingServiceProvider);
      final booking = await service.save(_buildRequest());
      ref.read(bookingsRefreshProvider.notifier).state++;

      await ContactLauncher.whatsapp(
        AppConstants.contactWhatsApp,
        message: _whatsappMessage(booking),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved — opening WhatsApp…')),
        );
      }
    } on AppFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentBookings = ref.watch(bookingsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primerock Laboratory',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.goldLight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Fill in your details and send via WhatsApp. Your request is saved locally on this device.',
                      style: TextStyle(color: AppColors.white70, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone *'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _service,
                decoration: const InputDecoration(labelText: 'Service *'),
                dropdownColor: AppColors.surfaceElevated,
                items: bookingServices
                    .map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _service = v);
                },
              ),
              const SizedBox(height: 12),
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
                          const Text(
                            'Preferred date (optional)',
                            style: TextStyle(color: AppColors.white38),
                          ),
                          Text(
                            _preferredDate != null
                                ? Formatters.date(_preferredDate!)
                                : 'Tap to select',
                            style: TextStyle(
                              color: _preferredDate != null
                                  ? AppColors.goldLight
                                  : AppColors.white38,
                              fontWeight: _preferredDate != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_preferredDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.white38,
                        onPressed: () => setState(() => _preferredDate = null),
                        tooltip: 'Clear date',
                      )
                    else
                      const Icon(Icons.edit, color: AppColors.white38, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _sending ? null : _sendViaWhatsApp,
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chat),
                label: Text(_sending ? 'Sending…' : 'Send via WhatsApp'),
              ),
              const SizedBox(height: 32),
              const SectionHeader(title: 'Recent bookings'),
              const SizedBox(height: 8),
              if (recentBookings.isEmpty)
                const GlassCard(
                  child: Text(
                    'No local bookings yet. Submit a request above.',
                    style: TextStyle(color: AppColors.white70),
                  ),
                )
              else
                ...recentBookings.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  b.name,
                                  style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                Formatters.dateShort(b.createdAt),
                                style: const TextStyle(
                                  color: AppColors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.serviceInterest,
                            style: const TextStyle(color: AppColors.gold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            b.phone,
                            style: const TextStyle(color: AppColors.white70, fontSize: 13),
                          ),
                          if (b.preferredDate != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Preferred: ${Formatters.date(b.preferredDate!)}',
                              style: const TextStyle(color: AppColors.white38, fontSize: 12),
                            ),
                          ],
                          if (b.notes.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              b.notes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.white38, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
