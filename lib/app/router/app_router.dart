import 'package:flutter/material.dart';

import '../../features/active_trip/presentation/pages/active_trip_page.dart';
import '../../features/audit_view/presentation/pages/audit_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/bus_assignment/presentation/pages/my_buses_page.dart';
import '../../features/bus_registration/presentation/pages/register_bus_page.dart';
import '../../features/driver_profile/presentation/pages/profile_page.dart';
import '../../features/line_selection/presentation/pages/change_line_page.dart';
import '../../features/map_view/presentation/pages/driver_map_page.dart';
import '../../features/trip_finish/presentation/pages/finish_trip_page.dart';
import '../../features/trip_start/presentation/pages/home_page.dart';
import '../../features/trip_start/presentation/pages/start_trip_page.dart';

class AppRouter {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const profile = '/profile';
  static const registerBus = '/register-bus';
  static const myBuses = '/my-buses';
  static const changeLine = '/change-line';
  static const startTrip = '/start-trip';
  static const activeTrip = '/active-trip';
  static const driverMap = '/driver-map';
  static const finishTrip = '/finish-trip';
  static const audit = '/audit';

  static Map<String, WidgetBuilder> routes({required VoidCallback onToggleTheme}) {
    return {
      splash: (_) => const SplashPage(),
      login: (_) => DriverLoginPage(onToggleTheme: onToggleTheme),
      register: (_) => DriverRegisterPage(onToggleTheme: onToggleTheme),
      home: (_) => DriverHomePage(onToggleTheme: onToggleTheme),
      profile: (_) => DriverProfilePage(onToggleTheme: onToggleTheme),
      registerBus: (_) => RegisterBusPage(onToggleTheme: onToggleTheme),
      myBuses: (_) => MyBusesPage(onToggleTheme: onToggleTheme),
      changeLine: (_) => ChangeLinePage(onToggleTheme: onToggleTheme),
      startTrip: (_) => StartTripPage(onToggleTheme: onToggleTheme),
      activeTrip: (_) => ActiveTripPage(onToggleTheme: onToggleTheme),
      driverMap: (_) => DriverMapPage(onToggleTheme: onToggleTheme),
      finishTrip: (_) => FinishTripPage(onToggleTheme: onToggleTheme),
      audit: (_) => AuditPage(onToggleTheme: onToggleTheme),
    };
  }
}
