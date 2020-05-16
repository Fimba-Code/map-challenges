class PlaceModel {
  String name;
  String address;
  double lat;
  double lng;
  PlaceModel(this.name, this.address, this.lat, this.lng);

  static List<PlaceModel> fromJson(Map<String, dynamic> json) {
    print("parsing data");
    List<PlaceModel> rs = List();

    var results = json['results'] as List;
    for (var item in results) {
      var p = PlaceModel(item['name'], item['formatted_address'], item['geometry']['location']['lat'], item['geometry']['location']['lng']);

      rs.add(p);
      
    }
    return rs;
  }

  static List<PlaceModel> fromJsonLatLong(Map<String, dynamic> json) {
    print("parsing data");
    List<PlaceModel> rs = List();

    var results = json['results'] as List;
    for (var item in results) {
      var p = PlaceModel(item['formatted_address'], item['formatted_address'], item['geometry']['location']['lat'], item['geometry']['location']['lng']);

      rs.add(p);
      
    }
    return rs;
  }
}