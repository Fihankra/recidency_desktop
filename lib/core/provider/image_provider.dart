import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImagePicked {
  XFile? image;
  bool isCaptured;
  String? error;
  ImagePicked({this.image, this.isCaptured = false, this.error});

  //copy with
  ImagePicked copyWith({XFile? image, bool? isCaptured, String? error}) {
    return ImagePicked(
        image: image ?? this.image,
        isCaptured: isCaptured ?? this.isCaptured,
        error: error ?? this.error);
  }
}

final imageProvider =
    StateNotifierProvider.autoDispose<ImageProvider, ImagePicked>((ref) => ImageProvider());

class ImageProvider extends StateNotifier<ImagePicked> {
  ImageProvider() : super(ImagePicked());

  void setImage({XFile? image, bool isCaptured = false}) {
    state = state.copyWith(image: image, isCaptured: isCaptured);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }


}
