
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const GestaoMasterApp());
}

class AppColors {
  static const background = Color(0xFF06152F);
  static const surface = Color(0xFF0D2244);
  static const surfaceAlt = Color(0xFF153461);
  static const accent = Color(0xFF1B5FAF);
  static const accentSoft = Color(0xFF2E78D1);
  static const white = Color(0xFFF4F7FB);
  static const muted = Color(0xFFB8C4D8);
  static const grey = Color(0xFFD8DDE7);
  static const danger = Color(0xFFF38C97);
}

// Máscara brasileira de telefone: (11) 98765-4321 ou (11) 3456-7890.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = digits.length > 11 ? digits.substring(0, 11) : digits;
    if (d.isEmpty) return const TextEditingValue();
    String formatted = '(${d.substring(0, d.length < 2 ? d.length : 2)}';
    if (d.length >= 2) formatted += ')';
    if (d.length > 2) {
      final body = d.substring(2);
      final split = d.length > 10 ? 5 : 4;
      if (body.length <= split) {
        formatted += ' $body';
      } else {
        formatted += ' ${body.substring(0, split)}-${body.substring(split)}';
      }
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

// Digitação monetária por centavos: 1 -> R$ 0,01; 1234 -> R$ 12,34.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue();
    // Evita valores grandes demais para o modelo demonstrativo.
    final safe = digits.length > 12 ? digits.substring(0, 12) : digits;
    final cents = int.parse(safe);
    final amount = cents ~/ 100;
    final decimal = (cents % 100).toString().padLeft(2, '0');
    final whole = amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
    final formatted = 'R\$ $whole,$decimal';
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

class GestaoMasterApp extends StatelessWidget {
  const GestaoMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestao Master',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentSoft,
          secondary: AppColors.grey,
          surface: AppColors.surface,
          onSurface: AppColors.white,
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: const TextStyle(color: AppColors.muted),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: .82, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 550),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF06152F), Color(0xFF0C3D7A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -140,
            child: _GlowCircle(
              size: 340,
              color: AppColors.grey.withValues(alpha: .08),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -160,
            child: _GlowCircle(
              size: 350,
              color: AppColors.accentSoft.withValues(alpha: .08),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: .18),
                        ),
                      ),
                      child: Image.asset('assets/images/logo.png', width: 92, height: 92),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Gestao Master',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        letterSpacing: -.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Organize sua vida financeira com praticidade.',
                      style: TextStyle(fontSize: 14, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 75,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: AppColors.grey,
                  strokeWidth: 2.5,
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 37,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'CONTROLE • ORGANIZAÇÃO • CLAREZA',
                style: TextStyle(fontSize: 9, letterSpacing: 2, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 110, spreadRadius: 45),
        ],
      ),
    );
  }
}

class MoneyEntry {
  final String label;
  final String category;
  final double amount;
  final bool income;
  final IconData icon;
  final DateTime date;

  MoneyEntry({
    required this.label,
    required this.category,
    required this.amount,
    required this.income,
    required this.icon,
    required this.date,
  });
}

class ProfileData {
  final String name;
  final String phone;
  final String email;
  final File? image;

  const ProfileData({
    required this.name,
    required this.phone,
    required this.email,
    required this.image,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String _profileName = 'Pietro';
  String _profilePhone = '(12) 99999-0000';
  String _profileEmail = 'pietro@email.com';

  final List<MoneyEntry> _entries = [
    MoneyEntry(
      label: 'Salário',
      category: 'Trabalho',
      amount: 5200,
      income: true,
      icon: Icons.work_outline_rounded,
      date: DateTime(2026, 10, 29),
    ),
    MoneyEntry(
      label: 'Supermercado',
      category: 'Alimentação',
      amount: 185.90,
      income: false,
      icon: Icons.shopping_bag_outlined,
      date: DateTime(2026, 10, 28),
    ),
    MoneyEntry(
      label: 'Internet',
      category: 'Serviços',
      amount: 119.90,
      income: false,
      icon: Icons.wifi_rounded,
      date: DateTime(2026, 10, 27),
    ),
    MoneyEntry(
      label: 'Freelance',
      category: 'Trabalho',
      amount: 680,
      income: true,
      icon: Icons.laptop_mac_outlined,
      date: DateTime(2026, 10, 26),
    ),
    MoneyEntry(
      label: 'Cafeteria',
      category: 'Alimentação',
      amount: 32.50,
      income: false,
      icon: Icons.coffee_outlined,
      date: DateTime(2026, 10, 25),
    ),
  ];

  double get _income =>
      _entries.where((e) => e.income).fold(0, (v, e) => v + e.amount);
  double get _expense =>
      _entries.where((e) => !e.income).fold(0, (v, e) => v + e.amount);
  double get _balance => _income - _expense;

  static String money(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'R\$ $whole,${parts[1]}';
  }

  Future<void> _pickImageForModal(
    ImageSource source,
    ValueChanged<File?> onSelected,
  ) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (picked != null) {
        onSelected(File(picked.path));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível selecionar a foto.')),
      );
    }
  }

  Future<void> _openProfileEditor() async {
    final nameController = TextEditingController(text: _profileName);
    final phoneController = TextEditingController(text: _profilePhone);
    final emailController = TextEditingController(text: _profileEmail);
    File? tempImage = _profileImage;

    final result = await showModalBottomSheet<ProfileData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            22,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Editar perfil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: AppColors.surfaceAlt,
                            backgroundImage:
                                tempImage != null ? FileImage(tempImage!) : null,
                            child: tempImage == null
                                ? const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.grey,
                                    size: 42,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () async {
                                await _pickImageForModal(
                                  ImageSource.camera,
                                  (file) => update(() => tempImage = file),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accentSoft,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _pickImageForModal(
                                ImageSource.camera,
                                (file) => update(() => tempImage = file),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.grey.withValues(alpha: .35),
                              ),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Tirar foto'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              await _pickImageForModal(
                                ImageSource.gallery,
                                (file) => update(() => tempImage = file),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: AppColors.grey.withValues(alpha: .35),
                              ),
                            ),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galeria'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Seu nome',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  textInputAction: TextInputAction.next,
                  inputFormatters: [PhoneInputFormatter()],
                  decoration: const InputDecoration(
                    hintText: 'Seu telefone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textCapitalization: TextCapitalization.none,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    hintText: 'Seu e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentSoft,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                    onPressed: () {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          emailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Preencha nome, telefone e e-mail.'),
                          ),
                        );
                        return;
                      }
                      FocusScope.of(sheetContext).unfocus();
                      Navigator.pop(
                        sheetContext,
                        ProfileData(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          image: tempImage,
                        ),
                      );
                    },
                    child: const Text(
                      'Salvar perfil',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // A janela termina de sair antes de atualizar a tela que a abriu.
    if (result != null && mounted) {
      setState(() {
        _profileName = result.name;
        _profilePhone = result.phone;
        _profileEmail = result.email;
        _profileImage = result.image;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado!')),
      );
    }
    // Evita liberar controladores enquanto a animação de fechamento está ativa.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
  }

  Future<void> _addEntry() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    bool income = false;
    final result = await showModalBottomSheet<MoneyEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            22,
            24,
            MediaQuery.viewInsetsOf(context).bottom + 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: AppColors.muted.withValues(alpha: .45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const Text(
                  'Nova movimentação',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _typeButton(
                        'Despesa',
                        !income,
                        AppColors.danger,
                        () => update(() => income = false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _typeButton(
                        'Receita',
                        income,
                        AppColors.accentSoft,
                        () => update(() => income = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Descrição (ex.: Mercado)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  decoration: const InputDecoration(
                    hintText: 'R\$ 0,00',
                    helperText: 'Digite somente os números: 1234 vira R\$ 12,34',
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentSoft,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                    ),
                    onPressed: () {
                      final digits = amountController.text.replaceAll(RegExp(r'\D'), '');
                      final amount = digits.isEmpty ? null : int.tryParse(digits) == null
                          ? null : int.parse(digits) / 100.0;
                      if (nameController.text.trim().isEmpty ||
                          amount == null ||
                          !amount.isFinite ||
                          amount <= 0) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Informe uma descrição e um valor válido.',
                            ),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(
                        sheetContext,
                        MoneyEntry(
                          label: nameController.text.trim(),
                          category: income ? 'Receita' : 'Despesa',
                          amount: amount,
                          income: income,
                          icon: income
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          date: DateTime.now(),
                        ),
                      );
                    },
                    child: const Text(
                      'Salvar movimentação',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _entries.insert(0, result);
        _tab = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movimentação adicionada!')),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    nameController.dispose();
    amountController.dispose();
  }

  Widget _typeButton(
    String label,
    bool selected,
    Color color,
    VoidCallback onTap,
  ) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      foregroundColor: selected ? color : AppColors.muted,
      side: BorderSide(
        color: selected ? color : AppColors.muted.withValues(alpha: .3),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
    ),
    child: Text(label),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [_dashboard(), _analytics(), _transactions(), _profile()],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: Color(0xFF1A3966))),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, 'Início'),
                _navItem(1, Icons.donut_large_rounded, 'Análises'),
                _navItem(2, Icons.receipt_long_rounded, 'Extrato'),
                _navItem(3, Icons.person_outline_rounded, 'Perfil'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _tab == 3
          ? null
          : FloatingActionButton(
              onPressed: _addEntry,
              backgroundColor: AppColors.accentSoft,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded, size: 29),
            ),
    );
  }

  Widget _navItem(int index, IconData icon, String title) => Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: _tab == index ? AppColors.grey : AppColors.muted,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        _tab == index ? FontWeight.bold : FontWeight.normal,
                    color: _tab == index ? AppColors.grey : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _dashboard() => ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
        children: [
          _header(),
          const SizedBox(height: 31),
          const Text(
            'Visão geral',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Acompanhe sua vida financeira',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D2C57), Color(0xFF1A5EA9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF5F87B9)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 18,
                      color: AppColors.grey,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Saldo disponível',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    money(_balance),
                    style: const TextStyle(
                      fontSize: 35,
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.grey,
                      size: 15,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Visão consolidada das movimentações',
                      style: TextStyle(color: AppColors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  'Receitas',
                  _income,
                  Icons.south_west_rounded,
                  AppColors.accentSoft,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _metricCard(
                  'Despesas',
                  _expense,
                  Icons.north_east_rounded,
                  AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 31),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Movimentações recentes',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _tab = 2),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ..._entries.take(4).map(_transactionTile),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Dados demonstrativos • Não conectados a bancos',
              style: TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ),
        ],
      );

  Widget _header() => Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Image.asset('assets/images/logo.png', width: 34, height: 34),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GESTAO MASTER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'Seu controle financeiro em um só lugar.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _tab = 3),
            child: _smallAvatar(),
          ),
        ],
      );

  Widget _smallAvatar() => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
          image: _profileImage != null
              ? DecorationImage(
                  image: FileImage(_profileImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _profileImage == null
            ? const Icon(
                Icons.person_outline_rounded,
                color: AppColors.grey,
                size: 22,
              )
            : null,
      );

  Widget _metricCard(String title, double amount, IconData icon, Color color) =>
      Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                money(amount),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _transactionTile(MoneyEntry entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                entry.icon,
                color: entry.income ? AppColors.accentSoft : AppColors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${entry.category} • ${entry.date.day.toString().padLeft(2, '0')}/${entry.date.month.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.income ? '+' : '−'} ${money(entry.amount)}',
              style: TextStyle(
                color: entry.income ? AppColors.accentSoft : AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );

  Widget _pageHeading(String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(bottom: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 28),
            Text(
              title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      );

  Widget _analytics() {
    final percentage = _income == 0 ? 0.0 : (_expense / _income).clamp(0.0, 1.0);
    final categories = <String, double>{};
    for (final e in _entries.where((e) => !e.income)) {
      categories[e.category] = (categories[e.category] ?? 0) + e.amount;
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
      children: [
        _pageHeading('Análises', 'Entenda para onde seu dinheiro vai.'),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Despesas em relação às receitas',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 15),
              Text(
                '${(percentage * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 10,
                  backgroundColor: AppColors.surfaceAlt,
                  color: AppColors.accentSoft,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${money(_expense)} de ${money(_income)} em receitas',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Despesas por categoria',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const Text(
            'Ainda não há despesas.',
            style: TextStyle(color: AppColors.muted),
          ),
        ...categories.entries.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(item.key)),
                  Text(
                    money(item.value),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _transactions() => ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 100),
        children: [
          _pageHeading('Extrato', 'Histórico das suas movimentações.'),
          ..._entries.map(_transactionTile),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Movimentações mantidas apenas nesta sessão',
              style: TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ),
        ],
      );

  Widget _profile() => ListView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 35),
        children: [
          _pageHeading('Perfil', 'Personalize seus dados no aplicativo.'),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: AppColors.surfaceAlt,
                  backgroundImage:
                      _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.grey,
                          size: 31,
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _profilePhone,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _profileEmail,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openProfileEditor,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _profileInfoCard(
            'Dados pessoais',
            [
              _infoRow(Icons.person_outline_rounded, 'Nome', _profileName),
              _infoRow(Icons.phone_outlined, 'Telefone', _profilePhone),
              _infoRow(Icons.email_outlined, 'E-mail', _profileEmail),
            ],
          ),
          const SizedBox(height: 18),
          _profileInfoCard(
            'Sobre o aplicativo',
            const [
              Text(
                'Gestao Master ajuda a visualizar receitas, despesas e saldo em uma interface elegante e moderna.',
                style: TextStyle(color: AppColors.muted, height: 1.6),
              ),
              SizedBox(height: 17),
              Text(
                'Versão demonstrativa • Projeto acadêmico Flutter',
                style: TextStyle(color: AppColors.grey, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openProfileEditor,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 17),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.edit_rounded),
              label: const Text(
                'Editar perfil',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );

  Widget _profileInfoCard(String title, List<Widget> children) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            Icon(icon, color: AppColors.grey, size: 20),
            const SizedBox(width: 10),
            Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: AppColors.muted),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
}
