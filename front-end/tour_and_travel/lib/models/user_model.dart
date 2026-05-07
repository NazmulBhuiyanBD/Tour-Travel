import 'dart:convert';

// Function to convert JSON string to UserModel object
UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  String? token;
  String? name;
  String? email;
  String? userId;

  String? role;

  UserModel({this.token, this.name, this.email, this.userId, this.role});

  // Convert JSON Map to Model
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    token: json["token"],
    name: json["name"] ?? json["userName"], 
    email: json["email"],
    userId: json["userId"],
    role: json["role"],
  );
  Map<String, dynamic> toJson() => {
    "token": token,
    "name": name,
    "email": email,
    "userId": userId,
    "role": role,
  };
}