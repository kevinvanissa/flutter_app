import 'package:geolocator/geolocator.dart';

class MyGeolocation {
  Position position;

  Future<Position> getPositon() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }
}
