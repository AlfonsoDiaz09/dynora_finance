import 'package:dynora_finance/core/logs/logger_output.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

var logger = LoggerOutput().logger;

void main() async {
  await initDependencies();

  final navigationBloc = serviceLocator<NavigationBloc>();
  final routerconfig = createRouter(navigationBloc);

  runApp(MyApp(router: routerconfig));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<NavigationBloc>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp.router(
            title: 'DynoraFinanceApp',
            routerConfig: router,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('es', 'ES'),
              const Locale('en', 'EN'),
            ],
          ),
      ),
    );
  }
}
