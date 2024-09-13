import 'dart:async';

import 'package:camar_ais/constants/colors.dart';
import 'package:camar_ais/data/datasources/auth_local_datasources.dart';
import 'package:camar_ais/data/datasources/auth_remote_datasources.dart';
import 'package:camar_ais/pages/data_pages.dart';
import 'package:camar_ais/pages/main_page.dart';
import 'package:camar_ais/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:camar_ais/presentation/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'presentation/auth/bloc/login/login_bloc.dart';

void main() {
  final StreamController<DeviceData> dataController = StreamController<DeviceData>.broadcast();
  runApp(MyApp(dataController: dataController));
}

class MyApp extends StatelessWidget {
  final StreamController<DeviceData> dataController;

  const MyApp({super.key, required this.dataController});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDataSource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDataSource()),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
          textTheme: GoogleFonts.quicksandTextTheme(
            Theme.of(context).textTheme,
          ),
          appBarTheme: AppBarTheme(
            color: AppColors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.quicksand(
              color: AppColors.primary,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            iconTheme: const IconThemeData(
              color: AppColors.primary,
            ),
          ),
        ),
        home: FutureBuilder<bool>(
            future: AuthLocalDataSource().isAuth(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                return MainPage(dataController: dataController);
              } else {
                return const LoginPage();
              }
            }),
      ),
    );
  }
}