import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather/additional_info_items.dart';
import 'package:weather/hourly_forecast_items.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future getCurrentWeather() async {
    await dotenv.load(fileName: ".env"); // Load the .env file

    try {
      String? cityName = 'Barisal';
      final apiKey = dotenv.env['weather_api'];

      final res = await http.get(Uri.parse(
        'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey',
      ));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') throw data['message'];
      return data;

      //data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;
          final currentData = data['list'][0];
          final currentTemp = currentData['main']['temp'];
          final currentSky = currentData['weather'][0]['main'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //Weather Forecast
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HourlyForecastItems(
                        time: '00.00',
                        icon: Icons.cloud,
                        temperature: '312.12',
                      ),
                      HourlyForecastItems(
                        time: '03.00',
                        icon: Icons.sunny,
                        temperature: '312.12',
                      ),
                      HourlyForecastItems(
                        time: '06.00',
                        icon: Icons.sunny_snowing,
                        temperature: '312.12',
                      ),
                      HourlyForecastItems(
                        time: '09.00',
                        icon: Icons.cloud,
                        temperature: '312.12',
                      ),
                      HourlyForecastItems(
                        time: '12.00',
                        icon: Icons.cloud,
                        temperature: '312.12',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                //Additional Information
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItems(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '77',
                    ),
                    AdditionalInfoItems(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '7.5',
                    ),
                    AdditionalInfoItems(
                      icon: Icons.beach_access_sharp,
                      label: 'Pressure',
                      value: '1035',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
