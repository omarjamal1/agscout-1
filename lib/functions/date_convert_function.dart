import 'package:intl/intl.dart';

String convertDateTimeDisplay(String date) {
  final DateFormat displayFormatter = DateFormat('yyyy-MM-ddThh:mm:ssZ');
  final DateFormat serverFormatter = DateFormat('dd-MM-yyyy');
  final DateTime displayDate = displayFormatter.parse(date);
  final String formatted = serverFormatter.format(displayDate);
  return formatted;
}
