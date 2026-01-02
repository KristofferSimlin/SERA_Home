import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

SupabaseClient get supabase {
  try {
    return Supabase.instance.client;
  } catch (e) {
    debugPrint('Supabase not initialized: $e');
    rethrow;
  }
}
