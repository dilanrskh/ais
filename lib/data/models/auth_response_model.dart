// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AuthResponseModel {
  final User? user;
  final String? token;
  final String? jarak;

  AuthResponseModel({
    this.user,
    this.token,
    this.jarak,
  });

  factory AuthResponseModel.fromRawJson(String str) =>
      AuthResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
        user: User.fromJson(json["user"]),
        token: json["token"] as String?,
        jarak: json["jarak"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "token": token,
        "jarak": jarak,
      };
}

class User {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? noSeri;
  final String? kapal;
  final String? jarak;
  final dynamic image;
  final dynamic createdAt;
  final dynamic updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.noSeri,
    this.kapal,
    this.jarak,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] as int?,
        name: json["name"] as String?,
        email: json["email"] as String?,
        phone: json["phone"] as String?,
        role: json["role"] as String?,
        noSeri: json["no_seri"] as String?,
        kapal: json["kapal"] as String?,
        jarak: json["jarak"] as String?,
        image: json["image"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "no_seri": noSeri,
        "kapal": kapal,
        "jarak": jarak,
        "image": image,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}