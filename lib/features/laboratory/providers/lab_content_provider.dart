import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/lab_content.dart';
import '../../../services/providers.dart';

final labContentProvider = FutureProvider<LabContent>((ref) async {
  final service = ref.watch(laboratoryServiceProvider);
  return service.load();
});
