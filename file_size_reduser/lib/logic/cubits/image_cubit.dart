import 'dart:io';

import 'package:bloc/bloc.dart';

import '../../repo/image_repository.dart';
import 'image_state.dart';
class ImageCubit extends Cubit<ImageState> {
  final ImageRepository repository;

  ImageCubit({required this.repository}) : super(ImageInitial());

  void reduceImage(File image, int quality) async {
    emit(ImageLoading());
    try {
      final reducedImage = await repository.reduceImage(image, quality);
      emit(ImageReduced(reducedImage: reducedImage!));
    } catch (error) {
      print(error.toString());
      emit(ImageError(error: error.toString()));
    }
  }
}
