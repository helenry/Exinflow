class UserModel {
  String _uid;
  String _email;
  String _fullName;
  String _mainCurrency;

  UserModel({
    required String uid,
    required String email,
    required String fullName,
    required String mainCurrency
  }) : _uid = uid,
  _email = email,
  _fullName = fullName,
  _mainCurrency = mainCurrency;

  String get uid => _uid;
  String get email => _email;
  String get fullName => _fullName;
  String get mainCurrency => _mainCurrency;

  void setMainCurrency(String newCurrency) {
    _mainCurrency = newCurrency;
  }

  void setFullName(String newName) {
    _fullName = newName;
  }
}