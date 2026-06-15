import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/index.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nomorHPController = TextEditingController();
  final asalController = TextEditingController();
  
  String selectedRole = 'user';
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeToTerms = false;

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nomorHPController.dispose();
    asalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Buat Akun Baru',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bergabunglah dengan kami',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),
                  // Error Message
                  if (authProvider.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[400]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              authProvider.clearError();
                            },
                            child: Icon(Icons.close, color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                  if (authProvider.errorMessage != null)
                    const SizedBox(height: 16),
                  // Nama Field
                  TextField(
                    controller: namaController,
                    enabled: !authProvider.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap Anda',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email Field
                  TextField(
                    controller: emailController,
                    enabled: !authProvider.isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'nama@example.com',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Field
                  TextField(
                    controller: passwordController,
                    enabled: !authProvider.isLoading,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 6 karakter',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        child: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password Field
                  TextField(
                    controller: confirmPasswordController,
                    enabled: !authProvider.isLoading,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        child: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Nomor HP Field
                  TextField(
                    controller: nomorHPController,
                    enabled: !authProvider.isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP (Opsional)',
                      hintText: '08xxxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Asal Field
                  TextField(
                    controller: asalController,
                    enabled: !authProvider.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Asal / Jurusan (Opsional)',
                      hintText: 'Contoh: Teknik Informatika',
                      prefixIcon: const Icon(Icons.school),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Role Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'user',
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline),
                              const SizedBox(width: 8),
                              const Text('User (Peserta)'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Row(
                            children: [
                              const Icon(Icons.admin_panel_settings),
                              const SizedBox(width: 8),
                              const Text('Admin (Pengelola)'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: !authProvider.isLoading
                          ? (value) {
                              setState(() {
                                selectedRole = value ?? 'user';
                              });
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Terms & Conditions
                  GestureDetector(
                    onTap: !authProvider.isLoading
                        ? () {
                            setState(() {
                              agreeToTerms = !agreeToTerms;
                            });
                          }
                        : null,
                    child: Row(
                      children: [
                        Checkbox(
                          value: agreeToTerms,
                          onChanged: !authProvider.isLoading
                              ? (value) {
                                  setState(() {
                                    agreeToTerms = value ?? false;
                                  });
                                }
                              : null,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Saya setuju dengan '),
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleRegister(context, authProvider),
                      child: authProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Daftar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun? '),
                      GestureDetector(
                        onTap: !authProvider.isLoading
                            ? () {
                                Navigator.of(context).pop();
                              }
                            : null,
                        child: Text(
                          'Login di sini',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleRegister(BuildContext context, AuthProvider authProvider) async {
    // Validation
    if (namaController.text.isEmpty) {
      _showError(context, 'Nama tidak boleh kosong');
      return;
    }

    if (emailController.text.isEmpty) {
      _showError(context, 'Email tidak boleh kosong');
      return;
    }

    if (passwordController.text.isEmpty) {
      _showError(context, 'Password tidak boleh kosong');
      return;
    }

    if (passwordController.text.length < 6) {
      _showError(context, 'Password minimal 6 karakter');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError(context, 'Password tidak cocok');
      return;
    }

    if (!agreeToTerms) {
      _showError(context, 'Anda harus setuju dengan Syarat & Ketentuan');
      return;
    }

    final success = await authProvider.register(
      email: emailController.text,
      password: passwordController.text,
      nama: namaController.text,
      role: selectedRole,
      nomorHP: nomorHPController.text.isEmpty ? null : nomorHPController.text,
      asal: asalController.text.isEmpty ? null : asalController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Selamat datang.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate based on role
        if (authProvider.isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/user/home');
        }
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
