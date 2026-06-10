import "package:typingtutor/import_export.dart";

late int millisecondStart, secondStart, minuteStart, hourofdayStart;
late int millisecondEnd, secondEnd, minuteEnd, hourofdayEnd;

void calculateTime(int firstChar) {
  if (firstChar == 0) {
    // Calendar cal = Calendar.getInstance();
    DateTime cal = DateTime.now();
    millisecondStart = cal.millisecond;
    secondStart = cal.second;
    minuteStart = cal.minute;
    hourofdayStart = cal.hour;
    millisecondEnd = cal.microsecond;
    secondEnd = cal.second;
    minuteEnd = cal.minute;
    hourofdayEnd = cal.hour;

    firstChar = 1;
  } else {
    DateTime cal = DateTime.now();
    millisecondEnd = cal.millisecond;
    secondEnd = cal.second;
    minuteEnd = cal.minute;
    hourofdayEnd = cal.hour;
  }
}

Widget getSpan({text, color}) {
  return Row(
    children: [
      Text(
        text.toString(),
        style: TextStyle(color: color ?? Colors.blue, fontSize: 30),
      ),
    ],
  );
}

List<Widget> getSplitValue(String str, List<Color> l1) {
  List<Widget> l = [];
  for (int i = 0; i < str.length; i++) {
    l.add(getSpan(text: str[i], color: l1[i]));
  }
  return l;
}

Widget getCustom({text, color, flex}) {
  return Expanded(
    flex: flex ?? 1,
    child: DottedBorder(
      borderType: BorderType.RRect,
      color: Colors.blueAccent,
      radius: const Radius.circular(2),
      borderPadding: const EdgeInsets.only(left: 1),
      child: Container(
        padding: const EdgeInsets.all(5),
        color: color,
        child: Center(
          child: Text(
            text.toString(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}

List<Widget> multipleWidget(List<String> s, List<Color> c) {
  List<Widget> l = [];
  for (int i = 0; i < s.length; i++) {
    if (s[i] == 'ENTER' || s[i] == 'CAPS' || s[i] == 'TAB' || s[i] == 'SHIFT') {
      l.add(getCustom(text: s[i], color: c[i], flex: 2));
    } else {
      l.add(getCustom(text: s[i], color: c[i]));
    }
  }
  return l;
}

int getCPM(int charsEntered) {
  int seconds = 0, speed = 0;
  if (hourofdayEnd == hourofdayStart) {
    if (minuteEnd == minuteStart) {
      seconds = (secondEnd - secondStart);
    } else if (minuteEnd > minuteStart) {
      int totalSeconds;
      totalSeconds = (minuteEnd - minuteStart) * 60;
      totalSeconds += secondEnd;
      seconds = totalSeconds - secondStart;
    }
  } else if (hourofdayEnd > hourofdayStart) {
    seconds = (hourofdayEnd - hourofdayStart) * 3600;
    if (minuteEnd == minuteStart) {
      seconds = (secondEnd - secondStart);
    } else if (minuteEnd > minuteStart) {
      int totalSeconds;
      // getting total seconds by multiplying every minute * 60
      totalSeconds = (minuteEnd - minuteStart) * 60;
      totalSeconds += secondEnd;
      seconds = seconds + (totalSeconds - secondStart);
    } else if (minuteEnd < minuteStart) {
      int startSec, endSec;
      startSec = (minuteStart * 60) + secondStart;
      endSec = (minuteEnd * 60) + secondEnd;
      seconds = seconds - (startSec - endSec);
    }
  }
  if (seconds <= 60) {
    speed = charsEntered;
  } else if (seconds > 60) {
    speed = ((charsEntered * 60) ~/ seconds);
  }
  return speed;
}
