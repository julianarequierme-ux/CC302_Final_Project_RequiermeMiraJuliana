import 'package:flutter/material.dart';

import '../utils/theme.dart';

/// Shown while local account/session data is read from the device.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: appGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 43,
                backgroundColor: Colors.white,
                child: Icon(Icons.flight_takeoff,
                    size: 44, color: AppColors.primary),
              ),
              SizedBox(height: 18),
              Text('SkySeaBooking',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w700)),
              SizedBox(height: 5),
              Text('Fly Higher • Sail Further',
                  style: TextStyle(color: Color(0xFFE2EDFF), fontSize: 13)),
              SizedBox(height: 26),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
