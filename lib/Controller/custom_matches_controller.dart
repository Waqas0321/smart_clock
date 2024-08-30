import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CustomMatchesController extends GetxController {
  RxInt preferenceStatus = 1.obs;
  RxList<dynamic> listOfTeamsObs = [].obs;
  RxList<dynamic> listOfPlayersObs = [].obs;

  RxString csvTeams = "Default".obs;
  RxString csvPlayers = "Default".obs;

  Rx<TextEditingController> footballTeam = TextEditingController().obs;
  Rx<TextEditingController> footballPlayer = TextEditingController().obs;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    getCustomSearch();
    getMatchPreferenceNew();
    getTeamNew();
    getPlayersNew();
  }

  Future<void> getCustomSearch() async {
    String? customSearch = await storage.read(key: "custom_search");
    preferenceStatus.value = customSearch != null ? int.parse(customSearch) : 0;
  }

  Future<void> getMatchPreference() async {
    footballPlayer.value.text = await storage.read(key: "custom_player") ?? "Default";
    footballTeam.value.text = await storage.read(key: "custom_team") ?? "Default";
  }

  Future<void> getMatchPreferenceNew() async {
    await getTeamNew();
    await getPlayersNew();
    footballPlayer.value.text = "Default";
    footballTeam.value.text = "Default";
  }

  Future<void> setCustomSearch(int value) async {
    await storage.write(key: "custom_search", value: value.toString());
    preferenceStatus.value = value;
  }

  Future<void> setPlayer() async {
    await storage.write(key: "custom_player", value: footballPlayer.value.text);
  }

  Future<void> setTeam() async {
    await storage.write(key: "custom_team", value: footballTeam.value.text);
  }

  Future<void> setTeamNew() async {
    String? stringOfTeams = await storage.read(key: 'custom_teams');
    if (stringOfTeams != null && footballTeam.value.text.isNotEmpty && footballTeam.value.text != "Default") {
      listOfTeamsObs.value = jsonDecode(stringOfTeams);
      if (!listOfTeamsObs.contains(footballTeam.value.text)) {
        listOfTeamsObs.add(footballTeam.value.text);
        await storage.write(key: 'custom_teams', value: jsonEncode(listOfTeamsObs));
      } else {
        if (kDebugMode) {
          print("Team already exists in the list.");
        }
      }
    } else if (footballTeam.value.text.isNotEmpty && footballTeam.value.text != "Default") {
      listOfTeamsObs.value = [footballTeam.value.text];
      await storage.write(key: 'custom_teams', value: jsonEncode(listOfTeamsObs));
    }
  }

  Future<String> getTeamNew() async {
    String? stringOfTeams = await storage.read(key: 'custom_teams');
    if (stringOfTeams != null) {
      listOfTeamsObs.value = jsonDecode(stringOfTeams);
      csvTeams.value = listOfTeamsObs.join(',');
    }
    return csvTeams.value;
  }

  Future<void> deleteTeam(int index) async {
    listOfTeamsObs.removeAt(index);
    await storage.write(key: 'custom_teams', value: jsonEncode(listOfTeamsObs));
    footballPlayer.value.text = "Default";
    footballTeam.value.text = "Default";
  }

  Future<void> setPlayerNew() async {
    String? stringOfPlayers = await storage.read(key: 'custom_players');
    if (stringOfPlayers != null && footballPlayer.value.text.isNotEmpty && footballPlayer.value.text != "Default") {
      listOfPlayersObs.value = jsonDecode(stringOfPlayers);
      if (!listOfPlayersObs.contains(footballPlayer.value.text)) {
        listOfPlayersObs.add(footballPlayer.value.text);
        await storage.write(key: 'custom_players', value: jsonEncode(listOfPlayersObs));
      } else {
        if (kDebugMode) {
          print("Player already exists in the list.");
        }
      }
    } else if (footballPlayer.value.text.isNotEmpty && footballPlayer.value.text != "Default") {
      listOfPlayersObs.value = [footballPlayer.value.text];
      await storage.write(key: 'custom_players', value: jsonEncode(listOfPlayersObs));
    }
  }

  Future<String> getPlayersNew() async {
    String? stringOfPlayers = await storage.read(key: 'custom_players');
    if (stringOfPlayers != null) {
      listOfPlayersObs.value = jsonDecode(stringOfPlayers);
      csvPlayers.value = listOfPlayersObs.join(',');
    }
    return csvPlayers.value;
  }

  Future<void> deletePlayer(int index) async {
    listOfPlayersObs.removeAt(index);
    await storage.write(key: 'custom_players', value: jsonEncode(listOfPlayersObs));
    footballPlayer.value.text = "Default";
    footballTeam.value.text = "Default";
  }

  Future<String?> getTeam() async {
    return await storage.read(key: "custom_team");
  }

  Future<String?> getPlayer() async {
    return await storage.read(key: "custom_player");
  }

 Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      if (kDebugMode) {
        print('Query is empty, returning empty list.');
      }
      return [];
    }

    String apiUrl = "http://149.28.150.230:9991/nextMatch/clubs/$query";

    try {
      var response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        if (kDebugMode) {
          print('Full response data: $data');
        }

        if (data == null || !data.containsKey('search_result')) {
          if (kDebugMode) {
            print('No search_result found in response.');
          }
          return [];
        }

        List<dynamic> suggestions = data['search_result'];
        if (kDebugMode) {
          print('Raw suggestions: $suggestions');
        }

        if (suggestions.isEmpty) {
          if (kDebugMode) {
            print('No suggestions found in response.');
          }
          return [];
        }

        List<String> suggestionNames = suggestions.map((item) => item['name'].toString()).toList();
        if (kDebugMode) {
          print('All suggestion names: $suggestionNames');
        }

        String lowerCaseQuery = query.toLowerCase();
        List<String> filteredSuggestions = suggestionNames.where((name) {
          String lowerCaseName = name.toLowerCase();
          bool matches = lowerCaseName.startsWith(lowerCaseQuery);
          if (kDebugMode) {
            print('Checking if "$name" starts with or contains "$lowerCaseQuery": $matches');
          }
          return matches;
        }).toList();

        if (kDebugMode) {
          print('Filtered suggestion names: $filteredSuggestions');
        }
        return filteredSuggestions;
      } else {
        if (kDebugMode) {
          print('Failed to fetch suggestions. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to fetch suggestions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching suggestions: $e');
      }
      return [];
    }
  }

Future<List<String>> fetchAllPlayerSuggestions(String query) async {
  List<String> allSuggestions = [];
  int currentPage = 1;
  bool hasMorePages = true;

  while (hasMorePages) {
    String apiUrl = "http://149.28.150.230:9991/nextMatchNew/players/$query?page=$currentPage";
    
    try {
      var response = await http.get(Uri.parse(apiUrl));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Full response data: $data');
        }
        
        // Check Rate Limiting Headers
        if (response.headers.containsKey('X-RateLimit-Remaining')) {
          int remainingRequests = int.parse(response.headers['X-RateLimit-Remaining']!);
          if (remainingRequests == 0) {
            if (kDebugMode) {
              print('Rate limit exceeded. Waiting before retrying...');
            }
            await Future.delayed(const Duration(minutes: 1)); // Wait for rate limit reset
            continue; // Retry the current page after delay
          }
        }
        
        if (data == null || !data.containsKey('search_result') || data['search_result'] == null) {
          if (kDebugMode) {
            print('No search_result found in response.');
          }
          return allSuggestions;
        }

        List<dynamic> suggestions = data['search_result'];
        if (kDebugMode) {
          print('Raw suggestions: $suggestions');
        }
        
        if (suggestions.isEmpty) {
          hasMorePages = false;
          break;
        }
        
        List<String> suggestionNames = suggestions
            .map((item) => item['name'].toString())
            .toList();

        allSuggestions.addAll(suggestionNames);
        
        // Check for pagination metadata
        int totalPages = data['pagination']['total_pages'] ?? 1;
        if (currentPage >= totalPages) {
          hasMorePages = false;
        } else {
          currentPage++;
        }
        
      } else if (response.statusCode == 429) {
        // Rate limit exceeded, handle accordingly
        if (kDebugMode) {
          print('Rate limit exceeded. Waiting before retrying...');
        }
        await Future.delayed(const Duration(minutes: 1)); // Wait for rate limit reset
      } else {
        if (kDebugMode) {
          print('Failed to fetch suggestions. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to fetch suggestions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching suggestions: $e');
      }
      return allSuggestions;  // Return the suggestions gathered so far
    }
  }

  // Filter suggestions after all pages are fetched
  String lowerCaseQuery = query.toLowerCase();
  List<String> filteredSuggestions = allSuggestions
      .where((name) {
        String lowerCaseName = name.toLowerCase();
        bool startsWithMatch = lowerCaseName.startsWith(lowerCaseQuery);
        bool containsMatch = lowerCaseName.contains(lowerCaseQuery);
        bool matches = startsWithMatch || containsMatch;
        if (kDebugMode) {
          print('Checking if "$name" starts with or contains "$lowerCaseQuery": $matches');
        }
        return matches;
      })
      .toList();
  
  if (kDebugMode) {
    print('Filtered suggestion names: $filteredSuggestions');
  }
  return filteredSuggestions;
}}