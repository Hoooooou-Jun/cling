import 'package:cling/datasources/google_auth_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<AuthResponse> googleAuth() async {

  final authResponse = await supabaseGoogleAuth();
  return authResponse;
  
}