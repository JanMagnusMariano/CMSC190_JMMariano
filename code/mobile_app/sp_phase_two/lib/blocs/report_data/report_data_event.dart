import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'dart:io';

abstract class ReportDataEvent extends Equatable {
  const ReportDataEvent();
}

class SubmitReport extends ReportDataEvent {
  final File imageFile;
  final String location, description;

  const SubmitReport({@required this.imageFile, this.location, this.description}) : assert(imageFile != null);

  @override
  List<Object> get props => [imageFile];
}

class FetchOlderReport extends ReportDataEvent {
  final String location;
//  final File imageFile;
//  final String location, description;
//
  const FetchOlderReport({this.location});

  @override
  List<Object> get props => [this.location];
}

class FetchNewerReport extends ReportDataEvent {
  final String location;

  const FetchNewerReport({this.location});

  @override
  List<Object> get props => [this.location];
}