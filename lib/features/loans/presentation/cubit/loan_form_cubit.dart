import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/usecases/loan_usecases.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class LoanFormState extends Equatable {
  const LoanFormState({
    required this.kind,
    required this.startDate,
    this.firstPaymentDate,
    this.fixedPayments = false,
    this.countsAsIncome = true,
    this.status = FormStatus.idle,
    this.error,
  });

  final LoanKind kind;
  final DateTime startDate;
  final DateTime? firstPaymentDate;

  /// Personal loans only: whether there is a fixed monthly payment.
  final bool fixedPayments;
  final bool countsAsIncome;
  final FormStatus status;
  final String? error;

  /// Institutions always pay fixed installments.
  bool get hasFixedPayments => kind == LoanKind.institution || fixedPayments;

  LoanFormState copyWith({
    LoanKind? kind,
    DateTime? startDate,
    DateTime? Function()? firstPaymentDate,
    bool? fixedPayments,
    bool? countsAsIncome,
    FormStatus? status,
    String? Function()? error,
  }) {
    return LoanFormState(
      kind: kind ?? this.kind,
      startDate: startDate ?? this.startDate,
      firstPaymentDate: firstPaymentDate != null
          ? firstPaymentDate()
          : this.firstPaymentDate,
      fixedPayments: fixedPayments ?? this.fixedPayments,
      countsAsIncome: countsAsIncome ?? this.countsAsIncome,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
    kind,
    startDate,
    firstPaymentDate,
    fixedPayments,
    countsAsIncome,
    status,
    error,
  ];
}

class LoanFormCubit extends Cubit<LoanFormState> {
  LoanFormCubit({
    required SaveLoan saveLoan,
    required DeleteLoan deleteLoan,
    this.editing,
  }) : _saveLoan = saveLoan,
       _deleteLoan = deleteLoan,
       super(
         LoanFormState(
           kind: editing?.kind ?? LoanKind.institution,
           startDate: editing?.startDate ?? DateTime.now(),
           firstPaymentDate: editing?.firstPaymentDate,
           fixedPayments: editing?.installmentAmount != null,
           countsAsIncome: editing?.countsAsIncome ?? true,
         ),
       );

  final SaveLoan _saveLoan;
  final DeleteLoan _deleteLoan;

  /// Loan being edited, `null` when creating a new one.
  final LoanEntity? editing;

  void selectKind(LoanKind kind) =>
      emit(state.copyWith(kind: kind, error: () => null));

  void changeStartDate(DateTime date) => emit(state.copyWith(startDate: date));

  void changeFirstPaymentDate(DateTime date) =>
      emit(state.copyWith(firstPaymentDate: () => date, error: () => null));

  void setFixedPayments(bool value) =>
      emit(state.copyWith(fixedPayments: value, error: () => null));

  void setCountsAsIncome(bool value) =>
      emit(state.copyWith(countsAsIncome: value));

  /// Loan described by the current form values (for previews and saving).
  LoanEntity draft({
    required String name,
    required double principal,
    double? interestRate,
    double? installmentAmount,
    int? installmentCount,
    String? note,
  }) {
    final fixed = state.hasFixedPayments;
    final now = DateTime.now();
    return LoanEntity(
      id: editing?.id ?? '',
      name: name.trim(),
      kind: state.kind,
      principal: principal,
      startDate: state.startDate,
      interestRate: state.kind == LoanKind.personal && (interestRate ?? 0) > 0
          ? interestRate
          : null,
      installmentAmount: fixed ? installmentAmount : null,
      installmentCount: fixed ? installmentCount : null,
      firstPaymentDate: fixed ? state.firstPaymentDate : null,
      countsAsIncome: state.countsAsIncome,
      note: note == null || note.trim().isEmpty ? null : note.trim(),
      createdAt: editing?.createdAt ?? now,
      updatedAt: editing?.updatedAt ?? now,
    );
  }

  Future<void> submit({
    required String name,
    required double? principal,
    double? interestRate,
    double? installmentAmount,
    int? installmentCount,
    String? note,
  }) async {
    if (principal == null) {
      emit(state.copyWith(error: () => 'Ingresa el monto prestado'));
      return;
    }
    if (state.hasFixedPayments && installmentAmount == null) {
      emit(state.copyWith(error: () => 'Ingresa el pago mensual'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(
      await _saveLoan(
        draft(
          name: name,
          principal: principal,
          interestRate: interestRate,
          installmentAmount: installmentAmount,
          installmentCount: installmentCount,
          note: note,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deleteLoan(current.id));
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

class LoanPaymentFormState extends Equatable {
  const LoanPaymentFormState({
    required this.paidAt,
    this.status = FormStatus.idle,
    this.error,
  });

  final DateTime paidAt;
  final FormStatus status;
  final String? error;

  LoanPaymentFormState copyWith({
    DateTime? paidAt,
    FormStatus? status,
    String? Function()? error,
  }) {
    return LoanPaymentFormState(
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [paidAt, status, error];
}

class LoanPaymentFormCubit extends Cubit<LoanPaymentFormState> {
  LoanPaymentFormCubit({
    required this.loanId,
    required SaveLoanPayment savePayment,
    required DeleteLoanPayment deletePayment,
    this.editing,
  }) : _savePayment = savePayment,
       _deletePayment = deletePayment,
       super(LoanPaymentFormState(paidAt: editing?.paidAt ?? DateTime.now()));

  final String loanId;
  final SaveLoanPayment _savePayment;
  final DeleteLoanPayment _deletePayment;

  /// Payment being edited, `null` when registering a new one.
  final LoanPaymentEntity? editing;

  void changePaidAt(DateTime date) => emit(state.copyWith(paidAt: date));

  Future<void> submit(double? amount, String note) async {
    if (amount == null) {
      emit(state.copyWith(error: () => 'Ingresa un monto válido'));
      return;
    }
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    final now = DateTime.now();
    _emitResult(
      await _savePayment(
        LoanPaymentEntity(
          id: editing?.id ?? '',
          loanId: loanId,
          amount: amount,
          paidAt: state.paidAt,
          note: note.trim().isEmpty ? null : note.trim(),
          createdAt: editing?.createdAt ?? now,
          updatedAt: editing?.updatedAt ?? now,
        ),
      ),
    );
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deletePayment(current.id));
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
