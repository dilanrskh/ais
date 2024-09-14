import 'dart:async';

import 'package:camar_ais/components/buttons.dart';
import 'package:camar_ais/components/custom_text_field.dart';
import 'package:camar_ais/components/spaces.dart';
import 'package:camar_ais/data/datasources/auth_local_datasources.dart';
import 'package:camar_ais/pages/data_pages.dart';
import 'package:camar_ais/pages/main_page.dart';
import 'package:camar_ais/presentation/auth/bloc/login/login_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final StreamController<DeviceData> dataController = StreamController<DeviceData>.broadcast();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    dataController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const SpaceHeight(80.0),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 130.0),
          //   child: Image.asset(
          //     Assets.images.logo.path,
          //     width: 100,
          //     height: 100,
          //   ),
          // ),
          const SpaceHeight(24.0),
          const Center(
            child: Text(
              "Camar Ais",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SpaceHeight(8.0),
          const Center(
            child: Text(
              "Masuk untuk Kapal",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          const SpaceHeight(40.0),
          CustomTextField(
            controller: usernameController,
            label: 'Username',
          ),
          const SpaceHeight(12.0),
          CustomTextField(
            controller: passwordController,
            label: 'Password',
            obscureText: true,
          ),
          const SpaceHeight(24.0),
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              state.maybeWhen(
                orElse: () {},
                success: (authResponseModel) {
                  if (authResponseModel != null) {
                    AuthLocalDataSource().saveAuthData(authResponseModel);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(dataController: dataController),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Authentication failed'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
            child: BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return state.maybeWhen(orElse: () {
                  return Button.filled(
                    onPressed: () {
                      context.read<LoginBloc>().add(
                        LoginEvent.login(
                          email: usernameController.text,
                          password: passwordController.text,
                        ),
                      );
                    },
                    label: 'Masuk',
                  );
                }, loading: () {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}