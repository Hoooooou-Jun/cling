import 'package:cling/core/secure_storage.dart';
import 'package:cling/datasources/auth_data_source.dart';
import 'package:cling/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cling/repositories/google_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // 자식 클래스에서 생성자 호출 전 부모 클래스의 생성자 호출
  LoginViewModel(this._repository): super(LoginState());

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
    if(authResponse.session != null && authResponse.user != null) {

      //authResponse.user의 createAt을 이용하여 해당 사용자가 최초로그인(실질적 회원가입)인지 판단
      //만약 최초 로그인이라면 추가 정보를 입력받는 페이지로 이동, 해당 값을 토대로 user테이블 생성

      if(authResponse.user?.createdAt == null){
        state = LoginState(status: LoginStatus.error);
        return;
      }
      
      final isFirstLogin = _isFirstLogin(DateTime.parse(authResponse.user!.createdAt));

      if (isFirstLogin) {
        // 추가 정보 입력 페이지로 이동 (Navigator 사용)
        // 이때 정보를 입력 받고 돌아올 때까지 await 처리
        // final additionalInfo = await Navigator.of(context).push<AdditionalInfo>(
        //   MaterialPageRoute(builder: (context) => AdditionalInfoInputPage()),
        // );
      }

      
      state = LoginState(status: LoginStatus.success);
    }
  }

  /// 최초 로그인 판단 예시 (createdAt과 현재 시간 차이 체크)
  bool _isFirstLogin(DateTime? createdAt) {
    if (createdAt == null) return false;

    final difference = DateTime.now().difference(createdAt);
    // 예: 생성 1분 이내면 최초 로그인으로 판단
    return difference.inMinutes < 1;
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
    return LoginViewModel(repo);
  },
);
