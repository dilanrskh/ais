import 'dart:convert';
import 'package:camar_ais/data/models/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDatasource {
  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> saveAuthData(AuthResponseModel data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('auth_data', data.toRawJson());
    } catch (e) {
      throw Exception("Failed to save auth data: $e");
    }
  }

  Future<AuthResponseModel> getAuthData() async {
    try {
      final prefs = await _getPrefs();
      final authData = prefs.getString('auth_data');
      
      if (authData != null) {
        return AuthResponseModel.fromJson(json.decode(authData));
      } else {
        throw Exception("Auth data not found");
      }
    } catch (e) {
      throw Exception("Failed to retrieve auth data: $e");
    }
  }

  Future<void> removeAuthData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove('auth_data');
    } catch (e) {
      throw Exception("Failed to remove auth data: $e");
    }
  }

  Future<bool> isLogin() async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey('auth_data');
    } catch (e) {
      throw Exception("Failed to check login status: $e");
    }
  }
}