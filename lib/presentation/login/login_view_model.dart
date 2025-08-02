import 'package:cling/core/secure_storage.dart';
import 'package:cling/datasources/auth_data_source.dart';
import 'package:cling/datasources/supabase_user_data_source.dart';
import 'package:cling/repositories/auth_repository.dart';
import 'package:cling/repositories/supabase_user_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cling/repositories/google_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cling/models/simple_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 로그인 상태값 enum(로그인 성공 여부를 따지기 위함으로, 필요할 경우에만 선언)
enum LoginStatus { initial, loading, success, error }

// 로그인 상태 관리 요소 클래스
class LoginState {
  final LoginStatus status;
  final String? message;
  LoginState({this.status = LoginStatus.initial, this.message});
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AuthRepository _repository;
  final SupabaseUserRepository _supabaseUserRepository;

  SimpleUserInfo? userInfo;
  AsyncCallback? onRequestNavigateRegist;

  // 자식 클래스에서 생성자 호출 전 부모 클래스의 생성자 호출
  LoginViewModel(this._repository, this._supabaseUserRepository): super(LoginState());

  Future<void> login(String id, String password, bool autoLogin) async {
    // 로그인 상태 값
    state = LoginState(status: LoginStatus.loading);
    try {
      final response = await _repository.login(
        userId: id,
        password: password,
        autoLogin: autoLogin,
      );

      await SecureStorage.write(key: 'access-token', value: response.accessToken);
      if (autoLogin) await SecureStorage.write(key: 'refresh-token', value: response.refreshToken!);

      // 성공했으므로 로그인 전역변수를 성공으로 변경.
      state = LoginState(status: LoginStatus.success);
    } catch (error) {
      // 실패 결과를 로그인 전역변수에 저장
      state = LoginState(
        status: LoginStatus.error,
        message: error.toString(),
      );
    }
  }

  Future<void> googleLogin() async {
    /* 구글 로그인 핸들러 */
    final authResponse = await googleAuth();

    if(authResponse.session == null) {
      state = LoginState(status: LoginStatus.error);
      return;
    }
    if(authResponse.user == null) {
      state = LoginState(status: LoginStatus.error);
      return;
    }

    final bool userCheck = await _supabaseUserRepository.checkUserExist(authResponse.user?.id);

    if(userCheck) {
      state = LoginState(status: LoginStatus.success);
      return;
    }

    await requestNavigateRegist();
    if(userInfo == null) {
      state = LoginState(status: LoginStatus.error);
      return;
    } else {
      final result = await _supabaseUserRepository.registUser(authResponse.user?.id, userInfo!);

      state = result ? LoginState(status: LoginStatus.success) : LoginState(status: LoginStatus.error);
    }


  }

  Future<void> requestNavigateRegist() async {
    if (onRequestNavigateRegist != null) {
      await onRequestNavigateRegist!();
    }
  }

  void updateSimpleUserInfo(SimpleUserInfo? info) {
    userInfo = info;
  }

}

// DataSource 프로바이더
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSourceImpl();
});

// Repository 프로바이더
// 단일 책임 원칙을 따르므로, AuthDataSource는 API 호출 -> Model 변환만을 담당.
// AuthRepository는 AuthDataSource를 사용해 데이터를 뷰모델에 전달.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.read(authDataSourceProvider);
  return AuthRepository(dataSource: dataSource);
});

// ViewModel 프로바이더
// ViewModel에 authRepository를 주입.
final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
  (ref) {
    final repo = ref.read(authRepositoryProvider);
    final supabaseUserRepository = ref.read(supabaseUserRepositoryProvider);
    return LoginViewModel(repo, supabaseUserRepository);
  },
);



final supabaseUserDataSourceProvider = Provider<SupabaseUserDataSource>((ref) {
  return SupabaseUserDataSourceImpl();
});

final supabaseUserRepositoryProvider = Provider<SupabaseUserRepository>((ref) {
  final datasource = ref.read(supabaseUserDataSourceProvider);
  return SupabaseUserRepositoryImpl(datasource);
});
