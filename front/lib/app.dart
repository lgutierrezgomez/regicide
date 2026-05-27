import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/l10n/app_strings.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/web/initial_room_code.dart';
import 'di/app_dependencies.dart';
import 'presentation/game/page/game_page.dart';
import 'presentation/home/bloc/home_event.dart';
import 'presentation/home/page/home_page.dart';
import 'presentation/lobby/page/lobby_page.dart';

class RegicideApp extends StatefulWidget {
  const RegicideApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<RegicideApp> createState() => _RegicideAppState();
}

class _RegicideAppState extends State<RegicideApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrapNavigation();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode) {
      widget.deps.prepareForHotReload();
      _bootstrapNavigation();
    }
  }

  Future<void> _bootstrapNavigation() async {
    final route = await widget.deps.startupRouteResolver.resolve();
    if (!mounted) {
      return;
    }
    setState(() => _bootstrapped = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (route == AppRoutes.home) {
        return;
      }
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped) {
      return MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppStrings.appTitle,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.lobby:
            return MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => widget.deps.createLobbyBloc(),
                child: const LobbyPage(),
              ),
            );
          case AppRoutes.game:
            return MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => widget.deps.createGameBloc(),
                child: const GamePage(),
              ),
            );
          case AppRoutes.home:
          default:
            return MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => widget.deps.createHomeBloc(
                  initialRoomCode: readInitialRoomCodeFromUrl(),
                )..add(const HomeStarted()),
                child: const HomePage(),
              ),
            );
        }
      },
    );
  }
}
