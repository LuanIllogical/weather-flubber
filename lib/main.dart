// lib/main.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Previsão do Tempo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        // Correção: usar CardThemeData em vez de CardTheme
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Verificar se a permissão foi concedida quando o app retornar
      _checkPermissionAndNavigate();
    }
  }

  Future<void> _requestLocationPermission() async {
    // Solicitar permissão de localização imediatamente
    var status = await Permission.location.status;

    if (status.isGranted) {
      // Permissão já concedida, navegar para HomeScreen
      _navigateToHome();
    } else if (status.isDenied || status.isRestricted) {
      // Solicitar permissão
      status = await Permission.location.request();

      if (status.isGranted) {
        _navigateToHome();
      } else {
        // Permissão negada, mostrar diálogo
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      // Permissão permanentemente negada
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _checkPermissionAndNavigate() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.orange),
              SizedBox(width: 8),
              Text('Permissão de Localização'),
            ],
          ),
          content: const Text(
            'A permissão de localização foi negada. Você pode:\n\n'
            '• Buscar cidades manualmente\n'
            '• Conceder a permissão nas configurações do dispositivo\n\n'
            'Sem a localização, será necessário pesquisar por uma cidade para ver o clima.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToHome();
              },
              child: const Text('Buscar cidade manualmente'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Abrir Configurações'),
              onPressed: () {
                Navigator.pop(context);
                openAppSettings().then((_) {
                  // Após abrir configurações, navegar para home
                  _navigateToHome();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animação de carregamento
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.wb_sunny,
                    size: 80,
                    color: Colors.yellow,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Previsão do Tempo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Informações climáticas em tempo real',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Solicitando permissões...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
