String getDateString(DateTime dateTime) {
    String dd = dateTime.day < 10 ? "0${dateTime.day}" : "${dateTime.day}";
    String mm = dateTime.month < 10 ? "0${dateTime.month}" : "${dateTime.month}";
    String yy = dateTime.year < 10 ? "0${dateTime.year}" : "${dateTime.year}";

    String hr = dateTime.hour < 10 ? "0${dateTime.hour}" : "${dateTime.hour}";
    String mn = dateTime.minute < 10 ? "0${dateTime.minute}" : "${dateTime.minute}";
    return "$dd/$mm/$yy $hr:$mn";

}

// ignore: missing_return
int dayFromString(String? s){
  if(s == null)
    return -1;

  switch(s){
    case 'Jan':
      return 1;
    case 'Feb':
      return 2;
    case 'Mar':
      return 3;
    case 'Apr':
      return 4;
    case 'May':
      return 5;
    case 'Jun':
      return 6;
    case 'Jul':
      return 7;
    case 'Aug':
      return 8;
    case 'Sep':
      return 9;
    case 'Oct':
      return 10;
    case 'Nov':
      return 11;
    case 'Dec':
      return 12;
  }

  return -1;
}


String dateToSimpleString(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

String dateAndHourToSimpleString(DateTime date) {
  return '${date.day}/${date.month}/${date.year} ${date.hour<10? '0${date.hour}' :date.hour }:${date.minute<10? '0${date.minute}' :date.minute }';
}

String shortestDate(DateTime date){
  var now = DateTime.now();
  print("diff=${now.difference(date).inHours}");
  print(now.day == date.day && now.month == date.month && now.year == date.year);
  // today
  if(now.day == date.day && now.month == date.month && now.year == date.year)
    return "${date.hour}:${date.minute}";

  return "${date.day}/${date.month}";
}

String getInDayDate(DateTime dateTime){
  String hr = dateTime.hour < 10 ? "0${dateTime.hour}" : "${dateTime.hour}";
  String mn = dateTime.minute < 10 ? "0${dateTime.minute}" : "${dateTime.minute}";
  return "$hr:$mn";

}

DateTime stringToDate(String dayString, {String? format}) {
  if(format == "dd/mm/yyyy"){
    var parts = dayString.split('/');
    if(parts.length != 3)
      return DateTime(1,1,1900);

    var day = int.parse(parts[0]);
    var month = int.parse(parts[1]);
    var year = int.parse(parts[2]);

    return DateTime(year ,month ,day);
  }

  else if(format == "dd/mm/yyyy HH:MM"){

    var parts = dayString.split('/');
    if(parts.isEmpty)
      return DateTime(DateTime.now().year);

    var day = int.parse(parts[0]);
    var month = int.parse(parts[1]);
    var year = int.parse(parts[2].split(' ')[0]);
    var hour = int.parse(parts[2].split(' ')[1].split(':')[0]);
    var minute = int.parse(parts[2].split(' ')[1].split(':')[1]);

    return DateTime(year ,month ,day, hour, minute);
  }

//  ex: Sun Jan 05 2020 22:35:20
  var parts = dayString.split(' ');
  var year = int.parse(parts[3]);
  var month = dayFromString(parts[1]);
  var day = int.parse(parts[2]);
  var hour = int.parse(parts[4].split(':')[0]);
  var minute = int.parse(parts[4].split(':')[1]);
  var second = int.parse(parts[4].split(':')[2]);


  return DateTime(year ,month ,day,hour,minute,second);

//  [int month = 1,
//  int day = 1,
//  int hour = 0,
//  int minute = 0,
//  int second = 0,

}


