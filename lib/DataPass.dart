import 'package:flutter/material.dart';
import 'package:flutter_app_test1/cacheBox.dart';

import 'JsonObj.dart';


class DataPassWidget extends InheritedWidget{
  final CacheBox cacheBox;
  const DataPassWidget(
      {Key? key,
        required Widget child,
        required this.cacheBox}) : super(key: key, child: child);

  static of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType<DataPassWidget>()!.cacheBox;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget != this;
  }

}