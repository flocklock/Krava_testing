import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:krava/utils.dart';

class Buttons extends StatefulWidget {
  final Controller c = Get.find();

  List<String> options = [
    'none',
    'lies',
    'grazes',
    'ruminates',
    'stands',
    'walks',
    'runs',
    'other',
  ];
  Buttons({super.key});

  @override
  State<Buttons> createState() => _ButtonsState();
}

class _ButtonsState extends State<Buttons> {
  @override
  Widget build(BuildContext context) {
    return ChipsChoice<int>.single(
      wrapped: true,
      value: widget.c.num.value,
      onChanged: (val) => setState(() => widget.c.num.value = val),
      choiceItems: C2Choice.listFrom<int, String>(
        source: widget.options,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
    );
  }
}
