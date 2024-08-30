import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_clock/Models/Sportsnew_Model.dart';
import 'package:smart_clock/utils/internet_connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SportsNewsController extends GetxController {
  var sportsNewsModel = SportsNewsModel().obs;
  RxList<Articles> filteredNews = <Articles>[].obs;
  RxList<String> countryCodes = <String>[].obs;
  RxBool isLoading = false.obs;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    getSportsNews();
  }

  @override
  void onClose() {
    // Perform any necessary cleanup here
    // For example, cancel any ongoing streams or subscriptions
    // If you have any StreamSubscription, you should cancel them here
    // subscription?.cancel();

    super.onClose();
  }

  void updateCountryCodes(List<String> codes) {
    countryCodes.value = codes;
    getSportsNews();
  }

  void search(String query) {
    filteredNews.value = sportsNewsModel.value.articles!
        .where((item) => item.title?.toLowerCase().contains(query.toLowerCase()) ?? false)
        .toList();
  }

  Future<void> getSportsNews() async {
    try {
      isLoading.value = true;
      final ConnectivityResult result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        showNoInternetSnackbar();
        return;
      }

      List<Articles> allArticles = [];
      List<String> codes = countryCodes;

      // If no country codes are selected, get the current country code
      if (codes.isEmpty) {
        String? currentCountryCode = await getCurrentCountryCode();
        if (currentCountryCode != null) {
          codes = [currentCountryCode];
        }
      }

      for (String code in codes) {
        var news = await fetchNewsForCountry(code);
        if (news.articles != null) {
          allArticles.addAll(news.articles!);
        }
      }
      sportsNewsModel.value = SportsNewsModel(articles: allArticles);
      filteredNews.value = allArticles;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching news: $e');
      }
      //showGenericErrorSnackbar(); // Implement this method to show a generic error message
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getCurrentCountryCode() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      return placemarks.first.isoCountryCode?.toUpperCase();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current country code: $e');
      }
      return null;
    }
  }

  Future<SportsNewsModel> fetchNewsForCountry(String countryCode) async {
    String url =
        "https://newsapi.org/v2/top-headlines?country=$countryCode&category=sports&apiKey=47f36ad2067d412eacd68507c7529c9c";

    try {
      var response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        var js = jsonDecode(responseBody);
        return SportsNewsModel.fromJson(js);
      } else {
        throw Exception('Failed to load news');
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('Not connected!');
      }
      throw Exception('No Internet Connection');
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print('TimeOut Exception');
      }
      throw Exception('Request Timeout');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      throw Exception('Failed to fetch news');
    }
  }
}
