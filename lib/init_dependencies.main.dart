part of 'init_dependencies.dart';


final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initApp();
  _initCategories();
  _initMovements();
}

Future<void> _initCore() async {
  final isar = await IsarDatabase.open([
    SyncMetadataModelSchema,
    CategoryModelSchema,
    MovementModelSchema,
  ]);

  serviceLocator
    ..registerSingleton<Isar>(isar)
    ..registerLazySingleton<Uuid>(() => const Uuid())
    // Offline only for now. To enable online mode, implement the remote data
    // sources and register instead:
    // RemoteSyncEngine(
    //   handlers: [CategorySyncHandler(...), MovementSyncHandler(...)],
    //   metadata: SyncMetadataLocalDataSourceImpl(serviceLocator()),
    // )
    ..registerLazySingleton<SyncEngine>(() => const OfflineSyncEngine());
}

void _initApp(){
   serviceLocator.registerLazySingleton(() => NavigationCubit());
}

void _initCategories() {
  serviceLocator
    ..registerLazySingleton<CategoryLocalDataSource>(
      () => CategoryLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetCategories(serviceLocator()))
    ..registerFactory(() => WatchCategories(serviceLocator()))
    ..registerFactory(() => AddCategory(serviceLocator()))
    ..registerFactory(() => UpdateCategory(serviceLocator()))
    ..registerFactory(() => DeleteCategory(serviceLocator()));
}

void _initMovements() {
  serviceLocator
    ..registerLazySingleton<MovementLocalDataSource>(
      () => MovementLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<MovementRepository>(
      () => MovementRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetMovements(serviceLocator()))
    ..registerFactory(() => WatchMovements(serviceLocator()))
    ..registerFactory(() => AddMovement(serviceLocator()))
    ..registerFactory(() => UpdateMovement(serviceLocator()))
    ..registerFactory(() => DeleteMovement(serviceLocator()));
}
