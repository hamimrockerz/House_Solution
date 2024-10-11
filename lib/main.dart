// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:latest/search_page.dart';
// import 'Car Rent Collect.dart';
// import 'Garage Rent Details.dart';
// import 'ProfilePage.dart';
// import 'RentDetailsPage.dart';
// import 'UserDetailsChangePage.dart';
// import 'house_rent_collect_page.dart';
// import 'house_rent_update_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:house_solution/profile-renter.dart';
import 'package:house_solution/profile.dart';
import 'package:house_solution/rent_history.dart';
import 'package:house_solution/renter_dashboard.dart';
import 'package:house_solution/welcome_screen.dart';

import 'ForgotPasswordPage.dart';
import 'ForgotPasswordVerificationPage.dart';
import 'HouseRentPage.dart';
import 'add_flat.dart';
import 'add_house.dart';
import 'add_user.dart';
import 'all_users.dart';
import 'create-account.dart';
import 'flat_status_change.dart';
import 'garage_rent.dart';
import 'garage_rent_collect.dart';
import 'garage_rent_details.dart';
import 'garage_rent_history.dart';
import 'house_rent_collect.dart';
import 'house_rent_details.dart';
import 'house_rent_update.dart';
import 'login.dart';
import 'notifications.dart';
import 'owner_dashboard.dart';
//import 'dashboard_page.dart';
// // import 'create_account_page.dart';
// import 'create_user_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'First App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen (),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/owner_dashboard': (context) => const OwnerDashboard(),
        '/house_rent': (context) => const HouseRentPage(),
        '/garage_rent': (context) => const GarageRentPage(), // Add route for GarageRentPage

        '/ForgotPasswordPage': (context) =>  const ForgotPasswordPage(),
        '/ForgotPasswordVerificationPage': (context) => const ForgotPasswordVerificationPage(),
        '/renter_dashboard': (context) => const RenterDashboard(),
        '/house_rent_update': (context) => const RentUpdatePage(),
        '/add_house': (context) => const AddHousePage(),
        '/add_flat': (context) => const AddFlatPage(),
        '/house_rent_details': (context) => const HouseRentDetailsPage(),
        '/house_rent_collect': (context) => const HouseRentCollectPage(),
        '/rent_history': (context) => const RentHistoryPage(),
        '/garage_rent_details': (context) => const GarageRentDetailsPage(),
        '/garage_rent_collect': (context) => const GarageRentCollectPage(),
        '/garage_rent_history': (context) => const GarageRentHistoryPage(),
        '/add_user': (context) => const AddUserPage(),
        '/all_users': (context) => const AllUsersPage(),
        '/flat_status_change': (context) => const FlatStatusChangePage(),
        '/profile': (context) => const ProfilePage(),
        '/profile-renter': (context) => const RenterProfilePage(),
        '/notifications': (context) => const NotificationsPage(),

        // '/dashboard': (context) => const DashboardPage(),
        // '/create-user': (context) => const CreateUserPage(),
        // '/user-details-change': (context) => const UserDetailsChangePage(),
        // '/house-rent-details': (context) => const RentDetailsPage(),// Add this route
        // '/house-rent-update': (context) => const RentUpdatePage(),// Add this route
        // '/house-rent-collect': (context) => const HouseRentCollectPage(),
        // '/garage-rent-details': (context) => const GarageRentDetailsPage(),
        // '/garage-rent-collect': (context) => const CarRentCollectPage(),
        // '/rent-history': (context) => SearchPage(),
        // '/profile': (context) => const ProfilePage(),// Add this route
      },
    );
  }
}
