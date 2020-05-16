import 'package:google_maps_flutter/google_maps_flutter.dart';

class StepModel {
  LatLng startLocation;
  LatLng endLocation;
  StepModel({this.startLocation, this.endLocation});

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
        startLocation: LatLng(
            json["start_location"]["lat"], json["start_location"]["lng"]),
        endLocation:
            LatLng(json["end_location"]["lat"], json["end_location"]["lng"]));
  }
}
