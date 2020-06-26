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
Set<Marker> createdMarkers;


final places =
    new GoogleMapsPlaces(apiKey: "AIzaSyCWjbyGKi7BoRJslCL03ppjWjTjd_uBhZ0");

// void executeThis() async {
//   PlacesSearchResponse response = await places.searchByText("Hospitals near me", location: Location(12.891188,77.642537), radius: 5000,opennow: true);
//   print("Here: "+response.results.toString());
//   for(int i = 0;i<response.results.length;i++){
//     print("Here $i: "+ response.results[i].id);
//   }
//   print("Here err: "+response.errorMessage);
// }

Future<void> moveCamera(Position pos) async {
  GoogleMapController mapController = await _controller.future;

  mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
    target: LatLng(pos.latitude, pos.longitude),
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
    getLocation();
    // executeThis();
    getCurrentLocation();
    // populateStations();
    super.initState();
  }

//AIzaSyCUnf4JFv9D6xV34n4ijVKgDcmn3Jr58NM

  List<Placemark> placemark;
  // String _address;

  // void createMarker(int markerID, double lat, double lng,String title, String snip ) {    
  //     createdMarkers.add(Marker(
  //       markerId: MarkerId(markerID.toString()),
  //       position: LatLng(lat, lng),
  //       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
  //       infoWindow: InfoWindow(title: title, snippet: snip),
  //     ));      
  // }

  //double latitude, double longitude
  void getAddress(String address, int i, String name) async {
        setState(() {
      _child = mapWidget();
    });
    // placemark =
    //     await Geolocator().placemarkFromCoordinates(latitude, longitude);
    print("Address of hospital $i "+address);
    placemark = await Geolocator().placemarkFromAddress(address);
    // _address =
    //     placemark[0].name.toString() + "," + placemark[0].locality.toString();
    print("Name "+placemark[0].locality);

    initMarker(placemark[0], i.toString(),name);
    // placemark[0].subLocality


    // createMarker(i, placemark[0].position.latitude, placemark[0].position.latitude, placemark[0].name, placemark[0].locality);

    setState(() {
      _child = mapWidget();
    });

  }

  void getLocation() async {
        Position res = await Geolocator().getCurrentPosition(locationPermissionLevel: GeolocationPermission.locationAlways,desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = res;
      _currentPosition = res;
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

    PlacesSearchResponse response = await places.searchByText(
        "Hospitals",
        location: Location(_lat, _lng),
        radius: 5000,
        opennow: true);
        // response.results[0].
    for (int i = 0; i < response.results.length; i++) {
      print("Name $i: "+response.results[i].name);
      await getAddress(response.results[i].name+", "+response.results[i].formattedAddress,i,response.results[i].name);
    }
    if (response.hasNoResults ||
        response.isDenied ||
        response.isInvalid ||
        response.isNotFound)
          print("Here err: " + response.errorMessage);
    // await getAddress(_lat, _lng);
  }

  Widget mapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      // markers: createdMarkers,
      markers: Set<Marker>.of(markers.values),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      //   onMapCreated: onMapCreated,
      //markers: _createMarker(),
      buildingsEnabled: false,
      compassEnabled: true,
      indoorViewEnabled: false,
      // liteModeEnabled: true,
      trafficEnabled: false,

      initialCameraPosition: CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 15.0),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        // mapController = controller;
      },
      
      
      
    );
  }

//   populateStations() {
// //     //stations = [];
//     // Firestore.instance.collection('hospitals').getDocuments().then((docs) {
//     //   if (docs.documents.isNotEmpty) {
//     //     for (int i = 0; i < docs.documents.length; ++i) {
//     //       // stations.add(docs.documents[i].data);
//     //       initMarker(docs.documents[i].data, docs.documents[i].documentID);
//     //     }
//     //   }
//     // });


    
//   }

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  void initMarker(request, requestId, name) {
    var markerIdVal = requestId;
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
      markerId: markerId,
      position:
          LatLng(request.position.latitude,request.position.longitude),
      infoWindow: InfoWindow(
          title: "$name, ${request.subLocality}, ${request.locality}",
          snippet:
              "(${request.position})"),
      draggable: false,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
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
