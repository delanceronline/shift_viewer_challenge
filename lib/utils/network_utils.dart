import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import '../data_models/shift.dart';

// network call class to handle api calls
class NetworkUtils {

  // function to fetch a list of shifts of a specific user
  static Future<List<Shift>> getShift(String user) async {
    try {

      final response = await http.get(
        Uri.parse('https://flutter-test-five.vercel.app/api/shifts/$user'),
        headers: {
          'Content-Type': 'application/json'
        },
      );

      if(response.statusCode == 200){
        final List<dynamic> shiftList = jsonDecode(response.body);

        // serialising data into data model
        return shiftList.map((json) => Shift.parseJson(json)).toList();
      }
      else{

        return [];

      }
    }
    catch(e){

      debugPrint(e.toString());
      return [];

    }
  }

}