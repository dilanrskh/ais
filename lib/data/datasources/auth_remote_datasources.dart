import 'dart:convert';

import 'package:camar_ais/constants/variables.dart';
import 'package:camar_ais/data/datasources/auth_local_datasources.dart';
import 'package:camar_ais/data/models/auth_response_model.dart';
import 'package:camar_ais/data/models/register_request.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  Future<Either<String, AuthResponseModel>> register(RegisterRequestModel data) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/register'),
      body: data.toJson(), 
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      return Right(AuthResponseModel.fromJson(json.decode(response.body)));
    } else {
      return Left(response.body);
    }
  }

  Future<Either<String, AuthResponseModel>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/login'),
      body: json.encode({
        'email': email,
        'password': password,
      }), 
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return Right(AuthResponseModel.fromJson(json.decode(response.body)));
    } else {
      return Left(response.body);
    }
  }

  Future<Either<String, String>> logout() async {
    final authData = await AuthLocalDatasource().getAuthData();
    final response = await http.post(
      Uri.parse('${Variables.baseUrl}/api/logout'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
      },
    );
    if (response.statusCode == 200) {
      return Right(response.body);
    } else {
      return Left(response.body);
    }
  }
}