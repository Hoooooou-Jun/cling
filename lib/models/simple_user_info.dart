class SimpleUserInfo {
  final String nickname;
  final String address;
  final DateTime? birth;
  final String? gender;
  final int? bikeYearLabel;

  SimpleUserInfo({
    required this.nickname,
    required this.address,
    this.birth,
    this.gender,
    this.bikeYearLabel,
  });
}