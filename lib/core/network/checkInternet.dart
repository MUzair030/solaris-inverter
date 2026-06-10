import 'package:dio/dio.dart';

void checkInternet() async {
  Dio dio = Dio();

  try {
    Response response = await dio.get('https://www.google.com');
    print('Response status: ${response.statusCode}');
  } catch (e) {
    print('Error: $e');
  }
}
