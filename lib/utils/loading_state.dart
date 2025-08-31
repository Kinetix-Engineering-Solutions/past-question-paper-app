import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage global loading state
final loadingStateProvider = StateProvider<bool>((ref) => false);
