import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geocoder/geocoder.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Permission permission;
  Geolocator geolocator = Geolocator();

  Position userLocation;
  _askPermission() async {
    await SimplePermissions.requestPermission(permission);
  }

  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    _askPermission();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('User Locator'),
            backgroundColor: Colors.green[700],
          ),
          body: new Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                myLocationEnabled: true,
              ),
              userLocation == null
                  ? CircularProgressIndicator()
                  : Text("Location:" +
                      userLocation.latitude.toString() +
                      " " +
                      userLocation.longitude.toString()),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    _getLocation().then((value) {
                      setState(() {
                        userLocation = value;
                        print(userLocation);
                      });
                    });
                  },
                  color: Colors.blue,
                  child: Text(
                    "Show address",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }
}
