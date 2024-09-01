import "package:exinflow/controllers/color.dart";
import "package:get/get.dart";
import 'package:exinflow/widgets/padding.dart';
import 'package:flutter/material.dart';
import 'package:exinflow/constants/constants.dart';
import 'package:exinflow/constants/data.dart';

class SelectColor {
  final ColorController colorController = Get.find<ColorController>();

  void show(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 350,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: Colors.white
              ),
              child: AllPadding(
                child: SingleChildScrollView(
                  child: Container(
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            shape: CircleBorder(),
                            side: BorderSide(width: 1, color: mainBlue),
                            padding: EdgeInsets.zero,
                            minimumSize: Size(45, 45),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: mainBlue,
                            size: 35
                          ),
                        ),
                    
                        Container(
                          height: 425,
                          child: GridView.count(
                            crossAxisCount: 5,
                            children: List.generate(colors.length, (index) {
                              return Center(
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Color(int.parse("FF${colors[index]}", radix: 16))
                                    ),
                                    icon: Icon(
                                      icons[icons.keys.elementAt(index)],
                                      size: 1,
                                      color: Colors.transparent,
                                    ),
                                    onPressed: () {
                                      colorController.changeColor(colors[index]);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              );
                            }),
                          ),
                        )
                      ]
                    ),
                  ),
                ),
              )
            ),
          )
        );
      }
    );
  }
}