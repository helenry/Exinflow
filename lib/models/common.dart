class Category {
  String _id;
  int? _subId;
  
  Category({
    required String id,
    required int? subId,
  }) : _id = id,
  _subId = subId;

  String get id => _id;
  int? get subId => _subId;
}