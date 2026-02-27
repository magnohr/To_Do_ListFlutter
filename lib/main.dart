import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

// 🔹 MODELS DO HIVE
import 'package:to_do_list/pastas/models/livroModel.dart';
import 'package:to_do_list/pastas/models/paginaModel.dart';

// 🔹 CONTROLLERS
import 'features/addTarefa/controllerAddTarefa.dart';

// 🔹 TELAS
import 'package:to_do_list/pastas/pastas.dart';
import 'features/addTarefa/addTarefaEditar.dart';
import 'features/configuraçao/configuracao.dart';
import 'features/home/home.dart';
import 'features/livros/livros.dart';
import 'features/login/cadastro/cadastro.dart';
import 'features/login/login.dart';
import 'features/splash/splash.dart';

import 'package:flutter/services.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize(); // ⭐ ESSENCIAL

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Future.delayed(const Duration(milliseconds: 50)); // ⭐ estabilidade extra

  try {
    await Hive.initFlutter();
    Hive.registerAdapter(LivroModelAdapter());
    Hive.registerAdapter(PaginaModelAdapter());

    await Hive.openBox<LivroModel>('livros');
    await Hive.openBox('config');
  } catch (e, s) {
    debugPrint('Erro Hive: $e');
    debugPrint('$s');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoController()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔴 ESSENCIAL PARA O flutter_quill
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],

      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/cadastro': (context) => const Cadastro(),
        '/home': (context) => const Home(),
        '/addtarefaEditar': (context) => const AddtarefaEditar(),
        '/config': (context) => const Configuracao(),
        '/pastas': (context) => const Pastas(),
        '/livros': (context) => const Livros(),
      },
    );
  }
}
