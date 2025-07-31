import 'package:cling/core/supabase_initialize.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<AuthResponse> supabaseGoogleAuth() async {


  /// TODO: update the Web client ID with your own.
  ///
  /// Web Client ID that you registered with Google Cloud.
  final webClientId = dotenv.get('SUPABASE_WEB_CLIENT_ID');

  /// TODO: update the iOS client ID with your own.
  ///
  /// iOS Client ID that you registered with Google Cloud.
  final iosClientId = dotenv.get('SUPABASE_IOS_CLIENT_ID');

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  await googleSignIn.initialize(
    clientId: iosClientId,
    serverClientId: webClientId,
  );

  final googleUser = await googleSignIn.authenticate();
  final googleAuth = await googleUser!.authentication;

  const scopes = <String>[
    'email',
    'profile',
    // 필요한 OAuth scope를 여기에 추가
  ];

  // 사용자에게 권한 요청 (권한 없으면 로그인 UI가 뜸)
  final GoogleSignInClientAuthorization? authorization =
      await googleUser.authorizationClient.authorizeScopes(scopes);

  if (authorization == null) {
    // 권한 요청 실패 또는 사용자 거부
    final nullResponse = null;
    return nullResponse;
  }

  final accessToken = authorization.accessToken;  
  final idToken = googleAuth.idToken;

  if (accessToken == null) {
    throw 'No Access Token found.';
  }
  if (idToken == null) {
    throw 'No ID Token found.';
  }

  final authResponse = await supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );



  // print('Access Token: $accessToken');
  // print('Id Token: $idToken');

  // print('Session: ${authResponse.session}');
  // print('User: ${authResponse.user}');

  // print('access token: ${authResponse.session?.accessToken}');
  return authResponse;




}