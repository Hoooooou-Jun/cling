import 'package:flutter/material.dart';
import 'package:cling/models/simple_user_info.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 입력 값 변수들
  String? _nickname;
  String? _address;
  // 생년월일
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;
  // 성별
  String? _gender;
  // 자전거 경력 (0 = 1년 미만, 1~19 = n년, 20=20년 이상)
  int _bikeYear = 0;

  // 각 스텝별 폼키
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final List<String> _genderOptions = ['남성', '여성'];

  // 연도, 월, 일 옵션 생성
  List<int> get _yearOptions {
    int now = DateTime.now().year;
    return List.generate(100, (i) => now - i);
  }

  List<int> get _monthOptions => List.generate(12, (i) => i + 1);

  List<int> get _dayOptions {
    return List.generate(31, (i) => i + 1);
  }

  // 성별/생년월일 에러 노출 토글 변수
  bool _birthGenderValidated = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = step;
      if (step != 2) {
        _birthGenderValidated = false; // 2가 아닌 스텝에선 에러 상태 초기화
      }
    });
  }

  void _onNext() {
    if (_currentStep == 2) {
      // 생년월일/성별 커스텀 검증
      bool valid = (_selectedYear != null &&
          _selectedMonth != null &&
          _selectedDay != null &&
          _gender != null);

      setState(() {
        _birthGenderValidated = true;
      });

      if (!valid) return; // 에러 노출 후 다음 이동 중단

      // 유효하면 폼 저장 후 다음
      if (_formKeys[_currentStep].currentState!.validate()) {
        _formKeys[_currentStep].currentState!.save();
        _birthGenderValidated = false;
        _goToStep(_currentStep + 1);
      }
    } else {
      if (_formKeys[_currentStep].currentState!.validate()) {
        _formKeys[_currentStep].currentState!.save();
        if (_currentStep < 3) {
          _goToStep(_currentStep + 1);
        }
      }
    }
  }

  void _onPrevious() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  void _onComplete() async {
    if (_formKeys[_currentStep].currentState!.validate()) {
      _formKeys[_currentStep].currentState!.save();

      DateTime? birth;
      if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) {
        try {
          birth = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
        } catch (e) {
          // 만약 날짜 조합에 문제가 있으면 로그 출력 또는 기본값 설정
          birth = null;
        }
      }

      await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('정보 제출 완료'),
          content: Text(
            '닉네임: $_nickname\n'
            '주소: $_address\n'
            '생년월일: ${birth != null ? birth.toIso8601String().split('T').first : ""}\n'
            '성별: $_gender\n'
            '자전거 경력: ${_bikeYear == 0 ? "1년 미만" : (_bikeYear == 20 ? "20년 이상" : "$_bikeYear 년")}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );

      // 다이얼로그 닫힌 뒤 RegistrationPage 자체 닫으면서 birth 전달
      Navigator.of(context).pop(SimpleUserInfo(
        nickname: _nickname ?? '',
        address: _address ?? '',
        birth: birth,
        gender: _gender,
        bikeYearLabel: _bikeYear,
      ));
    }
  }

  Widget _buildNicknameStep() {
    return Form(
      key: _formKeys[0],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('닉네임 입력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextFormField(
              initialValue: _nickname,
              decoration: InputDecoration(labelText: '닉네임'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '닉네임을 입력해주세요';
                if (v.length < 2) return '닉네임은 최소 2자 이상';
                return null;
              },
              onSaved: (v) => _nickname = v!.trim(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Form(
      key: _formKeys[1],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('주소 입력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            TextFormField(
              initialValue: _address,
              decoration: InputDecoration(labelText: '주소'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return '주소를 입력해주세요';
                return null;
              },
              onSaved: (v) => _address = v!.trim(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthGenderStep() {
    return Form(
      key: _formKeys[2],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('생년월일 및 성별', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    items: _yearOptions
                        .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedYear = v),
                    decoration: InputDecoration(labelText: "년"),
                    validator: (v) => v == null ? '필수 입력' : null,
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: DropdownButtonFormField<int>(
                    value: _selectedMonth,
                    items: _monthOptions
                        .map((m) => DropdownMenuItem(value: m, child: Text('${m.toString().padLeft(2, '0')}')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedMonth = v),
                    decoration: InputDecoration(labelText: "월"),
                    validator: (v) => v == null ? '필수 입력' : null,
                  ),
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: DropdownButtonFormField<int>(
                    value: _selectedDay,
                    items: _dayOptions
                        .map((d) => DropdownMenuItem(value: d, child: Text('${d.toString().padLeft(2, '0')}')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedDay = v),
                    decoration: InputDecoration(labelText: "일"),
                    validator: (v) => v == null ? '필수 입력' : null,
                  ),
                ),
              ],
            ),
            SizedBox(height: 34),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _genderOptions.map((g) {
                final selected = _gender == g;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(g),
                    selected: selected,
                    onSelected: (_) => setState(() => _gender = g),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 8),
            Builder(
              builder: (_) {
                if (!_birthGenderValidated) return SizedBox.shrink();

                String? err;
                if ((_selectedYear == null || _selectedMonth == null || _selectedDay == null))
                  err = "생년월일을 모두 선택해주세요";
                else if (_gender == null)
                  err = "성별을 선택해주세요";
                else
                  err = null;

                return err != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(err, style: TextStyle(color: Colors.red)),
                      )
                    : SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBikeExpSliderStep() {
    return Form(
      key: _formKeys[3],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('자전거 경력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),
            Row(
              children: [
                Text('1년 미만', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Slider(
                    value: _bikeYear.toDouble(),
                    onChanged: (v) => setState(() => _bikeYear = v.round()),
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: _bikeYear == 20
                        ? '20년 이상'
                        : (_bikeYear == 0 ? "1년 미만" : '${_bikeYear}년'),
                  ),
                ),
                Text('20년 이상', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 10),
            Text(
              _bikeYear == 20 ? "20년 이상"
                  : _bikeYear == 0 ? "1년 미만"
                  : "${_bikeYear}년",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final selected = _currentStep == index;
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 6),
          width: selected ? 16 : 12,
          height: selected ? 16 : 12,
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[400],
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0)
          ElevatedButton(
            onPressed: _onPrevious,
            child: Text('이전'),
          )
        else
          SizedBox(width: 80), // 자리맞춤
        ElevatedButton(
          onPressed: _currentStep == 3 ? _onComplete : _onNext,
          child: Text(_currentStep == 3 ? '완료' : '다음'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입 추가정보 입력'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: BouncingScrollPhysics(),
                onPageChanged: (step) {
                  setState(() {
                    _currentStep = step;
                    if (step != 2) {
                      _birthGenderValidated = false;
                    }
                  });
                },
                children: [
                  _buildNicknameStep(),
                  _buildAddressStep(),
                  _buildBirthGenderStep(),
                  _buildBikeExpSliderStep(),
                ],
              ),
            ),
            _buildPageIndicator(),
            SizedBox(height: 12),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }
}
