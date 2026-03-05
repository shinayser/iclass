import 'package:auth/src/features/login/presentation/controller/login_bloc.dart';
import 'package:auth/src/features/login/presentation/controller/login_state.dart';
import 'package:common/common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (BuildContext context) => Injection.get<LoginBloc>(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginDoneState) {
            Navigator.of(
              context,
            ).pushReplacementNamed(CommonRoutes.getHome(state.loginType));
          }
        },
        builder: (BuildContext context, LoginState state) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF9333EA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 72,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Bem-vindo",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Entre na sua conta",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _emailController,
                              enabled: state is! LoginLoadingState,
                              forceErrorText: state is LoginErrorState
                                  ? 'Credenciais inválidas'
                                  : null,
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: state is! LoginLoadingState,
                              forceErrorText: state is LoginErrorState
                                  ? 'Credenciais inválidas'
                                  : null,
                              decoration: InputDecoration(
                                labelText: "Senha",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  _showNotImplementedYet(context);
                                },
                                child: const Text("Esqueceu a senha?"),
                              ),
                            ),

                            const SizedBox(height: 8),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: state is LoginLoadingState
                                  ? Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),

                                      onPressed: () {
                                        BlocProvider.of<LoginBloc>(
                                          context,
                                        ).login(
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                      },
                                      child: const Text(
                                        "Entrar",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Não tem conta?"),
                                TextButton(
                                  onPressed: () {
                                    _showNotImplementedYet(context);
                                  },
                                  child: const Text("Criar conta"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showNotImplementedYet(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Não implementado ainda :('),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
