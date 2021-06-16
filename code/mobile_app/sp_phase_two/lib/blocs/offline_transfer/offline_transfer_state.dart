import 'package:equatable/equatable.dart';

abstract class OfflineTransferState extends Equatable {
  const OfflineTransferState();
}

class OfflineTransfer extends OfflineTransferState {
  final String message;

  OfflineTransfer({this.message});

  OfflineTransfer copyWith({
    String message
  }) {
    return OfflineTransfer(
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [message];
}
