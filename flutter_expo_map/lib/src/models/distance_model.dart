class DurationModel {
  String distanceDesc;
  String durationDesc;
  int distance;
  int duration;
  DurationModel(
      this.distanceDesc, this.durationDesc, this.distance, this.duration);

  static List<DurationModel> fromJson(Map<String, dynamic> json) {
    print("parsing data");
    List<DurationModel> rs = List();

    var results = json['rows'] as List;
    for (var item in results) {
      print(item['elements'][0]['distance']['text']);
      var p = DurationModel(
        item['elements'][0]['distance']['text'],
        item['elements'][0]['duration']['text'],
        item['elements'][0]['distance']['value'],
        item['elements'][0]['duration']['value'],
      );

      rs.add(p);
    }
    return rs;
  }
}
