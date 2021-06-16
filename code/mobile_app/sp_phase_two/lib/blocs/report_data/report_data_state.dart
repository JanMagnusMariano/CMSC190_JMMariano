import 'package:equatable/equatable.dart';

import '../../models/report_model.dart';

abstract class ReportDataState extends Equatable {
  const ReportDataState();

  @override
  List<Object> get props => [];
}

class ReportEmpty extends ReportDataState {}

class ReportLoading extends ReportDataState {}

class ReportSubmitted extends ReportDataState {}

class ReportFetched extends ReportDataState {
  final List<Report> reports;
  final int lastId;
  final bool hasReachedMax;

  ReportFetched({this.reports, this.hasReachedMax, this.lastId});

  ReportFetched copyWith({
    List<Report> reports,
    bool hasReachedMax,
    int lastId,
  }) {
    return ReportFetched(
      reports: reports ?? this.reports,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastId: lastId ?? this.lastId,
    );
  }

  @override
  List<Object> get props => [reports, hasReachedMax, lastId];
}

class ReportError extends ReportDataState {}