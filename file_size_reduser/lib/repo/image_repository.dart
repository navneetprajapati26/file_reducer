import 'dart:io';
import 'package:dio/dio.dart';

import '../data/image_data.dart';

class ImageRepository {
  final Dio _dio = Dio();

  Future<ImageData> reduceImage(File image, int quality) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(image.path),
      "quality": quality,
    });

    int originalSize = image.lengthSync();

    try {
      final response = await _dio.post(
        "https://file-size-reducer.onrender.com/reduce",
        data: formData,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        return ImageData(
          bytes: response.data,
          originalSize: originalSize,
          reducedSize: response.data.length,
        );
      }
    } catch (e) {
      throw e;
    }
    throw Exception("Failed to reduce image");
  }

}
