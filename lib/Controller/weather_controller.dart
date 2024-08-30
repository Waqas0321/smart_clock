import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:smart_clock/Models/airquality_model.dart';
import 'package:smart_clock/Models/Weather_Model.dart';
import 'package:smart_clock/utils/internet_connectivity.dart';

class WeatherController extends GetxController{
  late var weatherModel = WeatherModel().obs;
  late var airqualityModel = AirqualityModel().obs;
  RxString conditionImage = "assets/weather/weather.png".obs;
  final Connectivity _connectivity = Connectivity();
  @override
  void onInit()
  {
    super.onInit();
    getWeatherData();
    getAirQualityData();
  }
  

  Future<void> getWeatherData() async{
    Position position = await getLocationPermission();

    
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoInternetSnackbar();
    }
    String url = "http://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=244051b761f3bc4b510614ace5464aa5&units=metric";

    try
    {
      var response = await get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if(response.statusCode == 200)
      {
        final responseBody = response.body;
        var js =jsonDecode(responseBody);
        weatherModel.value = WeatherModel.fromJson(js);
        if (weatherModel.value.weather![0].description == "clear sky") {
          conditionImage.value = "assets/weather/clearSky.png";
        } else if (weatherModel.value.weather![0].description == "few clouds") {
          conditionImage.value = "assets/weather/fewClouds.png";
        } else if (weatherModel.value.weather![0].description == "scattered clouds") {
          conditionImage.value = "assets/weather/scatteredClouds.png";
        } else if (weatherModel.value.weather![0].description == "broken clouds") {
          conditionImage.value = "assets/weather/brokenClouds.png";
        } else if (weatherModel.value.weather![0].description == "shower rain") {
          conditionImage.value = "assets/weather/rain.png";
        } else if (weatherModel.value.weather![0].description == "rain") {
          conditionImage.value = "assets/weather/rain.png";
        } else if (weatherModel.value.weather![0].description == "thunderstorm") {
          conditionImage.value = "assets/weather/thunderstorm.png";
        } else if (weatherModel.value.weather![0].description == "snow") {
          conditionImage.value = "assets/weather/snow.png";
        } else if (weatherModel.value.weather![0].description == "mist") {
          conditionImage.value = "assets/weather/mist.png";
        } else if (weatherModel.value.weather![0].description == "overcast clouds") {
          conditionImage.value = "assets/weather/scatteredClouds.png";
        } else {
          conditionImage.value = "assets/weather/weather.png";
        }
        if (kDebugMode) {
          print("Latitude: ${position.latitude} Longitude: ${position.longitude}");
        }
      }
    }
    on SocketException catch (_) {
      if (kDebugMode) {
        print('Not connected!');
      }
    }
    on TimeoutException catch (_) {
      if (kDebugMode) {
        print('TimeOut Exception');
      }
    }
    catch(e)
    {
      if (kDebugMode) {
        print(e);
      }
    }
    
  }

  Future<void> getAirQualityData() async{
    Position position = await getLocationPermission();
    String url = "http://api.openweathermap.org/data/2.5/air_pollution?lat=${position.latitude}lon=${position.longitude}&appid=244051b761f3bc4b510614ace5464aa5";
        final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoInternetSnackbar();
    }
    try
    {
      var response = await get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if(response.statusCode == 200)
      {
        final responseBody = response.body;
        var js =jsonDecode(responseBody);
        airqualityModel.value = AirqualityModel.fromJson(js);

        if (kDebugMode) {
          print(js);
        }
      }
    }
    on SocketException catch (_) {
      if (kDebugMode) {
        print('Not connected!');
      }
    }
    on TimeoutException catch (_) {
      if (kDebugMode) {
        print('TimeOut Exception');
      }
    }
    catch(e)
    {
      if (kDebugMode) {
        print(e);
      }
    }
    
  }


  Future<Position> getLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    late Position position;
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoInternetSnackbar();
    }
    if( !( await Geolocator.isLocationServiceEnabled()) ) 
    {
      await Geolocator.openLocationSettings();
    }
    else{
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if(serviceEnabled)
      {
        if (kDebugMode) {
          print("GPS ENABLED");
        }
      }
      if (kDebugMode) {
        print(serviceEnabled);
      }

      if(serviceEnabled && (await Geolocator.checkPermission()) == LocationPermission.denied )
      {
        await Geolocator.requestPermission();
      }
      permission = await Geolocator.checkPermission();

      if ((permission == LocationPermission.whileInUse) || (permission == LocationPermission.always)) {
          position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
          return position;
      }
    }
    return Position(latitude: 40.69841754657531, longitude: -73.91096079482604, timestamp: DateTime.now(), accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);
  }
  
  


}