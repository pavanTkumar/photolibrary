import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';

class FishpondApp extends StatelessWidget {
  const FishpondApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final appRouter = AppRouter();
    
    return MaterialApp.router(
      title: 'Fish Pond by Suviko',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: appRouter.router,
    );
  }
}