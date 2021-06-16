import 'dart:io';
import 'dart:async';

import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class FilePrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE d MMM kk:mm:ss').format(now);
    String msg = event.message;
    //print('[$formattedDate] $msg');
    return ['[$formattedDate] $msg'];
  }
}

class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      // Get time
      writeCounter(line);
    }
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    bool hasFile = await File('$path/log.txt').exists();
    if (hasFile) {
      return File('$path/log.txt');
    } else {
      return new File('$path/log.txt').create(recursive: true);
    }
  }

  Future<File> writeCounter(String counter) async {
    final file = await _localFile;
    //print('Read from file : ' + String.fromCharCodes(file.readAsBytesSync()));
    var sink = file.openWrite(mode: FileMode.append);
    sink.write('$counter\n');
    await sink.flush();
    await sink.close();
    // Write the file
    String totalString = String.fromCharCodes(file.readAsBytesSync()) + '\n' + counter;
    return file;
  }
}
