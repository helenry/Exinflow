import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SpeechRecognitionService {
  Timestamp timestamp = Timestamp.now();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getWords(String dir, bool usePrompt) async {
    try {
      final fileDir = await getApplicationDocumentsDirectory();
      final filePath = path.join(fileDir.path, 'audio', 'speech.wav');
      final file = File(filePath);

      if (await file.exists()) {
        await file.readAsBytes();
      }

      final url = 'https://api.openai.com/v1/audio/transcriptions';
      final token= 'sk-proj-KUtseCK4nIuAO6ClxqsYT3BlbkFJmhIacXwhebjkJLgCQjxQ';

      var request = http.MultipartRequest('POST', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['model'] = 'whisper-1'
        ..fields['prompt'] = usePrompt == true ? "Transcribe to Indonesia. Transcription examples: Tambah transaksi uang masuk 1530000 ke Flazz kategori top-up, Tambah transaksi uang keluar 17400 dari ShopeePay kategori transportasi, Tambah transaksi transfer 630000 dari BCA ke GoPay, Tambah catatan tabungan masuk rumah 1380000 dari Line Bank, Tambah catatan tabungan keluar rumah 1900000000 dari Bank Mandiri, 1293000, 1233299000, 86722000, 1200000" : ''
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('audio', 'wav'),
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