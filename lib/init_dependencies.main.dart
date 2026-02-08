part of 'init_dependencies.dart';


final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initApp();
}

void _initApp(){
   serviceLocator.registerLazySingleton(() => NavigationBloc());
}