import 'package:exinflow/constants/constants.dart';
import 'package:flutter/material.dart';

class Alert {
  static void show(BuildContext context, Map<String, dynamic> result, Map<String, dynamic> transcription) {
    final overlay = Overlay.of(context);

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: result['success'] == true ? greenMinusOne : result['success'] == false ? redMinusOne : yellowMinusOne,
              borderRadius: borderRadius,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 7.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: result['success'] == true ? greenPlusOne : result['success'] == false ? redPlusOne : yellowPlusOne
                        ),
                        child: Icon(
                          result['success'] == true ? Icons.done_rounded : result['success'] == false ? Icons.close_rounded : Icons.question_mark_rounded,
                          color: Colors.white,
                          size: 30
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(result['success'] == true || result['success'] == false)
                            Text(
                              result['success'] == true ? "Sukses" : "Gagal",
                              style: TextStyle(
                                color: result['success'] == true ? greenPlusOne : redPlusOne,
                                fontWeight: FontWeight.w500,
                                fontSize: semiVerySmall
                              ),
                            ),
                          Container(
                            width: 200,
                            child: Text(
                              result['message'],
                              style: TextStyle(
                                color: greyMinusOne,
                                fontSize: tiny
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: greyMinusTwo, width: 1),
                          borderRadius: borderRadius
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: greyMinusOne,
                            size: 20
                          ),
                          onPressed: () {
                            overlayEntry?.remove();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                if(transcription.isNotEmpty)
                  Divider(),

                if(transcription.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 7.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transcription['true'].toString(),
                              style: TextStyle(
                                fontSize: medium,
                                color: greenPlusOne
                              ),
                            ),
                            Text(
                              'Kata Ucapan',
                              style: TextStyle(
                                fontSize: tiny,
                                color: greyMinusTwo
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transcription['false'].toString(),
                              style: TextStyle(
                                fontSize: medium,
                                color: greenPlusOne
                              ),
                            ),
                            Text(
                              'Kata di Transkrip',
                              style: TextStyle(
                                fontSize: tiny,
                                color: greyMinusTwo
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transcription['diff'].toString(),
                              style: TextStyle(
                                fontSize: medium,
                                color: greenPlusOne
                              ),
                            ),
                            Text(
                              'Selisih',
                              style: TextStyle(
                                fontSize: tiny,
                                color: greyMinusTwo
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ],
            )
          )
        )
      )
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry?.remove();
    });
  }
}