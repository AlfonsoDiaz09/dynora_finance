import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/domain/usecases/delete_card_payment.dart';
import 'package:dynora_finance/features/cards/domain/usecases/register_card_payment.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class CardPaymentFormState extends Equatable {
  const CardPaymentFormState({
    required this.paidAt,
    this.status = FormStatus.idle,
    this.error,
  });

  final DateTime paidAt;
  final FormStatus status;
  final String? error;

  CardPaymentFormState copyWith({
    DateTime? paidAt,
    FormStatus? status,
    String? Function()? error,
  }) {
    return CardPaymentFormState(
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [paidAt, status, error];
}

class CardPaymentFormCubit extends Cubit<CardPaymentFormState> {
  CardPaymentFormCubit({
    required this.cardId,
    required this.statement,
    required RegisterCardPayment registerPayment,
    required DeleteCardPayment deletePayment,
  }) : _registerPayment = registerPayment,
       _deletePayment = deletePayment,
       super(
         CardPaymentFormState(
           paidAt: statement.payment?.paidAt ?? DateTime.now(),
         ),
       );

  final String cardId;

  /// Statement being paid; its payment, if any, is the one edited.
  final CardStatement statement;
  final RegisterCardPayment _registerPayment;
  final DeleteCardPayment _deletePayment;

  void changePaidAt(DateTime date) => emit(state.copyWith(paidAt: date));

  Future<void> submit(double? amount) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(
      await _registerPayment(
        RegisterCardPaymentParams(
          cardId: cardId,
          periodStart: statement.period.start,
          amount: amount,
          paidAt: state.paidAt,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final payment = statement.payment;
    if (payment == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deletePayment(payment.id));
  }

  void _emitResult(Either<Failure, Object> result) {
    result.match(
      (failure) => emit(
        state.copyWith(
          status: FormStatus.failure,
          error: () => failure.message,
        ),
      ),
      (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }
}
