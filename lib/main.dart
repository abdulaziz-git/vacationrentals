import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // App-wide error boundaries so an uncaught error logs instead of crashing
  // silently (wire to Crashlytics/Sentry when a backend lands).
  FlutterError.onError = FlutterError.presentError;
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    debugPrint('Uncaught platform error: $error\n$stack');
    return true;
  };

  // Portrait-only (the UI is portrait-designed; matches Info.plist).
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);

  runApp(ProviderScope(observers: [_AppObserver()], child: const VrlbiApp()));
}

/// Lightweight provider observer — surfaces provider failures in debug logs.
class _AppObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    debugPrint(
      'Provider ${provider.name ?? provider.runtimeType} failed: $error',
    );
  }
}

class VrlbiApp extends StatelessWidget {
  const VrlbiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VRLBI — Vacation Rentals LBI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      routerConfig: appRouter,
      // Clamp Dynamic Type so very large accessibility sizes don't break
      // fixed-height rows, while still honoring user scaling up to 1.3×.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}
