import 'dart:convert';

import 'package:cron/cron.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:locationtracker/Providers/LocationProvider.dart';
import 'package:locationtracker/Screens/Login.dart';
import 'package:locationtracker/Services/NotificationService.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> requestLocationPermission() async {
    final serviceStatusLocation = await Permission.locationWhenInUse.isGranted;

    final status = await Permission.locationWhenInUse.request();

    if (status == PermissionStatus.granted) {
      print('Permission Granted');
    } else if (status == PermissionStatus.denied) {
      print('Permission denied');
    } else if (status == PermissionStatus.permanentlyDenied) {
      print('Permission Permanently Denied');
      await openAppSettings();
    }
  }

  Future<void> _getCurrentPosition() async {
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
    requestLocationPermission();
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             cancelSheduleTask();
            //           },
            //           child: Container(
            //             padding: const EdgeInsets.all(10),
            //             decoration: BoxDecoration(
            //                 border: Border.all(color: Colors.red),
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(10)),
            //             child: Center(
            //               child: Text(
            //                 "End",
            //                 style: GoogleFonts.poppins(
            //                     fontSize: 16, color: Colors.red),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       const SizedBox(
            //         width: 10,
            //       ),
            //       Expanded(
            //         child: GestureDetector(
            //           onTap: () {
            //             scheduleTask();
            //           },
            //           child: Container(
            //             padding: const EdgeInsets.all(10),
            //             decoration: BoxDecoration(
            //                 color: Colors.blue.shade400,
            //                 borderRadius: BorderRadius.circular(10)),
            //             child: Center(
            //               child: Text(
            //                 "Start",
            //                 style: GoogleFonts.poppins(
            //                     fontSize: 16, color: Colors.black),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // )
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
