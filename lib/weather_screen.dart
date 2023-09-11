import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  Future<Map<String, dynamic>> getCurrentWeather() async {
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
            onPressed: () {
              setState(() {});
            },
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
          final currentTemp =
              (currentData['main']['temp'] - 273.16).toStringAsFixed(2);
          final currentSky = currentData['weather'][0]['main'];
          final pressure = currentData['main']['pressure'];
          final windSpeed = currentData['wind']['speed'];
          final humidity = currentData['main']['humidity'];

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
                                '$currentTemp°C',
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
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky = hourlyForecast['weather'][0]['main'];
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecastItems(
                          time: DateFormat.j().format(time),
                          temperature: (hourlyForecast['main']['temp'] - 273.16)
                              .toStringAsFixed(2),
                          icon: hourlySky == 'Clouds' || currentSky == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                        );
                      }),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItems(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$humidity%',
                    ),
                    AdditionalInfoItems(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$windSpeed km/h',
                    ),
                    AdditionalInfoItems(
                      icon: Icons.beach_access_sharp,
                      label: 'Pressure',
                      value: pressure.toString(),
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
