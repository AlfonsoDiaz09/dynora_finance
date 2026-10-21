import 'package:dynora_finance/features/debts/domain/entities/debt_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/presentation/utils/debtor.dart';
import 'package:dynora_finance/features/debts/presentation/widgets/debtor_avatars.dart';
import 'package:dynora_finance/features/debts/presentation/widgets/debtors_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Debtor debtor(
  String id,
  String name, {
  DateTime? paidAt,
  double amount = 100,
}) => Debtor(personId: id, name: name, amount: amount, paidAt: paidAt);

Widget app(Widget child) => ScreenUtilInit(
  designSize: const Size(360, 640),
  child: MaterialApp(
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  test('debtors per movement: pending first, then by name', () {
    PersonEntity person(String id, String name) => PersonEntity(
      id: id,
      name: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    DebtEntity debt(String person, {DateTime? paidAt}) => DebtEntity(
      id: 'debt_m_$person',
      movementId: 'm',
      personId: person,
      amount: 100,
      paidAt: paidAt,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final byMovement = Debtor.byMovement(
      [debt('ana', paidAt: DateTime(2026, 10, 20)), debt('luis'), debt('beto')],
      [person('ana', 'Ana'), person('luis', 'Luis'), person('beto', 'Beto')],
    );
    expect(byMovement['m']!.map((d) => d.name), ['Beto', 'Luis', 'Ana']);
  });

  testWidgets('shows one circle per person and +N beyond the limit', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        DebtorAvatars(
          debtors: [
            debtor('a', 'Ana'),
            debtor('a', 'Ana'),
            debtor('b', 'Beto'),
            debtor('c', 'Carla'),
            debtor('d', 'Dani'),
            debtor('e', 'Eva'),
          ],
          onTap: () {},
        ),
      ),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('tapping the circles shows who paid and when', (tester) async {
    final debtors = [
      debtor('a', 'Ana', amount: 300),
      debtor('l', 'Luis', paidAt: DateTime(2026, 10, 20), amount: 200),
    ];
    await tester.pumpWidget(
      app(
        Builder(
          builder: (context) => DebtorAvatars(
            debtors: debtors,
            onTap: () =>
                DebtorsSheet.show(context, title: 'Cena', debtors: debtors),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DebtorAvatars));
    await tester.pumpAndSettle();

    expect(find.text('Cena'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Pendiente'), findsWidgets);
    expect(find.text('Luis'), findsOneWidget);
    expect(find.text('Pagado el 20 Oct'), findsOneWidget);
    expect(find.text('\$300.00'), findsWidgets);
    expect(find.text('Ver todo en Me deben'), findsOneWidget);
  });
}
