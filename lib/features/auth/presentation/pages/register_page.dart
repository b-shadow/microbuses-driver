import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/services/driver_api.dart';
import '../../../../shared/widgets/app_shell.dart';
import '../../../../shared/widgets/app_states.dart';
import '../../../../shared/widgets/app_ui.dart';

class DriverRegisterPage extends StatefulWidget {
  const DriverRegisterPage({super.key, this.onToggleTheme});

  final VoidCallback? onToggleTheme;

  @override
  State<DriverRegisterPage> createState() => _DriverRegisterPageState();
}

class _DriverRegisterPageState extends State<DriverRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _ci = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _licenseCategory = TextEditingController(text: 'B');
  final _api = DriverApi();

  String _status = '';
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _status = '';
    });
    try {
      await _api.dio.post('/auth/register-driver', data: {
        'email': _email.text.trim(),
        'password': _password.text,
        'ci': _ci.text.trim(),
        'full_name': _fullName.text.trim(),
        'phone': _phone.text.trim(),
        'license_category': _licenseCategory.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        _status =
            'Registro enviado. Tu cuenta quedo pendiente de aprobacion administrativa.';
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.login);
    } catch (error) {
      setState(
        () => _status = DriverApi.describeError(
          error,
          fallback: 'No se pudo registrar el conductor.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _ci.dispose();
    _fullName.dispose();
    _phone.dispose();
    _licenseCategory.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShell(
        title: 'Registro conductor',
        showAuthButton: false,
        onToggleTheme: widget.onToggleTheme,
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const DriverHeroCard(
                title: 'Registro operativo',
                subtitle:
                    'Completa tus datos para solicitar acceso. El administrador debe aprobar tu cuenta antes del primer inicio de sesion.',
                trailing: FaIcon(
                  FontAwesomeIcons.idCard,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              DriverListCard(
                title: 'Datos del conductor',
                subtitle:
                    'Estos datos se enviaran al backend y quedaran en estado pendiente.',
                icon: FontAwesomeIcons.userPlus,
                footer: Column(
                  children: [
                    TextFormField(
                      controller: _fullName,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Ingresa el nombre completo.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ci,
                      decoration: const InputDecoration(
                        labelText: 'CI',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Ingresa el CI.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Telefono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Ingresa el telefono.'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria licencia',
                        prefixIcon: Icon(Icons.assignment_ind_outlined),
                      ),
                      validator: (v) => (v ?? '').trim().isEmpty
                          ? 'Ingresa la categoria.'
                          : null,
                    ),
                    const SizedBox(height: 12),
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
                          (v ?? '').length < 6 ? 'Minimo 6 caracteres.' : null,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _register();
                              }
                            },
                      child: Text(
                          _loading ? 'Registrando...' : 'Solicitar acceso'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Ya tienes cuenta?'),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, AppRouter.login),
                          child: const Text('Inicia sesion'),
                        ),
                      ],
                    ),
                    StatusBanner(
                      text: _status,
                      isError: _status.isNotEmpty &&
                          !_status.toLowerCase().contains('pendiente'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
