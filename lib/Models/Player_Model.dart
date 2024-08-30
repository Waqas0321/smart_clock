class PlayersModel {
  List<SearchResult>? searchResult;

  PlayersModel({this.searchResult});

  PlayersModel.fromJson(Map<String, dynamic> json) {
    if (json['search_result'] != null) {
      searchResult = <SearchResult>[];
      json['search_result'].forEach((v) {
        searchResult!.add(SearchResult.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (searchResult != null) {
      data['search_result'] =
          searchResult!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchResult {
  String? name;
  UpcomingMatch? upcomingMatch;

  SearchResult({this.name, this.upcomingMatch});

  SearchResult.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    upcomingMatch = json['upcoming_match'] != null && json['upcoming_match'] != "No data found"
        ? UpcomingMatch.fromJson(json['upcoming_match'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (upcomingMatch != null) {
      data['upcoming_match'] = upcomingMatch!.toJson();
    }
    return data;
  }
}

class UpcomingMatch {
  String? label;
  String? home;
  String? away;
  String? time;
  String? homeImg;
  String? awayImg;

  UpcomingMatch({this.label, this.home, this.away, this.time, this.homeImg, this.awayImg});

  UpcomingMatch.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    home = json['home'];
    away = json['away'];
    time = json['time'];
    homeImg = json['home_img'];
    awayImg = json['away_img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['home'] = home;
    data['away'] = away;
    data['time'] = time;
    data['home_img'] = homeImg;
    data['away_img'] = awayImg;
    return data;
  }
}