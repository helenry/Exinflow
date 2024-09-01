import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class SpeechRecognitionService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getWords(String source, List<String> target, String date) async {
    try {
      final byteData = await rootBundle.load('assets/speech.mp3');
      final file = File.fromRawPath(byteData.buffer.asUint8List());

      final url = 'https://api.openai.com/v1/audio/transcriptions';
      final token= 'sk-proj-KUtseCK4nIuAO6ClxqsYT3BlbkFJmhIacXwhebjkJLgCQjxQ';

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['model'] = 'whisper-1'
        // ..fields['prompt'] = "Transcribe to Indonesia, use words not number for the money nominal, and don't include the currency. The transcript will consist of 3 parts: (1) Incoming or outgoing; (2) Amount of money. Please just return the number without Rp; (3) Account or wallet name. The account or wallet name (last word) can be the following bank names: BCA, Mandiri, BRI, OCBC, Flazz, e-money; (4) Transcription example: uang keluar 5500 e-money kategori makanan"
        ..fields['prompt'] = "Transcribe to Indonesia: (1) Transcription examples: tambah transaksi uang keluar 5500 e-money kategori makanan, tambah ; "
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('audio', 'mp3'),
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        final text = jsonResponse['text'];

        print({
          'success': true,
          'message': 'Sukses mendapatkan kata-kata',
          'text': text
        });
        return {
          'success': true,
          'message': 'Sukses mendapatkan kata-kata',
          'text': text
        };
      } else {
        print({
          'success': false,
          'message': 'Gagal mendapatkan kata-kata',
          'data': ''
        });
        return {
          'success': false,
          'message': 'Gagal mendapatkan kata-kata',
          'data': ''
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