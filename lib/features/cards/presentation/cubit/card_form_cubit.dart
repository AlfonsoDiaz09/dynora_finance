import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/cards/domain/usecases/add_card.dart';
import 'package:dynora_finance/features/cards/domain/usecases/delete_card.dart';
import 'package:dynora_finance/features/cards/domain/usecases/update_card.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

class CardFormState extends Equatable {
  const CardFormState({
    required this.type,
    required this.colorValue,
    this.status = FormStatus.idle,
    this.error,
  });

  final CardType type;
  final int colorValue;
  final FormStatus status;
  final String? error;

  CardFormState copyWith({
    CardType? type,
    int? colorValue,
    FormStatus? status,
    String? Function()? error,
  }) {
    return CardFormState(
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [type, colorValue, status, error];
}

class CardFormCubit extends Cubit<CardFormState> {
  CardFormCubit({
    required AddCard addCard,
    required UpdateCard updateCard,
    required DeleteCard deleteCard,
    required int defaultColorValue,
    this.editing,
  }) : _addCard = addCard,
       _updateCard = updateCard,
       _deleteCard = deleteCard,
       super(
         CardFormState(
           type: editing?.type ?? CardType.credit,
           colorValue: editing?.colorValue ?? defaultColorValue,
         ),
       );

  final AddCard _addCard;
  final UpdateCard _updateCard;
  final DeleteCard _deleteCard;

  /// Card being edited, `null` when creating a new one.
  final CardEntity? editing;

  void selectType(CardType type) =>
      emit(state.copyWith(type: type, error: () => null));

  void selectColor(int colorValue) =>
      emit(state.copyWith(colorValue: colorValue));

  Future<void> submit({
    required String name,
    required String lastFourDigits,
    required int? cutoffDay,
    required int? paymentDueDay,
  }) async {
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    final current = editing;
    final result = current == null
        ? await _addCard(
            AddCardParams(
              name: name,
              type: state.type,
              lastFourDigits: lastFourDigits,
              cutoffDay: cutoffDay,
              paymentDueDay: paymentDueDay,
              colorValue: state.colorValue,
            ),
          )
        : await _updateCard(
            current.copyWith(
              name: name,
              type: state.type,
              lastFourDigits: lastFourDigits,
              cutoffDay: () => cutoffDay,
              paymentDueDay: () => paymentDueDay,
              colorValue: state.colorValue,
            ),
          );
    _emitResult(result);
  }

  Future<void> delete() async {
    final current = editing;
    if (current == null) return;
    emit(state.copyWith(status: FormStatus.submitting, error: () => null));
    _emitResult(await _deleteCard(current.id));
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
