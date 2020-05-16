import 'dart:async';
import 'package:flutter_expo_map/src/models/distance_model.dart';
import 'package:flutter_expo_map/src/models/place_model.dart';
import 'package:flutter_expo_map/src/models/step_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

String placeBaseUrl = "https://maps.googleapis.com/maps/api/";

class PlaceService {
  static Future<List<PlaceModel>> searchPlace(String keyWord) async {
    String url =
        "${placeBaseUrl}place/textsearch/json?key=AIzaSyCDmOVyxl5q0kgN1zZHMZHKHTsruzRN1bE&language=pt&query=" +
            Uri.encodeQueryComponent(keyWord);

    print("search >>: " + url);
    var res = await http.get(url);
    if (res.statusCode == 200) {
      print(res.body);
      return PlaceModel.fromJson(json.decode(res.body));
    } else {
      return List();
    }
  }

  static Future<List<PlaceModel>> searchPlaceWithLatAndLong(
      String lat, String long) async {
    String url =
        "${placeBaseUrl}geocode/json?latlng=$lat,$long&key=AIzaSyCDmOVyxl5q0kgN1zZHMZHKHTsruzRN1bE";

    print("search >>: " + url);
    var res = await http.get(url);
    if (res.statusCode == 200) {
      print(res.body);
      return PlaceModel.fromJsonLatLong(json.decode(res.body));
    } else {
      return List();
    }
  }

  static Future<List<DurationModel>> getDistanceAndDuration(
      String from, String to) async {
    String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$from&destinations=$to&key=AIzaSyCDmOVyxl5q0kgN1zZHMZHKHTsruzRN1bE";

    print("get distance >>: " + url);
    var res = await http.get(url);
    if (res.statusCode == 200) {
      print(res.body);
      return DurationModel.fromJson(json.decode(res.body));
    } else {
      return List();
    }
  }

  static Future<dynamic> getStep(
      double lat, double lng, double tolat, double tolng) async {
    String str_origin = "origin=" + lat.toString() + "," + lng.toString();
    // destination of route
    String str_dest =
        "destination=" + tolat.toString() + "," + tolng.toString();
    //sensor enabled
    String sensor = "sensor=false";
    String mode = "mode=driving";
    //building the parameters to the web service
    String parameters = str_origin + "&" + str_dest + "&" + sensor + "&" + mode;
    //output format
    String output = "json";
    //building the url to the webservice
    String url = "${placeBaseUrl}directions/" +
        output +
        "?origin=" +
        parameters +
        "&key=AIzaSyCDmOVyxl5q0kgN1zZHMZHKHTsruzRN1bE";
    final JsonDecoder _decoder = JsonDecoder();
    return http.get(url).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        res = "{\"status\":" +
            statusCode.toString() +
            ",\"message\":\"error\",\"response\":" +
            res +
            "}";
        throw Exception(res);
      }

      List<StepModel> steps;
      try {
        steps =
            _parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
      } catch (e) {
        throw new Exception(res);
      }
    });
  }

  static List<StepModel> _parseSteps(final responseBody) {
    var list = responseBody
        .map<StepModel>((json) => StepModel.fromJson(json))
        .toList();

    return list;
  }
}
