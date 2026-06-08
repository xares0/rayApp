import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RealNameAuthStatus { unverified, pending }

class RealNameAuthState {
  final RealNameAuthStatus status;
  final String name;
  final String idCard;

  const RealNameAuthState({
    this.status = RealNameAuthStatus.unverified,
    this.name = '',
    this.idCard = '',
  });

  RealNameAuthState copyWith({
    RealNameAuthStatus? status,
    String? name,
    String? idCard,
  }) {
    return RealNameAuthState(
      status: status ?? this.status,
      name: name ?? this.name,
      idCard: idCard ?? this.idCard,
    );
  }
}

class RealNameAuthNotifier extends StateNotifier<RealNameAuthState> {
  RealNameAuthNotifier() : super(const RealNameAuthState());

  void submit({required String name, required String idCard}) {
    state = state.copyWith(
      status: RealNameAuthStatus.pending,
      name: name,
      idCard: idCard,
    );
  }
}

final realNameAuthProvider =
    StateNotifierProvider<RealNameAuthNotifier, RealNameAuthState>(
  (ref) => RealNameAuthNotifier(),
);
