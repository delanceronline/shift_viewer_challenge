import 'package:flutter/material.dart';
import 'data_models/shift.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class ShiftDetailView extends StatefulWidget {
  final Shift shift;

  const ShiftDetailView({super.key, required this.shift});

  @override
  State<ShiftDetailView> createState() => _ShiftDetailView();
}

class _ShiftDetailView extends State<ShiftDetailView> {

  bool _availableForClockIn = false;
  bool _availableForClockOut = false;
  bool _isWithinLocation = false;
  bool _isCheckingLocation = false;

  Future<void> _showDialog(String message)async {

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Message"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );

  }

  // initialise the location service of the device and requesting permissions
  // return current location if permission granted
  Future<Position> _initLocationService() async {

    // Test if location services are enabled.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      await _showDialog("Location services are disabled");
    }
    else{

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {

        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.

          await _showDialog("Location permissions are denied");
          return Future.error('Location permissions are denied');
        }

        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.

          await _showDialog("Location permissions are permanently denied, we cannot request permissions");
          return Future.error('Location permissions are permanently denied, we cannot request permissions');
        }

      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      return await Geolocator.getCurrentPosition();
    }

    return Future.error('Unknown error');
  }

  // calculate the distance btw current location and the shift point
  bool _isCloseToLocation(Position userPosition, Shift shift){

    double distance = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      shift.latitude,
      shift.longitude,
    );

    return distance <= 500;

  }

  void _onClockIn() async {
    _showDialog("You have successfully clocked in.");
  }

  void _onClockOut() async {
    _showDialog("You have successfully clocked out.");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // get current date time for validation
    DateTime now = DateTime.now();
    // this is for testing purpose
    //DateTime now = DateTime.parse("2025-02-18 12:59:00.000");
    DateTime shiftStart = widget.shift.startTime;
    DateTime shiftEnd = widget.shift.endTime;

    setState(() {

      // update buttons status
      _availableForClockIn = now.isAfter(shiftStart.subtract(Duration(minutes: 15))) && now.isBefore(shiftStart);
      _availableForClockOut = now.isAfter(shiftEnd.subtract(Duration(minutes: 15))) && now.isBefore(shiftEnd.add(Duration(minutes: 15)));

    });

    // only check current location when any time range matches
    if(_availableForClockIn || _availableForClockOut){

      setState(() {
        _isCheckingLocation = true;
      });
      _initLocationService().then((Position position){

        setState(() {

          _isCheckingLocation = false;

          debugPrint('${position.longitude} ${position.latitude}');
          _isWithinLocation = _isCloseToLocation(position, widget.shift);

          if(!_isWithinLocation){

            _showDialog("You are not close enough to the shift location (within 500m).").then((e){
              debugPrint('clicked');

              if(context.mounted){
                Navigator.pop(context);
              }

            });

          }

          debugPrint('isWithinLocation: $_isWithinLocation');
        });

      }).catchError((error){
        setState(() {
          _isCheckingLocation = false;
        });
      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Shift Details")),
      body:
    Center(
      child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Start time: ${DateFormat('HH:mm').format(widget.shift.startTime)}"),
            SizedBox(height: 10,),
            Text("End time: ${DateFormat('HH:mm').format(widget.shift.endTime)}"),
            SizedBox(height: 10,),
            Text("Location: ${widget.shift.latitude} ${widget.shift.longitude}"),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: _availableForClockIn && _isWithinLocation ? _onClockIn : null,
              child: Text("Clock In"),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: _availableForClockOut && _isWithinLocation ? _onClockOut : null,
              child: Text("Clock Out"),
            ),

            if(_isCheckingLocation)...[
              SizedBox(height: 20,),
              CircularProgressIndicator(),
              SizedBox(height: 10,),
              Text("Getting location from the device..."),
            ],

          ],
        ),
      ),
    );
  }
}