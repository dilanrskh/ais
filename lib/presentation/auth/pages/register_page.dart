import 'package:camar_ais/components/custom_text_field.dart';
import 'package:camar_ais/components/spaces.dart';
import 'package:camar_ais/data/models/register_request.dart';
import 'package:camar_ais/presentation/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camar_ais/presentation/auth/bloc/register/register_bloc.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _kapalController = TextEditingController();
  final TextEditingController _noSeriController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _kapalController.dispose();
    _noSeriController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _kapalController.text.isEmpty ||
        _noSeriController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: const Text('Silakan isi semua field'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final registerRequest = RegisterRequestModel(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
      kapal: _kapalController.text,
      noSeri: _noSeriController.text,
    );

    context
        .read<RegisterBloc>()
        .add(RegisterButtonPressed(data: registerRequest));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Register Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const SpaceHeight(80.0),
          const Center(
            child: Text(
              "Camar Ais",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
          ),
          const SpaceHeight(8.0),
          const Center(
            child: Text(
              "Daftar untuk Kapal",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey),
            ),
          ),
          const SpaceHeight(40.0),
          ..._buildTextFields(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: BlocListener<RegisterBloc, RegisterState>(
              listener: (context, state) {
                if (state is RegisterLoading) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        Center(child: CircularProgressIndicator()),
                  );
                } else if (state is RegisterSuccess) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                } else if (state is RegisterFailed) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red));
                }
              },
              child: BlocBuilder<RegisterBloc, RegisterState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: (state is RegisterLoading) ? null : _register,
                    child: state is RegisterLoading
                        ? CircularProgressIndicator()
                        : const Text('Register'),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Sudah Punya Akun ?'),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTextFields() {
    return [
      Padding(
        padding: const EdgeInsets.all(8),
        child:
            CustomTextField(label: 'Nama Lengkap', controller: _nameController),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: CustomTextField(label: 'Email', controller: _emailController),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: CustomTextField(
            controller: _passwordController,
            label: 'Password',
            obscureText: true),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child:
            CustomTextField(label: 'Nama Kapal', controller: _kapalController),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child:
            CustomTextField(label: 'Nomor Seri', controller: _noSeriController),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: CustomTextField(
            controller: _phoneController, label: 'Nomor Telepon'),
      ),
    ];
  }
}
