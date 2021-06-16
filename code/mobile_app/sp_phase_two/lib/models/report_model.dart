import 'package:equatable/equatable.dart';

/// Issues:
///

// ignore: must_be_immutable
class Report extends Equatable {
  final String date, desc, reportId, location, filename;
  int id;

  static final columns = ['id', 'report_id', 'report_loc', 'date_uploaded', 'description', 'filename'];

  Report({this.id, this.reportId, this.location, this.desc, this.date, this.filename});

  @override
  List<Object> get props => [id, reportId, location, desc, date, filename];

  // For converting to receive HTTP call
  factory Report.fromJson(Map<String, dynamic> parsedJson) {
    return Report(
      reportId: parsedJson['path'],
      location: parsedJson['report_loc'],
      filename: parsedJson['filename'],
      date: parsedJson['date_uploaded'] as String,
      desc: parsedJson['description'],
    );
  }

  // For converting from local sqlite DB / cache
  factory Report.fromMap(Map<String, dynamic> dbRow) {
    return Report(
      id: dbRow['id'],
      filename: dbRow['filename'],
      reportId: dbRow['report_id'],
      location: dbRow['report_loc'],
      date: dbRow['date_uploaded'],
      desc: dbRow['description'],
    );
  }

  // For converting to send over HTTP
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map =  {
      'report_id': reportId,
      'date_uploaded': date,
      'report_loc': location,
      'description': desc,
    };

    return map;
  }

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'report_id': reportId,
      'date_uploaded': date,
      'filename': filename,
      'report_loc': location,
      'description': desc,
    };

    if (id != null) map['id'] = id;
    return map;
  }
}
