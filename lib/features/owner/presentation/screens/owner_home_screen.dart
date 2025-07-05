import 'package:flutter/material.dart';
import '../../../cars/presentation/screens/view_cars_screen.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../home/presentation/widgets/home_widgets/notification_badge_widget.dart';
import '../widgets/owner_drawer.dart';

class OwnerHomeScreen extends StatelessWidget {
  // const OwnerHomeScreen({Key? key}) : super(key: key);
  final int? userRole;

  const OwnerHomeScreen({Key? key, this.userRole}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cars'),
        actions: [
          // Notification icon with badge
          NotificationBadgeWidget(
            onTap: () {
              Navigator.pushNamed(context, ScreensName.newnotifytest);
            },
          ),
        ],
      ),
      drawer: const OwnerDrawer(),
      // body: const ViewCarsScreen(),
      body: ViewCarsScreen(userRole: userRole),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, ScreensName.addCarScreen);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 