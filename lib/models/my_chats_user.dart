class MyChatsUser{
  String firebaseId;
  String phoneNumber;
  String fullName;
  String about;
  List<Map> contactInfo;
  String? profilePicUrl;
  List<String>? groups;

  MyChatsUser({
    required this.firebaseId,
    required this.phoneNumber,
    required this.fullName,
    required this.contactInfo,
    this.profilePicUrl,
    this.groups,
    required this.about
  });
}