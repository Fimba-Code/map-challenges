import 'package:flutter/material.dart';
import 'package:flutter_expo_map/src/blocs/place_bloc.dart';
import 'package:flutter_expo_map/src/models/distance_model.dart';
import 'package:flutter_expo_map/src/models/place_model.dart';
import 'package:flutter_expo_map/src/ui/home_page/widgets/go_button.dart';
import 'package:flutter_expo_map/src/utils/map_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController _controller;
  TextEditingController _textEditingController = TextEditingController();
  Position _currentPosition;
  PlaceModel place;
  PlaceBloc placeBloc = PlaceBloc();
  List<Marker> _markers = List();
  static BitmapDescriptor myIcon;
  CameraPosition initialPosition =
      CameraPosition(target: LatLng(-8.997030, 13.272295), zoom: 10);
  bool removeList = false;
  List<Polyline> routes = new List();
  MapUtil mapUtil = MapUtil();

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      _currentPosition = null;
    });

    _initCurrentLocation();
  }

  @override
  void initState() {
    super.initState();
    _initCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 2160, allowFontScaling: false);
    return SafeArea(
      child: new Scaffold(
        body: FutureBuilder<GeolocationStatus>(
            future: Geolocator().checkGeolocationPermissionStatus(),
            builder: (BuildContext context,
                AsyncSnapshot<GeolocationStatus> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data == GeolocationStatus.denied) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: Text(
                        "Permitir acesso aos serviços de localização para este aplicativo indicar o ponto inicial."),
                  ),
                );
              }
              return Stack(
                children: <Widget>[
                  GoogleMap(
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    myLocationEnabled: true,
                    initialCameraPosition: initialPosition,
                    onCameraIdle: () {},
                    onCameraMove: (CameraPosition position) {},
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      _setMapStyle(controller);
                    },
                    markers: Set<Marker>.of(_markers),
                    polylines: Set<Polyline>.of(routes),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 20, right: 20),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0x88999999),
                                        offset: Offset(0, 5),
                                        blurRadius: 5.0)
                                  ],
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Stack(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      children: <Widget>[
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          width: 40,
                                          height: 50,
                                          child: Center(
                                            child: IconButton(
                                              icon: Icon(Icons.close),
                                              onPressed: () {
                                                _textEditingController.text =
                                                    "";
                                              },
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 10.0, right: 50.0),
                                          child: TextField(
                                            controller: _textEditingController,
                                            onChanged: (s) {
                                              placeBloc.searchPlace(s);
                                            },
                                            decoration: InputDecoration(
                                                hintText: "Ponto B",
                                                border: InputBorder.none),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 2),
                                child: StreamBuilder(
                                  stream: placeBloc.placeStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data == "start") {
                                        removeList = false;
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else if (snapshot.data ==
                                          "startLatLong") {
                                        removeList = true;
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }

                                      List<PlaceModel> places = snapshot.data;

                                      if (places.isNotEmpty) {
                                        if (removeList) {
                                          _textEditingController.text =
                                              places[0].address;
                                          place = places[0];
                                        }
                                      }

                                      return removeList
                                          ? Container()
                                          : Container(
                                              child: ListView.separated(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Color(
                                                                0x88999999),
                                                            offset:
                                                                Offset(0, 5),
                                                            blurRadius: 5.0)
                                                      ],
                                                    ),
                                                    child: ListTile(
                                                      title: Text(
                                                        places
                                                            .elementAt(index)
                                                            .name,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      subtitle: Text(places
                                                          .elementAt(index)
                                                          .address),
                                                      onTap: () {
                                                        print("ontap");
                                                        _textEditingController
                                                                .text =
                                                            places
                                                                .elementAt(
                                                                    index)
                                                                .address;
                                                        //placeBloc.searchPlace("");
                                                        setState(() {
                                                          removeList = true;
                                                          place = places
                                                              .elementAt(index);
                                                        });
                                                      },
                                                    ),
                                                  );
                                                },
                                                separatorBuilder:
                                                    (context, index) => Divider(
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                                itemCount: places.length,
                                              ),
                                            );
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Center(
                        child: StreamBuilder<List<DurationModel>>(
                            stream: placeBloc.durationStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 6),
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Distance: ${snapshot.data[0].distanceDesc}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      Text(
                                        "Duration: ${snapshot.data[0].durationDesc}",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }),
                      )),
                  Positioned(
                      bottom: 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: StreamBuilder<List<DurationModel>>(
                            stream: placeBloc.durationStream,
                            builder: (context, snapshot) {
                              return AnimatedContainer(
                                duration: Duration(milliseconds: 1000),
                                width: MediaQuery.of(context).size.width,
                                margin: snapshot.hasData
                                    ? EdgeInsets.only(bottom: 50)
                                    : EdgeInsets.only(bottom: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      width: 50,
                                      height: 50,
                                    ),
                                    GoButton(
                                      title: "GO",
                                      onPressed: () {
                                        placeBloc.getDuration(
                                            "${_currentPosition.latitude}, ${_currentPosition.longitude}",
                                            "${place.lat}, ${place.lng}");
                                        _addMarker(
                                            "Local do Evento",
                                            PlaceModel(
                                                "to_address",
                                                "to_address",
                                                place.lat,
                                                place.lng));

                                        addPolyline();
                                        LatLngBounds bound = LatLngBounds(
                                            southwest: LatLng(
                                                _currentPosition.latitude,
                                                _currentPosition.longitude),
                                            northeast:
                                                LatLng(place.lat, place.lng));
                                        CameraUpdate u2 =
                                            CameraUpdate.newLatLngBounds(
                                                bound, 40);
                                        _controller.animateCamera(u2);
                                      },
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                    )
                                  ],
                                ),
                              );
                            }),
                      ))
                ],
              );
            }),
      ),
    );
  }

  _initCurrentLocation() {
    Geolocator()
      ..forceAndroidLocationManager = !true
      ..getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).then((position) async {
        if (mounted) {
          setState(() => _currentPosition = position);

          Marker marker = Marker(
            markerId: MarkerId("My Location"),
            draggable: false,
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: "Minha Localização"),
          );
          setState(() {
            place = PlaceModel("Localização Atual", "Localização Atual",
                position.latitude, position.longitude);
            _markers.add(marker);
          });

          _controller
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            bearing: 192.8334901395799,
            target: LatLng(position.latitude, position.longitude),
            tilt: 0,
            zoom: 15.4746,
          )));
        }
      }).catchError((e) {
        //
      });
  }

  addPolyline() async {
    if (_markers.length > 1) {
      mapUtil
          .getRoutePath(
              LatLng(_markers[0].position.latitude,
                  _markers[0].position.longitude),
              LatLng(_markers[1].position.latitude,
                  _markers[1].position.longitude))
          .then((locations) {
        List<LatLng> path = new List();

        locations.forEach((location) {
          path.add(new LatLng(location.latitude, location.longitude));
        });

        final Polyline polyline = Polyline(
          polylineId: PolylineId(_markers[1].position.latitude.toString() +
              _markers[1].position.longitude.toString()),
          consumeTapEvents: true,
          color: Color(0xFFFFB400),
          width: 4,
          points: path,
        );

        setState(() {
          routes.add(polyline);
        });
      });
    }
  }

  void _addMarker(String mkId, PlaceModel place) async {
    // remove old
    _markers.remove(mkId);

    if (place.name == "to_address") {
      Marker marker = Marker(
          markerId: MarkerId(mkId),
          draggable: false,
          position: LatLng(place.lat, place.lng),
          infoWindow: InfoWindow(title: mkId),
          icon: myIcon);
      setState(() {
        _markers.add(marker);
      });
    } else {
      Marker marker = Marker(
        markerId: MarkerId(mkId),
        draggable: false,
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(title: mkId),
      );
      setState(() {
        _markers.add(marker);
      });
    }
  }

  void _setMapStyle(GoogleMapController controller) async {
    String value =
        await DefaultAssetBundle.of(context).loadString("assets/mapstyle.json");
    controller.setMapStyle(value);
  }
}
