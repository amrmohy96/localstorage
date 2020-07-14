class Contact {
  static const tblContacts = "contacts";
  static const colId = "id";
  static const colName = "name";
  static const colMobile = "mobile";
  int id;
  String name;
  String mobile;
  Contact({this.id, this.name, this.mobile});

  //TODO: convert contact to map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colName: name, colMobile: mobile};
    if (id != null) {
      id = map[colId];
    }
    return map;
  }

  // TODO:convert from map to contact

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(id: map[colId], name: map[colName], mobile: map[colMobile]);
  }
}
