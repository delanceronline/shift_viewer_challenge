// an object model class for a shift serialised by json data
class Shift {

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double latitude;
  final double longitude;

  Shift({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
  });

  factory Shift.parseJson(Map<String, dynamic> json){

    return Shift(
      id: json['_id'],
      startTime: DateTime.parse("${json['date']} ${json['startTime']}:00"),
      endTime: DateTime.parse("${json['date']} ${json['finishTime']}:00"),
      longitude: json['location']['cordinates']['longitude'],
      latitude: json['location']['cordinates']['latitude'],
    );

  }
}
