import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locationtracker/Providers/LocationProvider.dart';
import 'package:locationtracker/Screens/Login.dart';
import 'package:locationtracker/Services/NotificationService.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _currentAddress;
  Position _currentPosition;
  final cron = Cron();
  ScheduledTask scheduledTask;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition.latitude, _currentPosition.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      print(place.country);

      print(place.locality);
      print(place.administrativeArea);
      print(place.postalCode);

      print(place.subAdministrativeArea);
      print(place.isoCountryCode);

      setState(() {
        _currentAddress =
            '${place.name},${place.street},${place.subLocality}, ${place.locality},${place.subAdministrativeArea},${place.administrativeArea}, ${place.country},${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
    addAddress();
  }

  @override
  void initState() {
    _handleLocationPermission();
    _getCurrentPosition();
    tz.initializeTimeZones();
    scheduleTask();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              IconButton(
                  onPressed: () async {
                    cancelSheduleTask();
                    await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                        (route) => false);
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.black,
                  ))
            ],
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Welcome",
              style: GoogleFonts.poppins(
                  fontSize: 35, fontWeight: FontWeight.w500),
            ),
            Text(
              "Working started",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 40,
            ),
            Text(
              "Address",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                _currentAddress ?? "",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        cancelSheduleTask();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "End",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.red),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        scheduleTask();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Start",
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  scheduleTask() async {
    print("Start");
    scheduledTask = cron.schedule(Schedule.parse("*/10 * * * *"), () async {
      _getCurrentPosition();
    });
    //
  }

  void cancelSheduleTask() async {
    scheduledTask.cancel();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Logged Out',
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ));
    print("cancel");
  }

  addAddress() async {
    var data = {
      'longitude': _currentPosition.longitude.toString(),
      'latitude': _currentPosition.latitude.toString(),
      'address': _currentAddress.toString()
    };
    var res = await LocationProvider().address(data);
    print(res.body);
    final body = json.decode(res.body);

    print(res.body);

    if (res.statusCode == 200) {
      print("Location Added");
    }
  }
}
