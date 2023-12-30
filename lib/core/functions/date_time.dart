import 'package:intl/intl.dart';

class DateTimeAction{


  static String getDateTime(int timestamp){
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
     
     //format date
      String formattedDate = DateFormat('MMM dd ,yyyy - HH:mm a').format(date);
    return formattedDate;
  }
}