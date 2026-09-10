class UserModel {
  final Map<String, dynamic> data;

  UserModel({
    required this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(data: json);
  }
}