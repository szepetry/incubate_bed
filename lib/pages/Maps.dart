import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

Completer<GoogleMapController> _controller = Completer();
Position _currentPosition;

class Maps extends StatefulWidget {
  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  void initState() {
    super.initState();
    // getCurrentLocation();
    _getLocation();
  }

  // void getCurrentLocation() async {
  //   Position res = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  //   setState(() {
  //     _currentPosition = res;
  //   });
  // }

    Future<void> _getLocation() async {
    // final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    //double distanceInMeters = await Geolocator().distanceBetween(52.2165157, 6.9437819, 52.3546274, 4.8285838);

    setState(() {
      _currentPosition = position;
    });

    GoogleMapController mapController = await _controller.future;

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(_currentPosition.latitude, _currentPosition.longitude),
      zoom: 17.0,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Stack(
          children: <Widget>[
            //Main maps body
            MainMapBody(),
            //Custom defined move camera button
            Positioned(
              bottom: 120,
              left: MediaQuery.of(context).size.width - 80,
              child: RawMaterialButton(
                onPressed: () {
                  _getLocation();
                },
                child: Icon(
                  Icons.gps_fixed,
                ),
                shape: CircleBorder(),
                elevation: 4.0,
                fillColor: Colors.red,
                padding: EdgeInsets.all(15.0),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition:
          CameraPosition(target: LatLng(12.9747066, 77.6072206), zoom: 15.0),
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
