// import 'package:exinflow/constants/constants.dart';
// import 'package:flutter/material.dart';

// class Alert {
//   static void show(BuildContext context, Map<String, dynamic> result) {
//     final overlay = Overlay.of(context);

//     OverlayEntry? overlayEntry;
//     overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: 50,
//         left: 0,
//         right: 0,
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//             padding: EdgeInsets.all(15),
//             decoration: BoxDecoration(
//               color: result['success'] == true ? greenMinusOne : redMinusOne,
//               borderRadius: borderRadius,
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 7.5),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: result['success'] == true ? greenPlusOne : redPlusOne
//                         ),
//                         child: Icon(
//                           result['success'] == true ? Icons.done_rounded : Icons.close_rounded,
//                           color: Colors.white,
//                           size: 30
//                         ),
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             result['success'] == true ? "Sukses" : "Gagal",
//                             style: TextStyle(
//                               color: result['success'] == true ? greenPlusOne : redPlusOne,
//                               fontWeight: FontWeight.w500,
//                               fontSize: semiVerySmall
//                             ),
//                           ),
//                           Container(
//                             width: 200,
//                             child: Text(
//                               result['message'],
//                               style: TextStyle(
//                                 color: greyMinusOne,
//                                 fontSize: tiny
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: greyMinusTwo, width: 1),
//                           borderRadius: borderRadius
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             Icons.close_rounded,
//                             color: greyMinusOne,
//                             size: 20
//                           ),
//                           onPressed: () {
//                             overlayEntry?.remove();
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 Divider(),

//                 Padding(
//                   padding: const EdgeInsets.only(top: 7.5),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '9',
//                             style: TextStyle(
//                               fontSize: medium,
//                               color: greenPlusOne
//                             ),
//                           ),
//                           Text(
//                             'Kata Ucapan',
//                             style: TextStyle(
//                               fontSize: tiny,
//                               color: greyMinusTwo
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '8',
//                             style: TextStyle(
//                               fontSize: medium,
//                               color: greenPlusOne
//                             ),
//                           ),
//                           Text(
//                             'Kata di Transkrip',
//                             style: TextStyle(
//                               fontSize: tiny,
//                               color: greyMinusTwo
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '1',
//                             style: TextStyle(
//                               fontSize: medium,
//                               color: greenPlusOne
//                             ),
//                           ),
//                           Text(
//                             'Selisih',
//                             style: TextStyle(
//                               fontSize: tiny,
//                               color: greyMinusTwo
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             )
//           )
//         )
//       )
//     );

//     overlay.insert(overlayEntry);

//     // Future.delayed(Duration(seconds: 3), () {
//     //   overlayEntry?.remove();
//     // });
//   }
// }





import 'package:exinflow/constants/constants.dart';
import 'package:flutter/material.dart';

class Alert {
  static void show(BuildContext context, Map<String, dynamic> result) {
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
              color: result['success'] == true ? greenMinusOne : redMinusOne,
              borderRadius: borderRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: result['success'] == true ? greenPlusOne : redPlusOne
                  ),
                  child: Icon(
                    result['success'] == true ? Icons.done_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 30
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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