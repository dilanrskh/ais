import 'package:camar_ais/data/datasources/auth_local_datasources.dart';
import 'package:camar_ais/presentation/auth/bloc/logout/logout_bloc.dart';
import 'package:camar_ais/presentation/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text('Settings'),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Center(
              child:  BlocConsumer<LogoutBloc, LogoutState>(
            listener: (context, state) {
              state.maybeMap(
                orElse: () {},
                success: (_) {
                  AuthLocalDataSource().removeAuthData();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                },
              );
            },
            builder: (context, state) {
              return ElevatedButton(
                onPressed: () {
                  context.read<LogoutBloc>().add(const LogoutEvent.logout());
                },
                child: const Text('Logout'),
              );
            },
          ),
            ),
          ),
        ],
      ),
    );
  }
}