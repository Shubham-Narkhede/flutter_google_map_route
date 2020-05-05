import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map_route/map_request.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  bool loading = true;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  Set<Polyline> get polyLines => _polyLines;
  Completer<GoogleMapController> _controller = Completer();
  static LatLng latLng;
  LocationData currentLocation;


  // Future<Position> locateUser() async {
  //   return Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  // }

  @override
  void initState() {
    setState(() {
      getLocation();
    });
    // loading = true;
    super.initState();
  }

  // getUserLocation() async {
  //   __currentLocation = await locateUser();
  //   setState(() {
  //     latLng = LatLng(__currentLocation.latitude, __currentLocation.longitude);
  //     _onAddMarkerButtonPressed();
  //   });
  //   print('center:====== $latLng');
  // }


   getLocation() async {

    var location = new Location();
    location.onLocationChanged().listen((  currentLocation) {

      print(currentLocation.latitude);
      print(currentLocation.longitude);
      setState(() {

        latLng =  LatLng(currentLocation.latitude, currentLocation.longitude);
       });

      print("getLocation:$latLng");
      _onAddMarkerButtonPressed();
      loading = false;
    });

  }



  void _onAddMarkerButtonPressed() {
     setState(() {
      _markers.add(Marker(
         markerId: MarkerId("111"),
        position: latLng,
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
   }


  void onCameraMove(CameraPosition position) {
    latLng = position.target;
   }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void sendRequest() async {
    LatLng destination = LatLng(20.008751, 73.780037);
    String route = await _googleMapsServices.getRouteCoordinates(
        latLng, destination);
    createRoute(route);
    _addMarker(destination,"KTHM Collage");
  }

  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(latLng.toString()),
        width: 4,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.red));
  }

  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
      markerId: MarkerId("112"),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
     do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
       if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

     for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }

  @override
  Widget build(BuildContext context) {
//    print("getLocation111:$latLng");
    return new Scaffold(

      body:
      GoogleMap(
        polylines: polyLines,
        markers: _markers,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: latLng,
          zoom: 14.4746,
        ),
        onCameraMove:  onCameraMove,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          sendRequest();
        },
        label: Text('Destination'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }
}






