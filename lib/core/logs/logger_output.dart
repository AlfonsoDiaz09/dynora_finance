import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class PermissiveFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class LoggerOutput {
  static final LoggerOutput _singleton = LoggerOutput._internal();

  factory LoggerOutput() => _singleton;

  LoggerOutput._internal();

  static File? _logFile;
  static Logger? _logger;
  static String? _currentDate;

  Future<File> get logFile async {
    String fechaLogger = DateFormat("yyyy_MM_dd")
        .format(DateTime.now());
    if (_logFile == null || _currentDate != fechaLogger) {
      final Directory? appDir = await getExternalStorageDirectory();
      final Directory publicDir = Directory('${appDir!.path}/inventariosapp/logs');

      if (!await publicDir.exists()) {
        await publicDir.create(recursive: true);
      }

      String logFilePath = join(publicDir.path, "output_$fechaLogger.log");

      _logFile = File(logFilePath);
      _currentDate = fechaLogger;
    }

    return _logFile!;
  }

  Logger get logger {
    _logger ??= Logger(
      filter: PermissiveFilter(),
        printer: PrettyPrinter(),
        output: ConsoleAndFileOutput(this),
      );
    return _logger!;
  }
}

class ConsoleAndFileOutput extends LogOutput {
  final LoggerOutput logOutput;

  ConsoleAndFileOutput(this.logOutput);

  @override
  void output(OutputEvent event) async {
    final file = await logOutput.logFile;
    for (var line in event.lines) {
      String hora = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
      String logLine = "[$hora] $line";
      print(logLine);
      final randomAccessFile = file.openSync(mode: FileMode.append);
      randomAccessFile.writeStringSync('$logLine\n', encoding:  Encoding.getByName('utf-8') ?? utf8);
      randomAccessFile.closeSync();
    }
  }
}