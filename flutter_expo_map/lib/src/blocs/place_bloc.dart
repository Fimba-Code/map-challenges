import 'dart:async';
import 'package:flutter_expo_map/src/models/distance_model.dart';
import 'package:flutter_expo_map/src/services/place_service.dart';

class PlaceBloc {
  var _placeController = StreamController.broadcast();
  StreamController<List<DurationModel>> _durationController = StreamController.broadcast();
  Stream get placeStream => _placeController.stream;
  Stream<List<DurationModel>> get durationStream => _durationController.stream;

  void searchPlace(String keyword) {
    if (keyword.isNotEmpty) {
      _placeController.sink.add("start");
    }
    PlaceService.searchPlace(keyword).then((rs) {
      _placeController.sink.add(rs);
    }).catchError(() {
      //sink stop
    });
  }

  void searchPlaceLongLat(String lat, String long) {
    if (lat.isNotEmpty && long.isNotEmpty) {
      _placeController.sink.add("startLatLong");
    }
    PlaceService.searchPlaceWithLatAndLong(lat, long).then((rs) {
      _placeController.sink.add(rs);
    }).catchError((Object error) {
      print(error);
      //sink stop
    });
  }

  void getDuration(String from, String to) {
    if (from.isNotEmpty && to.isNotEmpty) {
      //_durationController.sink.add("startDuration");
    }
    PlaceService.getDistanceAndDuration(from, to).then((rs) {
      _durationController.sink.add(rs);
    }).catchError((Object error) {
      print(error);
      //sink stop
    });
  }

  void dispose() {
    _placeController.close();
    _durationController.close();
  }
}
