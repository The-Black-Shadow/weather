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
  @override
  void initState() {
    super.initState();
    getCurrentWeather();
  }

  Future getCurrentWeather() async {
    await dotenv.load(fileName: ".env"); // Load the .env file

    String? cityName = 'london';
    final apiKey = dotenv.env['weather_api'];

    final res = await http.get(Uri.parse(
      'http://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey',
    ));

    print(res.body);
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
      body: Padding(
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
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '300 K',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Icon(
                            Icons.cloud,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Rain',
                            style: TextStyle(
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
      ),
    );
  }
}
