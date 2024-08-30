import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:smart_clock/Controller/custom_matches_controller.dart';
import 'package:smart_clock/Models/matches_model.dart';
import 'package:smart_clock/utils/internet_connectivity.dart';
class MatchesController extends GetxController {
  var matchesModel = MatchesModel().obs;
  var suggestions = [].obs;
  CustomMatchesController customMatchesController = Get.find<CustomMatchesController>();
  RxBool matchtype = false.obs;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    getMatches();
  }

  @override
  void onClose() {
    // Perform any necessary cleanup here
    // For example, cancel any ongoing streams or subscriptions
    // If you have any StreamSubscription, you should cancel them here
    // subscription?.cancel();

    super.onClose();
  }

  Future<void> getMatches() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoInternetSnackbar();
      return;
    }

    int status = customMatchesController.preferenceStatus.value;
    String? team = await customMatchesController.getTeamNew();
    String url = "http://149.28.150.230:9991/nextMatchNew/clubs/arsenal";

    if (status == 1 && team != "") {
      url = "http://149.28.150.230:9991/nextMatchNew/clubs/$team";
    }

    try {
      var response = await get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        var js = jsonDecode(responseBody);
        matchesModel.value = MatchesModel.fromJson(js);
        if (kDebugMode) {
          print(js);
        }
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('Not connected!');
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print('Timeout Exception');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> fetchSuggestions(String query) async {
    String apiUrl = "http://149.28.150.230:9991/nextMatch/clubs/$query";
    try {
      var response = await get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        suggestions.value = data['search_result'];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
