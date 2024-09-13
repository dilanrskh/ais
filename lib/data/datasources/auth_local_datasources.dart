import 'dart:convert';

import 'package:camar_ais/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthLocalDataSource {
  Future<void> saveAuthData(AuthResponseModel authResponseModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_data', authResponseModel.toRawJson());
  }

  // ini untuk remove auth data alias logout
  Future<void> removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
  }

  // ini buat dapetin token, data, email
  Future<AuthResponseModel> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');
    if (authData != null) {
      return AuthResponseModel.fromJson(json.decode(authData));
    } else {
      throw Exception("Auth data not found");
    }
  }

  // ini buat ngecek data auth
  Future<bool> isAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');

    return authData != null;
  }
}