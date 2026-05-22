import 'dart:convert';

// Function to convert JSON string to UserModel object
UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

class UserModel {
  String? token;
  String? name;
  String? email;
  String? userId;
  String? role;
  String? phone;
  String? gender;
  String? dateOfBirth;
  String? address;
  String? profilePicture;

  UserModel({
    this.token,
    this.name,
    this.email,
    this.userId,
    this.role,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.address,
    this.profilePicture,
  });

  // Convert JSON Map to Model
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    token: json["token"],
    name: json["name"] ?? json["userName"], 
    email: json["email"],
    userId: (json["userId"] ?? json["id"])?.toString(),
    role: json["role"],
    phone: json["phone"],
    gender: json["gender"],
    dateOfBirth: json["dateOfBirth"],
    address: json["address"],
    profilePicture: json["profilePicture"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "name": name,
    "email": email,
    "userId": userId,
    "role": role,
    "phone": phone,
    "gender": gender,
    "dateOfBirth": dateOfBirth,
    "address": address,
    "profilePicture": profilePicture,
  };
}