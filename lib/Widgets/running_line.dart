import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:country_icons/country_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_clock/utils/Colors.dart';

class RunningLines extends StatefulWidget {
  const RunningLines({super.key});

  @override
  State<RunningLines> createState() => _RunningLinesState();
}

class _RunningLinesState extends State<RunningLines> {
  final bool _isDataLoaded = false;
  List<Map<String, String>> _countries = [];
  List<String> _selectedCountryCodes = [];
  final List<Map<String, String>> _keywordNewsPairs = [];
  bool _isLoading = false;
 // String _currentCountryName = 'No COUNTRY IS SELECTED'; // Default country name
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    _loadCountries().then((_) {
      if (!_isDataLoaded) {
        _loadSelectedCountries();
      }
      _getCurrentCountry();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCountries() async {
    try {
      final input = await rootBundle.loadString('assets/countries.csv');
      final fields = const CsvToListConverter(eol: '\n').convert(input);

      setState(() {
        _countries = fields.map((field) {
          return {
            'name': field[1].toString(),
            'code': field[0].toString(),
          };
        }).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading CSV: $e');
      }
    }
  }

  Future<void> _loadSelectedCountries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedCountryNames = prefs.getStringList('selectedCountries') ?? [];

    if (savedCountryNames.isEmpty) {
      savedCountryNames = await _getCurrentCountry();
    }

    // Map country names to their respective country codes
    final savedCountryCodes = savedCountryNames.map((countryName) {
      return _countries.firstWhere(
          (country) => country['name']!.toLowerCase() == countryName.toLowerCase(),
          orElse: () => {'code': 'No COUNTRY IS SELECTED'})['code']!;
    }).toList();

    setState(() {
      _selectedCountryCodes = savedCountryCodes;
     // _currentCountryName = savedCountryNames.isEmpty ? 'No COUNTRY IS SELECTED' : savedCountryNames.first;
    });

    await _updateDataForCountries(_selectedCountryCodes);
  }

  Future<List<String>> _getCurrentCountry() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return ['No COUNTRY IS SELECTED'];
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return ['No COUNTRY IS SELECTED'];
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return ['No COUNTRY IS SELECTED'];
      }

      Position? position;
      try {
        position = await Future.any([
          Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ),
          Future.delayed(const Duration(seconds: 10), () => null),
        ]);
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching position: $e');
        }
      }

      if (position == null) {
        return ['No COUNTRY IS SELECTED'];
      }

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        return [placemarks.first.country ?? 'No COUNTRY IS SELECTED'];
      } else {
        return ['No COUNTRY IS SELECTED'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current country: $e');
      }
      return ['No COUNTRY IS SELECTED'];
    }
  }

  static Future<Map<String, dynamic>> _fetchDataForCountry(String countryCode) async {
    if (countryCode == 'No COUNTRY IS SELECTED') {
    return {};
    }
    final url = Uri.parse('http://149.28.150.230:9991/trending/$countryCode');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse) as Map<String, dynamic>;
      return data;
    } else {
      throw Exception('Failed to fetch data for country $countryCode');
    }
  }

  Future<void> _updateDataForCountries(List<String> countryCodes) async {
    setState(() {
      _isLoading = true;
      _keywordNewsPairs.clear();
    });
    try {
      for (final countryCode in countryCodes) {
        try {
          final data = await _fetchDataForCountry(countryCode);
          _processDataAndUpdateState(data, countryCode);
        } catch (error) {
          if (kDebugMode) {
            print('Error fetching data for country $countryCode: $error');
          }
          _addNoDataState(countryCode);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching data for countries: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _processDataAndUpdateState(Map<String, dynamic> data, String countryCode) {
    final searchResults = data['search_result'] as List<dynamic>;
    final trendingSearches = searchResults.isNotEmpty
        ? searchResults[0]['trendingSearches'] as List<dynamic>
        : [];

    if (mounted) {
      setState(() {
        if (trendingSearches.isNotEmpty) {
          for (final trendingSearch in trendingSearches) {
            final keyword = trendingSearch['title']['query'] as String;
            final firstArticle = (trendingSearch['articles'] as List<dynamic>).isNotEmpty
                ? trendingSearch['articles'][0]['title'] as String
                : 'No news available';
            final firstArticleUrl = (trendingSearch['articles'] as List<dynamic>).isNotEmpty
                ? trendingSearch['articles'][0]['url'] as String
                : '';
            _keywordNewsPairs.add({
              'countryCode': countryCode,
              'keyword': keyword,
              'newsTitle': firstArticle,
              'newsUrl': firstArticleUrl,
            });
          }
        } else {
          _addNoDataState(countryCode);
        }
      });
    }
  }

  void _addNoDataState(String countryCode) {
    _keywordNewsPairs.add({
      'countryCode': countryCode,
      'keyword': 'No data available',
      'newsTitle': '',
      'newsUrl': '',
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _getCountryIcon(String countryCode) {
    try {
      return SizedBox(
        width: 24,
        height: 24,
        child: CountryIcons.getSvgFlag(countryCode),
      );
    } catch (e) {
      return const Icon(Icons.flag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getCurrentCountry(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No country data available'));
        } else {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_keywordNewsPairs.isEmpty)
                  const Center(child: Text('No news available'))
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...(_showAll ? _selectedCountryCodes : _selectedCountryCodes.take(1)).map((countryCode) {
                        final countryName = _countries.firstWhere(
                            (country) => country['code'] == countryCode,
                            orElse: () => {'name': 'No COUNTRY IS SELECTED'})['name'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                _getCountryIcon(countryCode),
                                const SizedBox(width: 8),
                                Text(
                                  countryName ?? 'No COUNTRY IS SELECTED',
                                  style: GoogleFonts.bebasNeue(
                                    textStyle: const TextStyle(
                                      fontSize: 24,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: _keywordNewsPairs
                                  .where((pair) => pair['countryCode'] == countryCode)
                                  .map((pair) => Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pair['keyword']!,
                                            style: GoogleFonts.bebasNeue(
                                              textStyle: const TextStyle(
                                                fontSize: 20,
                                                color: CustomColor.textBlueColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: pair['newsTitle']!.isNotEmpty
                                                    ? SizedBox(
                                                        height: 30,
                                                        child: Marquee(
                                                          text: pair['newsTitle']!,
                                                          style: GoogleFonts.bebasNeue(
                                                            textStyle: const TextStyle(
                                                              fontSize: 16,
                                                              color: CustomColor.textBlueColor,
                                                            ),
                                                          ),
                                                          scrollAxis: Axis.horizontal,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          blankSpace: 20.0,
                                                          velocity: 50.0,
                                                          pauseAfterRound: const Duration(seconds: 1),
                                                          startPadding: 10.0,
                                                          accelerationDuration: const Duration(seconds: 1),
                                                          accelerationCurve: Curves.linear,
                                                          decelerationDuration: const Duration(seconds: 1),
                                                          decelerationCurve: Curves.easeOut,
                                                        ),
                                                      )
                                                    : Text(
                                                        'No news available',
                                                        style: GoogleFonts.bebasNeue(
                                                          textStyle: const TextStyle(
                                                            fontSize: 16,
                                                            color: CustomColor.textBlueColor,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                              if (pair['newsUrl']!.isNotEmpty)
                                                IconButton(
                                                  icon: const Icon(Icons.open_in_new,
                                                      color: CustomColor.textBlueColor),
                                                  onPressed: () => _launchURL(pair['newsUrl']!),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }),
                      if (_selectedCountryCodes.length > 1)
                        Center(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _showAll = !_showAll;
                              });
                            },
                            child: Text(_showAll ? 'Show Less' : 'Read More',
                                style: GoogleFonts.bebasNeue(
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    color: CustomColor.textBlueColor,
                                  ),
                                )),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          );
        }
      },
    );
  }
}
