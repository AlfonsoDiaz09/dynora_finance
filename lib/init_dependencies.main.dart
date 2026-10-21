part of 'init_dependencies.dart';


final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  _initApp();
  _initCategories();
  _initMovements();
  _initCards();
  _initBudget();
  _initDebts();
  _initLoans();
  _initScreens();
}

Future<void> _initCore() async {
  final isar = await IsarDatabase.open([
    SyncMetadataModelSchema,
    CategoryModelSchema,
    MovementModelSchema,
    CardModelSchema,
    CardPaymentModelSchema,
    BudgetModelSchema,
    PersonModelSchema,
    DebtModelSchema,
    LoanModelSchema,
    LoanPaymentModelSchema,
  ]);

  serviceLocator
    ..registerSingleton<Isar>(isar)
    ..registerLazySingleton<Uuid>(() => const Uuid())
    // Offline only for now. To enable online mode, implement the remote data
    // sources and register instead:
    // RemoteSyncEngine(
    //   handlers: [
    //     CategorySyncHandler(...),
    //     MovementSyncHandler(...),
    //     CardSyncHandler(...),
    //     CardPaymentSyncHandler(...),
    //     BudgetSyncHandler(...),
    //     PersonSyncHandler(...),
    //     DebtSyncHandler(...),
    //     LoanSyncHandler(...),
    //     LoanPaymentSyncHandler(...),
    //   ],
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
    ..registerFactory(() => DeleteCategory(serviceLocator()))
    ..registerFactory(() => EnsureDefaultCategories(serviceLocator()));
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

void _initCards() {
  serviceLocator
    ..registerLazySingleton<CardLocalDataSource>(
      () => CardLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<CardRepository>(
      () => CardRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )
    ..registerFactory(() => WatchCards(serviceLocator()))
    ..registerFactory(() => AddCard(serviceLocator()))
    ..registerFactory(() => UpdateCard(serviceLocator()))
    ..registerFactory(() => DeleteCard(serviceLocator()))
    ..registerLazySingleton<CardPaymentLocalDataSource>(
      () => CardPaymentLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<CardPaymentRepository>(
      () => CardPaymentRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
      ),
    )
    ..registerFactory(() => WatchCardPayments(serviceLocator()))
    ..registerFactory(() => RegisterCardPayment(serviceLocator()))
    ..registerFactory(() => DeleteCardPayment(serviceLocator()));
}

void _initBudget() {
  serviceLocator
    ..registerLazySingleton<BudgetLocalDataSource>(
      () => BudgetLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
      ),
    )
    ..registerFactory(() => WatchBudgets(serviceLocator()))
    ..registerFactory(() => SetBudget(serviceLocator()))
    ..registerFactory(() => DeleteBudget(serviceLocator()));
}

void _initDebts() {
  serviceLocator
    ..registerLazySingleton<PersonLocalDataSource>(
      () => PersonLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<PersonRepository>(
      () => PersonRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )
    ..registerLazySingleton<DebtLocalDataSource>(
      () => DebtLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<DebtRepository>(
      () => DebtRepositoryImpl(
        local: serviceLocator(),
        syncEngine: serviceLocator(),
      ),
    )
    ..registerFactory(() => WatchPeople(serviceLocator()))
    ..registerFactory(() => AddPerson(serviceLocator()))
    ..registerFactory(() => WatchDebts(serviceLocator()))
    ..registerFactory(() => SetMovementDebts(serviceLocator()))
    ..registerFactory(() => SetDebtsPaid(serviceLocator()))
    ..registerFactory(() => RenamePerson(serviceLocator()));
}

void _initLoans() {
  serviceLocator
    ..registerLazySingleton<LoanLocalDataSource>(
      () => LoanLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<LoanPaymentLocalDataSource>(
      () => LoanPaymentLocalDataSourceImpl(serviceLocator()),
    )
    ..registerLazySingleton<LoanRepository>(
      () => LoanRepositoryImpl(
        loans: serviceLocator(),
        payments: serviceLocator(),
        syncEngine: serviceLocator(),
        uuid: serviceLocator(),
      ),
    )
    ..registerFactory(() => WatchLoans(serviceLocator()))
    ..registerFactory(() => WatchLoanPayments(serviceLocator()))
    ..registerFactory(() => SaveLoan(serviceLocator()))
    ..registerFactory(() => DeleteLoan(serviceLocator()))
    ..registerFactory(() => SaveLoanPayment(serviceLocator()))
    ..registerFactory(() => DeleteLoanPayment(serviceLocator()));
}

void _initScreens() {
  serviceLocator
    ..registerFactory(
      () => HomeCubit(
        watchMovements: serviceLocator(),
        watchCategories: serviceLocator(),
        watchCards: serviceLocator(),
        watchCardPayments: serviceLocator(),
        watchDebts: serviceLocator(),
        watchLoans: serviceLocator(),
        watchLoanPayments: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => MovementsCubit(
        watchMovements: serviceLocator(),
        watchCategories: serviceLocator(),
        watchCards: serviceLocator(),
        watchDebts: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => StatsCubit(
        watchMovements: serviceLocator(),
        watchCategories: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CardsCubit(
        watchCards: serviceLocator(),
        watchMovements: serviceLocator(),
        watchCardPayments: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => LoansCubit(
        watchLoans: serviceLocator(),
        watchLoanPayments: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => DebtsCubit(
        watchDebts: serviceLocator(),
        watchPeople: serviceLocator(),
        watchMovements: serviceLocator(),
        setDebtsPaid: serviceLocator(),
        renamePerson: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => BudgetCubit(
        watchBudgets: serviceLocator(),
        watchCategories: serviceLocator(),
        watchMovements: serviceLocator(),
      ),
    );
}
