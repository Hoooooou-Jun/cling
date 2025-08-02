import 'package:cling/widgets/google_login_button.dart';
import 'package:flutter/material.dart';
import 'package:cling/core/color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_view_model.dart';
import 'package:cling/presentation/login/register_view.dart';
import 'package:cling/models/simple_user_info.dart';
class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _autoLogin = false;

  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  late LoginViewModel viewModel;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration:  const Duration(seconds: 2)
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    viewModel = ref.read(loginViewModelProvider.notifier);

    viewModel.onRequestNavigateRegist = () async {
      final result = await Navigator.of(context).push<SimpleUserInfo>(
        MaterialPageRoute(builder: (context) => RegistrationPage()),
      );

      viewModel.updateSimpleUserInfo(result);
    };

  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);

    ref.listen<LoginState>(loginViewModelProvider, (prev, next) {
      if (next.status == LoginStatus.success) {
        Navigator.pushReplacementNamed(context, '/main');
      } else if (next.status == LoginStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message ?? '로그인 실패')),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            bgTopColor,
            bgBottomColor
          ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          )
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    "assets/images/main_icon_typhography.png",
                    width: 360,
                    height: 360,
                  ),
                ),
                
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idCtrl,
                  style: TextStyle(color: text900Color),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '아이디',
                    hintStyle: TextStyle(color: text600Color),
                    prefixIcon: Icon(Icons.person, color: secondaryColor),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide:
                      BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                  ),
                  validator: (v) => v!.isNotEmpty ? null : '아이디를 입력하세요',
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: TextStyle(color: text900Color),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '비밀번호',
                    hintStyle: TextStyle(color: text600Color),
                    prefixIcon: Icon(Icons.lock, color: secondaryColor),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide:
                      BorderSide(color: secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide(color: secondaryColor),
                    ),
                  ),
                  validator: (v) =>
                  (v?.length ?? 0) >= 6 ? null : '6자 이상 입력하세요',
                ),

                const SizedBox(height: 16),
                state.status == LoginStatus.loading
                    ? CircularProgressIndicator(color: secondaryColor)
                    : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ref
                            .read(loginViewModelProvider.notifier)
                            .login(_idCtrl.text, _passwordCtrl.text, _autoLogin);
                      }
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(fontSize: 18, color: text200Color),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                GoogleLoginButton(onPressed: () => ref.read(loginViewModelProvider.notifier).googleLogin())

              ],
            )
          )
        )
      )
    );

  }
}
