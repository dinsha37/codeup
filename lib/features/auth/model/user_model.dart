// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    CreatedAt? createdAt;
    String? uid;
    String? password;
    String? name;
    String? email;
    int? status;

    UserModel({
        this.createdAt,
        this.uid,
        this.password,
        this.name,
        this.email,
        this.status,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
       
        uid: json["uid"],
        password: json["password"],
        name: json["name"],
        email: json["email"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toJson(),
        "uid": uid,
        "password": password,
        "name": name,
        "email": email,
        "status": status,
    };
}

class CreatedAt {
    int? seconds;
    int? nanoseconds;

    CreatedAt({
        this.seconds,
        this.nanoseconds,
    });

    factory CreatedAt.fromJson(Map<String, dynamic> json) => CreatedAt(
        seconds: json["seconds"],
        nanoseconds: json["nanoseconds"],
    );

    Map<String, dynamic> toJson() => {
        "seconds": seconds,
        "nanoseconds": nanoseconds,
    };
}
