import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/addi_card.dart';
import 'package:weather_app/hourly_forecast.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double temp = 0;

  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    String cityName = 'London';

    try {
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openweatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An error occured';
      }

      //data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Screen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data;
          final info = data!['list'][0];
          final currentTemp = info['main']['temp'];
          final cloudState = info['weather'][0]['main'];
          final currentHumidity = info['main']['humidity'];
          final currentPressure = info['main']['pressure'];
          final currentWindSpeed = info['wind']['speed'];
          final cityName = data['city']['name'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(16),
                    ),
                    elevation: 20,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                cloudState == 'Clouds' || cloudState == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(cloudState, style: TextStyle(fontSize: 24)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 10; i++)
                //         HourlyForecast(
                //           value: data!['list'][i + 1]['dt'].toString(),
                //           icon:
                //               data!['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clouds' ||
                //                   data!['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rainy'
                //               ? Icons.cloud
                //               : Icons.sunny,
                //           text: data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlyClouds =
                          data['list'][index + 1]['weather'][0]['main'];
                      final hourlyTemp =
                          data['list'][index + 1]['main']['temp'];
                      final date = DateTime.parse(
                        hourlyForecast['dt_txt'].toString(),
                      );
                      return HourlyForecast(
                        value: DateFormat.j().format(date),
                        icon:
                            hourlyClouds == 'Clouds' || hourlyClouds == 'Rainy'
                            ? Icons.cloud_sharp
                            : Icons.sunny,
                        text: hourlyTemp.toString(),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  'Additional Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: currentHumidity.toString(),
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.wind_power,
                        label: 'Wind Speed',
                        value: currentWindSpeed.toString(),
                        onTap: () {},
                      ),
                    ),
                    Expanded(
                      child: InfoCard(
                        icon: Icons.umbrella,
                        label: 'Pressure',
                        value: currentPressure.toString(),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('City: $cityName'),
              ],
            ),
          );
        },
      ),
    );
  }
}
