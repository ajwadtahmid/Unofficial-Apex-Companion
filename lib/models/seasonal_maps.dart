import '../constants/map_constants.dart';

class SeasonalMaps {
  final List<AppMap> ranked;
  final List<AppMap> pubs;

  SeasonalMaps({required this.ranked, required this.pubs});

  factory SeasonalMaps.fromJson(Map<String, dynamic> json) {
    final ranked = (json['ranked'] as List<dynamic>?)
            ?.map((m) => AppMap(
                  id: m['id'] as String? ?? '',
                  name: m['name'] as String? ?? '',
                ))
            .toList() ??
        [];
    final pubs = (json['pubs'] as List<dynamic>?)
            ?.map((m) => AppMap(
                  id: m['id'] as String? ?? '',
                  name: m['name'] as String? ?? '',
                ))
            .toList() ??
        [];
    return SeasonalMaps(ranked: ranked, pubs: pubs);
  }

  Map<String, dynamic> toJson() => {
        'ranked': ranked.map((m) => {'id': m.id, 'name': m.name}).toList(),
        'pubs': pubs.map((m) => {'id': m.id, 'name': m.name}).toList(),
      };
}
