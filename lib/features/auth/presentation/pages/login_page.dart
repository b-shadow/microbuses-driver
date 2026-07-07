import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/services/driver_api.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = DriverApi();
  String _status = '';
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final res = await _api.dio.post('/auth/login',
          data: {'email': _email.text.trim(), 'password': _password.text});
      final token = res.data['data']?['access_token'] as String?;
      if (token == null || token.isEmpty) {
        setState(() => _status = 'Credenciales invalidas.');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_access_token', token);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (error) {
      setState(
        () => _status = DriverApi.describeError(
          error,
          fallback: 'Error de autenticacion.',
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Login conductor',
        showBack: false,
        showAuthButton: false,
        onToggleTheme: widget.onToggleTheme,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const DriverHeroCard(
                title: 'Acceso de conductor',
                subtitle:
                    'Inicia sesion para seleccionar microbus, activar recorrido y sincronizar ubicacion con el backend.',
                trailing: FaIcon(FontAwesomeIcons.idCardClip,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 18),
              DriverListCard(
                title: 'Credenciales operativas',
                subtitle:
                    'Usa el correo aprobado por administracion y tu contrasena actual.',
                icon: FontAwesomeIcons.rightToBracket,
                footer: Column(
                  children: [
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Ingresa tu correo.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contrasena',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                      validator: (v) =>
                          (v ?? '').isEmpty ? 'Ingresa tu contrasena.' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) _login();
                            },
                      child: Text(_loading ? 'Ingresando...' : 'Ingresar'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No tienes cuenta?'),
                        TextButton(
                          onPressed: _loading
                              ? null
                              : () => Navigator.pushNamed(
                                  context, AppRouter.register),
                          child: const Text('Registrate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatusBanner(
                        text: _status,
                        isError: _status.isNotEmpty && _status != 'OK'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
