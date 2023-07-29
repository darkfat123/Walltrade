import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../variables/serverURL.dart';

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  TextEditingController _textEditingController = TextEditingController();
  String _prediction = '';

  Future<void> _predictStock() async {
    String stockName = _textEditingController.text;
    if (stockName.isEmpty) {
      setState(() {
        _prediction = 'Please enter a stock name.';
      });
      return;
    }

    var url = Uri.parse('${Constants.serverUrl}/predict');
    final headers = {'Content-Type': 'application/json'};
    String body = jsonEncode({'name': stockName});

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _prediction = data['prediction'];
        });
      } else {
        throw Exception('Prediction failed.');
      }
    } catch (e) {
      setState(() {
        _prediction = 'error caught: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFECF8F9),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  labelText: 'Enter stock name',
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _predictStock,
                child: Text('Predict'),
              ),
              SizedBox(height: 16.0),
              Text(
                _prediction,
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
