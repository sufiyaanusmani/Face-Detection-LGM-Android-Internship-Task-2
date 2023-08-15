class ImageData {
  int faceID;
  var boundingBox;
  double? smilingProbability;
  double? leftEyeOpenProbability;
  double? rightEyeOpenProbability;

  ImageData(
      {required this.faceID,
      required this.boundingBox,
      required this.smilingProbability,
      required this.leftEyeOpenProbability,
      required this.rightEyeOpenProbability});
}
