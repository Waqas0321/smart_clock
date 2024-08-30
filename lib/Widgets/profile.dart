import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_clock/Controller/custom_matches_controller.dart';
import 'package:smart_clock/Controller/matches_controller.dart';
import 'package:smart_clock/Controller/player_matches_controller.dart';
import 'package:smart_clock/Controller/sports_new_controller.dart';
import 'package:csv/csv.dart';
import 'package:smart_clock/View/bottom_navigation.dart';
import 'package:smart_clock/homepage.dart';
import 'package:smart_clock/utils/Colors.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:dropdown_search/dropdown_search.dart';

class Profile extends StatefulWidget {
  final String screen;

  const Profile({super.key, required this.screen});

  @override
  State<Profile> createState() => _ProfileState();
}

List<String> footballTeams = [
  "Manchester City",
  "Liverpool",
  "Bayern Munich",
  "Barcelona",
  "Real Madrid",
  "Juventus",
  "Paris Saint-Germain",
  "Chelsea",
  "Arsenal",
  "Manchester United",
  "Inter Milan",
  "AC Milan",
  "Borussia Dortmund",
  "Atletico Madrid",
  "Sevilla",
  "Roma",
  "Tottenham Hotspur",
  "Ajax",
  "Porto",
  "Shakhtar Donetsk",
  "Brazil",
  "Germany",
  "Argentina",
  "Spain",
  "France",
  "England",
  "Italy",
  "Netherlands",
  "Portugal",
  "Belgium",
  "Croatia",
  "Poland",
  "Sweden",
  "Denmark",
  "Switzerland",
];

List<String> players = [
  "Lionel Messi",
  "Cristiano Ronaldo",
  "Kylian Mbappé",
  "Robert Lewandowski",
  "Kevin De Bruyne",
  "Mohamed Salah",
  "Virgil van Dijk",
  "Paul Pogba",
  "Neymar Jr.",
  "Eden Hazard",
  "Harry Kane",
  "Sergio Agüero",
  "Trent Alexander-Arnold",
  "Andrew Robertson",
  "Alisson Becker",
  "David de Gea",
  "Marc-André ter Stegen",
  "Jan Oblak",
  "Dayot Upamecano",
  "Raphael Varane",
  "Marquinhos",
  "Sergio Ramos",
  "Gerard Piqué",
  "Giorgio Chiellini",
  "Kalidou Koulibaly",
  "N'Golo Kanté",
  "Fabinho",
  "Casemiro",
  "Luka Modrić",
  "Thiago Alcântara",
];

class _ProfileState extends State<Profile> {
  List<String> selectedCountries = [];
  List<String> selectedPlayers = [];
  List<String> selectedTeam = [];
  CustomMatchesController customMatchesController =
      Get.find<CustomMatchesController>();

  // final bool _isEditingText = true;
  PlayerMatchesController controllerPlayers =
      Get.find<PlayerMatchesController>();
  MatchesController controllerMatches = Get.find<MatchesController>();
  SportsNewsController newsController = Get.find<SportsNewsController>();
  String? defaultCountryCode;
  List<String> countryList = [];
  late Map<String, String> countryCodesMap = {};

  TextEditingController searchController = TextEditingController();
  String? selectedItem;
  final TextEditingController teamController = TextEditingController();
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    loadSelectedCountries();
    loadCountries();
    loadSelectedPlayers();
    loadSelectedTeams();

    // Listen for changes in the search field
    teamController.addListener(() {
      _fetchSuggestions(teamController.text);
    });
    // customMatchesController = Get.find<CustomMatchesController>();
  }

  Future<void> _fetchSuggestions(String query) async {
    List<String> fetchedSuggestions =
        await customMatchesController.fetchSuggestions(query);
    setState(() {
      suggestions = fetchedSuggestions;
    });
  }

  Future<void> loadSelectedCountries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedCountries = prefs.getStringList('selectedCountries');

    if (savedCountries != null && savedCountries.isNotEmpty) {
      setState(() {
        selectedCountries = savedCountries;
      });
    }
    if (kDebugMode) {
      print("Selected countries: $selectedCountries");
    }
  }

  Future<String> _getCountryCode(Position position) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    return placemarks.first.isoCountryCode?.toUpperCase() ?? '';
  }
  Future<void> saveSelectedTeams(List<String> footballTeams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedTeams', footballTeams);
  }
  Future<void> loadSelectedTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedTeam = prefs.getStringList('selectedTeams') ?? [];
    });
  }

  Future<void> saveSelectedCountries(List<String> countries) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedCountries', countries);
  }

  Future<void> saveSelectedPlayers(List<String> players) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('SelectedPlayers', players);
  }
  Future<void> loadSelectedPlayers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPlayers = prefs.getStringList('SelectedPlayers') ?? [];
    });
  }

  Future<void> loadCountries() async {
    final input = await rootBundle.loadString('assets/countries.csv');
    final List<List<dynamic>> fields =
        const CsvToListConverter(eol: '\n').convert(input);

    setState(() {
      countryList = fields
          .map((field) => field[1].toString())
          .toList(); // Assuming country names are in the second column
      countryCodesMap = {
        for (var item in fields) item[1].toString(): item[0].toString()
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
            child: widget.screen == "tablet"
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Preferences",
                          style: GoogleFonts.bebasNeue(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: (orientation == Orientation.portrait)
                                ? 40.sp
                                : 30.sp,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "Enable/Disable custom search for Matches",
                              style: GoogleFonts.bebasNeue(
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                fontSize: (orientation == Orientation.portrait)
                                    ? 40.sp
                                    : 30.sp,
                              ),
                            ),
                            const Spacer(),
                            Obx(() => ToggleSwitch(
                                  minWidth: 0.12.sw,
                                  minHeight: 0.05.sw,
                                  cornerRadius: 50.0,
                                  inactiveFgColor: Colors.white,
                                  initialLabelIndex: customMatchesController
                                      .preferenceStatus.value,
                                  totalSwitches: 2,
                                  labels: const ["DISABLE", "ENABLE"],
                                  customTextStyles: [
                                    GoogleFonts.bebasNeue(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                    GoogleFonts.bebasNeue(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ],
                                  onToggle: (index) async {
                                    await customMatchesController
                                        .setCustomSearch(index!);
                                  },
                                )),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Obx(() => customMatchesController
                                    .preferenceStatus.value ==
                                1
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Add your Favourite Location for News",
                                        style: GoogleFonts.bebasNeue(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: (orientation ==
                                                  Orientation.portrait)
                                              ? 35.sp
                                              : 25.sp,
                                        ),
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        child: DropdownSearch<String>(
                                          items: countryList.where((country) {
                                            return !selectedCountries
                                                .contains(country);
                                          }).toList(),

                                          selectedItem: null,
                                          // No item should be selected
                                          itemAsString: (String? item) {
                                            return "Select "; // Always display hint text
                                          },
                                          dropdownDecoratorProps:
                                              const DropDownDecoratorProps(
                                            dropdownSearchDecoration:
                                                InputDecoration(
                                              hintText: "Select ",
                                              hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                              enabledBorder:
                                                  UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 1.0),
                                              ),
                                            ),
                                          ),

                                          onChanged: (newValue) {
                                            if (newValue != null &&
                                                newValue
                                                    .toLowerCase()
                                                    .startsWith(searchController
                                                        .text
                                                        .toLowerCase())) {
                                              setState(() {
                                                selectedCountries.add(newValue);
                                                searchController.clear();
                                                var selectedCountryCodes =
                                                    selectedCountries
                                                        .map((country) =>
                                                            countryCodesMap[
                                                                country]!)
                                                        .toList();
                                                newsController
                                                    .updateCountryCodes(
                                                        selectedCountryCodes);
                                                saveSelectedCountries(
                                                    selectedCountries);
                                              });
                                            }
                                          },
                                          popupProps: PopupProps.menu(
                                            showSearchBox: true,
                                            searchFieldProps: TextFieldProps(
                                              controller: searchController,
                                              decoration: const InputDecoration(
                                                hintText: "Search ",
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                                border: OutlineInputBorder(),
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            itemBuilder:
                                                (context, item, isSelected) {
                                              // Only display items that start with the search text
                                              if (item.toLowerCase().startsWith(
                                                  searchController.text
                                                      .toLowerCase())) {
                                                return ListTile(
                                                  title: Text(item),
                                                );
                                              } else {
                                                return Container(); // Return an empty container for non-matching items
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Selected Countries:",
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: selectedCountries.map((country) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              country,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Color.fromARGB(
                                                      255, 74, 68, 68)),
                                              onPressed: () {
                                                setState(() {
                                                  selectedCountries
                                                      .remove(country);
                                                  // Update the newsController with the new list of country codes
                                                  var selectedCountryCodes =
                                                      selectedCountries
                                                          .map((country) =>
                                                              countryCodesMap[
                                                                  country]!)
                                                          .toList();
                                                  newsController
                                                      .updateCountryCodes(
                                                          selectedCountryCodes);
                                                  saveSelectedCountries(
                                                      selectedCountries);
                                                  searchController.clear();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(children: [
                                      Text(
                                        "Add your Favourite Location for News",
                                        style: GoogleFonts.bebasNeue(
                                          fontWeight: FontWeight.w500,
                                          color: CustomColor.lightgreyColor,
                                          fontSize: (orientation ==
                                                  Orientation.portrait)
                                              ? 35.sp
                                              : 25.sp,
                                        ),
                                      ),
                                    ])
                                  ])),
                        Obx(() => customMatchesController
                                    .preferenceStatus.value ==
                                1
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Add Favourite FootBall Player",
                                              style: GoogleFonts.bebasNeue(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: (orientation ==
                                                        Orientation.portrait)
                                                    ? 35.sp
                                                    : 25.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          child: DropdownSearch<String>(
                                            items: countryList.where((country) {
                                              return !selectedCountries
                                                  .contains(country);
                                            }).toList(),

                                            selectedItem: null,
                                            // No item should be selected
                                            itemAsString: (String? item) {
                                              return "Select "; // Always display hint text
                                            },
                                            dropdownDecoratorProps:
                                                const DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                hintText: "Select ",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                              ),
                                            ),

                                            onChanged: (newValue) {
                                              if (newValue != null &&
                                                  newValue
                                                      .toLowerCase()
                                                      .startsWith(
                                                          searchController.text
                                                              .toLowerCase())) {
                                                setState(() {
                                                  selectedCountries
                                                      .add(newValue);
                                                  searchController.clear();
                                                  var selectedCountryCodes =
                                                      selectedCountries
                                                          .map((country) =>
                                                              countryCodesMap[
                                                                  country]!)
                                                          .toList();
                                                  newsController
                                                      .updateCountryCodes(
                                                          selectedCountryCodes);
                                                  saveSelectedCountries(
                                                      selectedCountries);
                                                });
                                              }
                                            },
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                controller: searchController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "Search ",
                                                  hintStyle: TextStyle(
                                                      color: Colors.black),
                                                  border: OutlineInputBorder(),
                                                ),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              itemBuilder:
                                                  (context, item, isSelected) {
                                                // Only display items that start with the search text
                                                if (item
                                                    .toLowerCase()
                                                    .startsWith(searchController
                                                        .text
                                                        .toLowerCase())) {
                                                  return ListTile(
                                                    title: Text(item),
                                                  );
                                                } else {
                                                  return Container(); // Return an empty container for non-matching items
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Obx(() => ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: customMatchesController
                                              .listOfPlayersObs.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                Text(
                                                  customMatchesController
                                                      .listOfPlayersObs[index],
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const Spacer(),
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () async {
                                                    await customMatchesController
                                                        .deletePlayer(index);
                                                    await controllerPlayers
                                                        .getMatches();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        )),
                                  ],
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: Row(
                                  children: [
                                    Text(
                                      "Add Favourite FootBall Player",
                                      style: GoogleFonts.bebasNeue(
                                        fontWeight: FontWeight.w500,
                                        color: CustomColor.lightgreyColor,
                                        fontSize: (orientation ==
                                                Orientation.portrait)
                                            ? 35.sp
                                            : 25.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        Obx(() => customMatchesController
                                    .preferenceStatus.value ==
                                1
                            ? Column(
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Add Your Favourite Football Team",
                                            style: GoogleFonts.bebasNeue(
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                              fontSize: (orientation ==
                                                      Orientation.portrait)
                                                  ? 35.sp
                                                  : 25.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 0.2.sw,
                                        child: _editTeamDropdown(),
                                      ),
                                    ],
                                  ),
                                  Obx(() => ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: customMatchesController
                                            .listOfTeamsObs.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              Text(
                                                customMatchesController
                                                    .listOfTeamsObs[index],
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                  await customMatchesController
                                                      .deleteTeam(index);
                                                  await controllerMatches
                                                      .getMatches();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      )),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    "Add your Favourite FootBall Team",
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w500,
                                      color: CustomColor.lightgreyColor,
                                      fontSize:
                                          (orientation == Orientation.portrait)
                                              ? 35.sp
                                              : 25.sp,
                                    ),
                                  ),
                                ],
                              )),
                        const SizedBox(height: 120),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ScreenUtil().screenWidth > 600
                                          ? const HomePage()
                                          : BottomNavigation(),
                                ),
                              );
                            },
                            child: const Text("save"))
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "Preferences",
                          style: GoogleFonts.bebasNeue(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 30.sp,
                            height: 0,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "Enable/Disable custom search for Matches",
                            style: GoogleFonts.bebasNeue(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          const Spacer(),
                          Obx(() => ToggleSwitch(
                                minWidth: 0.10.sw,
                                minHeight: 0.05.sw,
                                cornerRadius: 40.0,
                                inactiveFgColor: Colors.white,
                                initialLabelIndex: customMatchesController
                                    .preferenceStatus.value,
                                totalSwitches: 2,
                                labels: const ["DISABLE", "ENABLE"],
                                customTextStyles: [
                                  GoogleFonts.bebasNeue(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                                  GoogleFonts.bebasNeue(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                                ],
                                onToggle: (index) async {
                                  await customMatchesController
                                      .setCustomSearch(index!);
                                },
                              )),
                        ],
                      ),
                      Obx(() => customMatchesController
                                  .preferenceStatus.value ==
                              1
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: Get.width,
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Add Favourite FootBall Player",
                                              style: GoogleFonts.bebasNeue(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: (orientation ==
                                                        Orientation.portrait)
                                                    ? 16.sp
                                                    : 10.sp,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Gap(5),
                                        Expanded(
                                          child: DropdownSearch<String>(
                                            items: players.where((player) {
                                              return !selectedPlayers
                                                  .contains(player);
                                            }).toList(),
                                            selectedItem: null,
                                            itemAsString: (String? item) {
                                              return "Select";
                                            },
                                            dropdownDecoratorProps:
                                                const DropDownDecoratorProps(
                                              dropdownSearchDecoration:
                                                  InputDecoration(
                                                hintText: "      Select",
                                                hintStyle: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                                enabledBorder:
                                                    UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0),
                                                ),
                                              ),
                                            ),

                                            // Ensure no selected item is displayed

                                            onChanged: (newValue) {
                                              if (newValue != null &&
                                                  newValue
                                                      .toLowerCase()
                                                      .startsWith(
                                                          searchController.text
                                                              .toLowerCase())) {
                                                setState(() {
                                                  selectedPlayers.add(newValue);
                                                  // Reset selected item to null
                                                  searchController.clear();
                                                  saveSelectedPlayers(
                                                      selectedPlayers);
                                                });
                                              }
                                            },
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                controller: searchController,
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: "Search ",
                                                  hintStyle: TextStyle(
                                                      color: Colors.black),
                                                  border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.black)),
                                                ),
                                                style: const TextStyle(
                                                    color: Colors.black),
                                              ),
                                              itemBuilder:
                                                  (context, item, isSelected) {
                                                // Only display items that start with the search text
                                                if (item
                                                    .toLowerCase()
                                                    .startsWith(searchController
                                                        .text
                                                        .toLowerCase())) {
                                                  return ListTile(
                                                    title: Text(item),
                                                  );
                                                } else {
                                                  return Container(); // Return an empty container for non-matching items
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    "Selected Players:",
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: selectedPlayers.map((country) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              country,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Color.fromARGB(
                                                      255, 74, 68, 68)),
                                              onPressed: () {
                                                setState(() {
                                                  selectedPlayers
                                                      .remove(country);
                                                  searchController.clear();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 30),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  Text(
                                    "Add Favourite FootBall Player",
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w100,
                                      color: CustomColor.lightgreyColor,
                                      fontSize:
                                          (orientation == Orientation.portrait)
                                              ? 16.sp
                                              : 10.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      Obx(() => customMatchesController
                                  .preferenceStatus.value ==
                              1
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Add your Favourite Location for News",
                                      style: GoogleFonts.bebasNeue(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        fontSize: (orientation ==
                                                Orientation.portrait)
                                            ? 13.sp
                                            : 10.sp,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: countryList.where((country) {
                                          return !selectedCountries
                                              .contains(country);
                                        }).toList(),
                                        selectedItem: null,
                                        itemAsString: (String? item) {
                                          return "Select ";
                                        },
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            hintText: "      Select ",
                                            hintStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                          ),
                                        ),

                                        // Ensure no selected item is displayed

                                        onChanged: (newValue) {
                                          if (newValue != null &&
                                              newValue.toLowerCase().startsWith(
                                                  searchController.text
                                                      .toLowerCase())) {
                                            setState(() {
                                              selectedCountries.add(newValue);
                                              // Reset selected item to null
                                              searchController.clear();
                                              var selectedCountryCodes =
                                                  selectedCountries
                                                      .map((country) =>
                                                          countryCodesMap[
                                                              country]!)
                                                      .toList();
                                              newsController.updateCountryCodes(
                                                  selectedCountryCodes);
                                              saveSelectedCountries(
                                                  selectedCountries);
                                            });
                                          }
                                        },
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller: searchController,
                                            decoration: const InputDecoration(
                                              hintText: "Search ",
                                              hintStyle: TextStyle(
                                                  color: Colors.black),
                                              border: OutlineInputBorder(),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          itemBuilder:
                                              (context, item, isSelected) {
                                            // Only display items that start with the search text
                                            if (item.toLowerCase().startsWith(
                                                searchController.text
                                                    .toLowerCase())) {
                                              return ListTile(
                                                title: Text(item),
                                              );
                                            } else {
                                              return Container(); // Return an empty container for non-matching items
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Selected Countries:",
                                  style: GoogleFonts.bebasNeue(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: selectedCountries.map((country) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            country,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Color.fromARGB(
                                                    255, 74, 68, 68)),
                                            onPressed: () {
                                              setState(() {
                                                selectedCountries
                                                    .remove(country);

                                                // Update the newsController with the new list of country codes
                                                var selectedCountryCodes =
                                                    selectedCountries
                                                        .map((country) =>
                                                            countryCodesMap[
                                                                country]!)
                                                        .toList();
                                                newsController
                                                    .updateCountryCodes(
                                                        selectedCountryCodes);
                                                saveSelectedCountries(
                                                    selectedCountries);
                                                searchController.clear();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Row(children: [
                                    Text(
                                      "Add your Favourite Location for News",
                                      style: GoogleFonts.bebasNeue(
                                        fontWeight: FontWeight.w500,
                                        color: CustomColor.lightgreyColor,
                                        fontSize: (orientation ==
                                                Orientation.portrait)
                                            ? 15.sp
                                            : 10.sp,
                                      ),
                                    ),
                                  ]),
                                ])),
                      const SizedBox(height: 30),
                      Obx(() => customMatchesController
                                  .preferenceStatus.value ==
                              1
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Add Your Favourite Football Team",
                                          style: GoogleFonts.bebasNeue(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: (orientation ==
                                                    Orientation.portrait)
                                                ? 15.sp
                                                : 10.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Gap(5),
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: footballTeams.where((player) {
                                          return !selectedTeam
                                              .contains(player);
                                        }).toList(),
                                        selectedItem: null,
                                        itemAsString: (String? item) {
                                          return "Select";
                                        },
                                        dropdownDecoratorProps:
                                            const DropDownDecoratorProps(
                                          dropdownSearchDecoration:
                                              InputDecoration(
                                            hintText: "     Select",
                                            hintStyle: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 1.0),
                                            ),
                                          ),
                                        ),

                                        // Ensure no selected item is displayed

                                        onChanged: (newValue) {
                                          if (newValue != null &&
                                              newValue.toLowerCase().startsWith(
                                                  searchController.text
                                                      .toLowerCase())) {
                                            setState(() {
                                              selectedTeam.add(newValue);
                                              // Reset selected item to null
                                              searchController.clear();
                                              saveSelectedTeams(
                                                  selectedTeam);
                                            });
                                          }
                                        },
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller: searchController,
                                            decoration: const InputDecoration(
                                              hintText: "Search",
                                              hintStyle: TextStyle(
                                                  color: Colors.black),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.black)),
                                            ),
                                            style: const TextStyle(
                                                color: Colors.black),
                                          ),
                                          itemBuilder:
                                              (context, item, isSelected) {
                                            // Only display items that start with the search text
                                            if (item.toLowerCase().startsWith(
                                                searchController.text
                                                    .toLowerCase())) {
                                              return ListTile(
                                                title: Text(item),
                                              );
                                            } else {
                                              return Container(); // Return an empty container for non-matching items
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Selected Teams:",
                                  style: GoogleFonts.bebasNeue(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: selectedTeam.map((country) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            country,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Color.fromARGB(
                                                    255, 74, 68, 68)),
                                            onPressed: () {
                                              setState(() {
                                                selectedTeam
                                                    .remove(country);

                                                // Update the newsController with the new list of country codes
                                                saveSelectedTeams(
                                                    selectedTeam);
                                                searchController.clear();
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Text(
                                  "Add your Favourite FootBall Team",
                                  style: GoogleFonts.bebasNeue(
                                    fontWeight: FontWeight.w500,
                                    color: CustomColor.lightgreyColor,
                                    fontSize:
                                        (orientation == Orientation.portrait)
                                            ? 15.sp
                                            : 10.sp,
                                  ),
                                ),
                              ],
                            )),
                      const SizedBox(height: 120),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ScreenUtil().screenWidth > 600
                                        ? const HomePage()
                                        : BottomNavigation(),
                              ),
                            );
                          },
                          child: const Text("save"))
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _editPlayerTextField() {
    return TypeAheadField<String>(
      controller: customMatchesController.footballPlayer.value,
      builder: (context, controller, focusNode) {
        return TextField(
          style: const TextStyle(color: Colors.white),
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: 'Enter player name',
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        );
      },
      // textFieldConfiguration: TextFieldConfiguration(
      //   style: const TextStyle(color: Colors.white),
      //   controller: customMatchesController.footballPlayer.value,
      //   decoration: const InputDecoration(
      //     hintText: 'Enter player name',
      //     hintStyle: TextStyle(color: Colors.white),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //   ),
      // ),
      suggestionsCallback: (pattern) async {
        // Check if pattern has at least 1 character before fetching suggestions
        if (pattern.isNotEmpty) {
          try {
            return await customMatchesController
                .fetchAllPlayerSuggestions(pattern);
          } catch (e) {
            if (kDebugMode) {
              print('Exception in suggestionsCallback: $e');
            }
            return []; // Return empty list on error
          }
        } else {
          return []; // Return empty list if pattern is empty or less than 1 character
        }
      },
      debounceDuration: const Duration(milliseconds: 100),
      // Adjust debounce duration as needed
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion,
            style: const TextStyle(color: Colors.white),
          ),
          tileColor: Colors.grey[800], // Customize tile background color
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
        );
      },
      onSelected: (suggestion) {
        customMatchesController.footballPlayer.value.text = suggestion;
        customMatchesController.setPlayer();
        customMatchesController.setPlayerNew();
      },

      emptyBuilder: (context) => Container(
        padding: const EdgeInsets.all(14.0),
        child: const Text(
          'LOADING.....',
          style: TextStyle(color: Colors.white),
        ),
      ),
      decorationBuilder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: child,
        );
      },
      constraints: const BoxConstraints(
        maxHeight: 700.0, // Limit the suggestions box height if needed
      ),
      // suggestionsBoxDecoration: SuggestionsBoxDecoration(
      //   constraints: const BoxConstraints(
      //     maxHeight: 700.0, // Limit the suggestions box height if needed
      //   ),
      //   borderRadius: BorderRadius.circular(8.0),
      //   color:
      //       Colors.grey[800], // Customize suggestions box background color
      // ),
    );
  }

  Widget _editTeamDropdown() {
    return TypeAheadField<String>(
      // textFieldConfiguration: TextFieldConfiguration(
      //   style: const TextStyle(color: Colors.white),
      //   controller: customMatchesController.footballTeam.value,
      //   decoration: const InputDecoration(
      //     hintText: 'Enter player name',
      //     hintStyle: TextStyle(color: Colors.white),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //   ),
      // ),
      controller: customMatchesController.footballTeam.value,
      builder: (context, controller, focusNode) {
        return TextField(
          style: const TextStyle(color: Colors.white),
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            hintText: 'Enter player name',
            hintStyle: TextStyle(color: Colors.white),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        // Check if pattern has at least 1 character before fetching suggestions
        if (pattern.isNotEmpty) {
          try {
            return await customMatchesController.fetchSuggestions(pattern);
          } catch (e) {
            if (kDebugMode) {
              print('Exception in suggestionsCallback: $e');
            }
            return []; // Return empty list on error
          }
        } else {
          return []; // Return empty list if pattern is empty or less than 1 character
        }
      },
      debounceDuration: const Duration(milliseconds: 100),
      // Adjust debounce duration as needed
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(
            suggestion,
            style: const TextStyle(color: Colors.white),
          ),
          tileColor: Colors.grey[800], // Customize tile background color
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
        );
      },
      onSelected: (suggestion) {
        customMatchesController.footballTeam.value.text = suggestion;
        customMatchesController.setTeam();
        customMatchesController.setTeamNew();
      },
      emptyBuilder: (context) => Container(
        padding: const EdgeInsets.all(14.0),
        child: const Text(
          'LOADING.....',
          style: TextStyle(color: Colors.white),
        ),
      ),
      decorationBuilder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: child,
        );
      },
      constraints: const BoxConstraints(
        maxHeight: 700.0, // Limit the suggestions box height if needed
      ),
    );
  }
}
