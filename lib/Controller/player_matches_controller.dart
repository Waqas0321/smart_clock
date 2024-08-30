import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:smart_clock/Controller/custom_matches_controller.dart';
import 'package:smart_clock/Models/Player_Model.dart';
import 'package:smart_clock/utils/internet_connectivity.dart';

class PlayerMatchesController extends GetxController {
  var playersModel = PlayersModel().obs;
  CustomMatchesController customMatchesController = Get.find<CustomMatchesController>();
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

  void setPreferenceStatus(double newValue) {
    // Convert double to int? and set preferenceStatus
    customMatchesController.preferenceStatus.value = newValue.toInt();
  }

  Future<void> getMatches() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      showNoInternetSnackbar();
      return;
    }

    int status = customMatchesController.preferenceStatus.value;
    String? player = await customMatchesController.getPlayersNew();
    String url = "http://149.28.150.230:9991/nextMatchNew/players/Cristiano";

    if (status == 1 && player.isNotEmpty) {
      url = "http://149.28.150.230:9991/nextMatchNew/players/$player";
    }

    try {
      var response = await get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final responseBody = response.body;
        var js = jsonDecode(responseBody);
        playersModel.value = PlayersModel.fromJson(js);
        if (kDebugMode) {
          print(js);
        }
      } else {
        if (kDebugMode) {
          print('Failed to load matches. Status code: ${response.statusCode}');
        }
      }
    } on SocketException catch (_) {
      if (kDebugMode) {
        print('No internet connection.');
      }
    } on TimeoutException catch (_) {
      if (kDebugMode) {
        print('Request timed out.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }
}
