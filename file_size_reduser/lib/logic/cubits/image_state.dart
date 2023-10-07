import 'package:file_size_reduser/data/image_data.dart';

abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageReduced extends ImageState {
  final ImageData reducedImage;

  ImageReduced({required this.reducedImage});
}

class ImageError extends ImageState {
  final String error;

  ImageError({required this.error});
}
