import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HelperFunction {
  static Color? getColor(String value) {

    if(value == 'Green') {
      return Colors.green;
    } else if (value == 'Green') {
      return Colors.green;
    } else if (value == 'Red') {
      return Colors.red;
    } else if (value == 'Blue') {
      return Colors.blue;
    } else if (value == 'Pink') {
      return Colors.pink;
    } else if (value == 'Grey') {
      return Colors.grey;
    } else if (value == 'Purple') {
      return Colors.grey;
    } else if (value == 'Black') {
      return Colors.black;
    } else if (value == 'White') {
      return Colors.white;
    } else if (value == 'Brown') {
      return Colors.brown;
    } else if (value == 'Teal') {
      return Colors.teal;
    } else if (value == 'Indigo'){
      return Colors.teal;
    } else {
      return null;
    }
    }

    static void navigateScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    }

    static void navigateScreenReplacement(BuildContext context, Widget screen) {
      Navigator.pushReplacement(context, 
      MaterialPageRoute(builder: (_) => screen),
      );
    }

    static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
    }

    static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness ==Brightness.dark;
    }

  static String getFormattedDate(DateTime date, {String format = 'dd MMM yyy'}) {
    return DateFormat(format).format(date);
  }
  
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }
  
  static List<Widget> wrapWidgets(List<Widget> widgets, int rowSize) {
    final wrappedList = <Widget>[];
    for (var i = 0; i < widgets.length; i += rowSize) {
      final rowChildren = widgets.sublist(i, i + rowSize > widgets.length ? widgets.length : i + rowSize);
          wrappedList.add(Row(children: rowChildren));
    }
    return wrappedList;
  }

  static void scrollToBottom(ScrollController controller, {Duration duration = const Duration(milliseconds: 300)}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: duration,
          curve: Curves.easeOut,
        );
      }
    });
  }
}
