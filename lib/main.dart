import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// POJO (Plain Old Java Object)
class Country {
  final String? name;
  final String? capital;
  final String? flag;

  Country({
    required this.name,
    required this.capital,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'],
      capital: json['capital'],
      flag: json['media']['flag'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countries of the World',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TimeTable(),
    );
  }
}

class TimeTable extends StatefulWidget {
  const TimeTable({Key? key}) : super(key: key);

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  List<Country>? _countries;
  List<Country>? _filteredCountries;

  @override
  void initState() {
    super.initState();
    _getCountries();
  }

  void _getCountries() async {
    var dio = Dio(BaseOptions(responseType: ResponseType.plain));
    var response = await dio.get(
        'https://api.sampleapis.com/countries/countries'
    );
    List list = jsonDecode(response.data);

    setState(() {
      _countries = list.map(
              (country) => Country.fromJson(country)
      ).toList();
      _filteredCountries = _countries;
    });
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = _countries
          ?.where((country) =>
          country.name!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countries of the World'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CountrySearchDelegate(_countries ?? []),
              );
            },
          ),
        ],
      ),
      body: _filteredCountries == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _filteredCountries!.length,
        itemBuilder: (context, index) {
          var country = _filteredCountries![index];
          return ListTile(
            title: Text(country.name ?? ''),
            subtitle: Text(country.capital ?? ''),
            trailing: country.flag == null || country.flag!.isEmpty
                ? null
                : Image.network(
              country.flag!,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(country.name ?? ''),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Capital: ${country.capital ?? ''}'),
                        Text('Flag: ${country.flag ?? ''}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class CountrySearchDelegate extends SearchDelegate<Country> {
  final List<Country> countries;

  CountrySearchDelegate(this.countries);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Country(name: '', capital: '', flag: ''));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(query);
  }

  Widget _buildList(String query) {
    final List<Country> filteredList = countries
        .where((country) =>
    country.name!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final Country country = filteredList[index];
        return ListTile(
          title: Text(country.name ?? ''),
          subtitle: Text(country.capital ?? ''),
          onTap: () {
            close(context, country);
          },
        );
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}
