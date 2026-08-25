import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('dashboard.title'.tr()));
  }
}
