import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/geolocation.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/timezone.dart';

Completer<GoogleMapController> _controller = Completer();
Marker marker;
Position _currentPosition;

final places = new GoogleMapsPlaces(apiKey: "AIzaSyCWjbyGKi7BoRJslCL03ppjWjTjd_uBhZ0");

void executeThis() async {
  PlacesSearchResponse response = await places.searchByText("Covid hospitals near me",location: Location(12.8899504,77.6459123));
  print("Here 1: "+response.results[0].name);
  print("Here 2: "+response.errorMessage);
}

Future<void> moveCamera() async {
  GoogleMapController mapController = await _controller.future;

  mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
    zoom: 17.0,
  )));
}

class MainMapBody extends StatefulWidget {
  @override
  _MainMapBodyState createState() => _MainMapBodyState();
}

class _MainMapBodyState extends State<MainMapBody> {
  GoogleMapController mapController;
  Position position;
  Widget _child;

  @override
  void initState() {
    // executeThis();
    getCurrentLocation();
    populateStations();
    super.initState();
  }

//AIzaSyCUnf4JFv9D6xV34n4ijVKgDcmn3Jr58NM

  List<Placemark> placemark;
  String _address;

  void getAddress(double latitude, double longitude) async {
    placemark =
        await Geolocator().placemarkFromCoordinates(latitude, longitude);
    _address =
        placemark[0].name.toString() + "," + placemark[0].locality.toString();
    setState(() {
      _child = mapWidget();
    });
  }

  void getCurrentLocation() async {
    Position res = await Geolocator().getCurrentPosition();
    setState(() {
      position = res;
      _currentPosition = res;
    });

    var _lat = position.latitude;
    var _lng = position.longitude;
    await getAddress(_lat, _lng);
  }



  Widget mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      markers: Set<Marker>.of(markers.values),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      //   onMapCreated: onMapCreated,
      //markers: _createMarker(),
      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 15.0),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }

    populateStations() {
//     //stations = [];
    Firestore.instance
        .collection('hospitals')
        .getDocuments()
        .then((docs) {
      if (docs.documents.isNotEmpty) {
        for (int i = 0; i < docs.documents.length; ++i) {
          // stations.add(docs.documents[i].data);
          initMarker(docs.documents[i].data, docs.documents[i].documentID);
        }
      }
    });
  }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initMarker(request, requestId) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position:
          LatLng(request['location'].latitude, request['location'].longitude),
      infoWindow: InfoWindow(title: request['name'], snippet: "(${request['location'].latitude},${request['location'].longitude})"),
      draggable: false,
    );

    setState(() {
      markers[markerId] = marker;
      print(markerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _child);
  }
}
