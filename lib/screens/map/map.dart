import 'package:flutter/material.dart';

import '../../common/widgets/appbar/appbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text('Map',
        style: Theme.of(context).textTheme.headlineSmall,)
      ),
      body: Text('Map Screen'));
  }
}