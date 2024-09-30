import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CurrencyService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> conversionRate(String source, List<String> target, String date) async {
    try {
      final now = DateTime.now().toUtc().add(Duration(hours: 7));
      final twoDaysAgo = now.subtract(Duration(days: 2));
      final formattedDate = date == 'now' ? DateFormat('yyyy-MM-dd').format(twoDaysAgo) : DateFormat('yyyy-MM-dd').parse(date).isAfter(twoDaysAgo) ? DateFormat('yyyy-MM-dd').format(twoDaysAgo) : date;

      Map<String, double> rates = {
        for (var currency in target) currency: 0
      };
      
      if(target.length > 0) {
        // for (var currency in target) {
        //   final key = 'cur_live_NhtBqAhzCUQasLI01cASoO44pyTAH2n3OcijDWex';
        //   final url = 'https://api.currencyapi.com/v3/historical?apikey=$key&currencies=$source&base_currency=$currency&date=$formattedDate';
        //   final response = await http.get(Uri.parse(url));
        //   final data = jsonDecode(response.body);
        //   rates[currency] = data['data'][source]['value'];
        // }

        if(source == 'IDR') {
          rates = {
            'USD': 15398.7608385,
          };
        }
        if(source == 'USD') {
          rates = {
            'IDR': 0.0000649403
          };
        }

        if (rates.length == target.length) {
          print({
            'success': true,
            'message': 'Sukses mendapatkan nilai tukar mata uang',
            'rates': rates
          });
          return {
            'success': true,
            'message': 'Sukses mendapatkan nilai tukar mata uang',
            'rates': rates
          };
        } else {
          print({
            'success': false,
            'message': 'Gagal mendapatkan nilai tukar mata uang',
          });
          return {
            'success': false,
            'message': 'Gagal mendapatkan nilai tukar mata uang',
          };
        }
      } else {
        print({
            'success': true,
            'message': 'Sukses mendapatkan nilai tukar mata uang',
            'rates': {}
          });
          return {
            'success': true,
            'message': 'Sukses mendapatkan nilai tukar mata uang',
            'rates': {}
          };
      }
    } catch(e) {
      print({
        'success': false,
        'message': e.toString()
      });
      return {
        'success': false,
        'message': e.toString()
      };
    }
  }
}