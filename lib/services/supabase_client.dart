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

bool isSupabaseReady() {
  try {
    Supabase.instance.client;
    return true;
  } catch (_) {
    return false;
  }
}
