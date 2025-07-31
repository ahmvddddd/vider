import 'package:flutter/material.dart';
import 'dart:math';

import '../../../utils/constants/image_strings.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  SwitchScreenState createState() => SwitchScreenState();
}

class SwitchScreenState extends State<SwitchScreen> {
  final PageController _pageController = PageController(initialPage: 0, viewportFraction: 0.8);

  // List of asset image paths (screens)
  final List<String> screenImages = [
    Images.carpenter,
    Images.carpenter,
    Images.carpenter,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Screen'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: PageView.builder(
          controller: _pageController,
          reverse: true,  // Reverse to show most recent screen on the left
          itemCount: screenImages.length,
          itemBuilder: (context, index) {
            return _buildSwitchSlider(index);
          },
        ),
      ),
    );
  }

  Widget _buildSwitchSlider(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }

        // Apply perspective effect using Transform
        return Center(
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)  // Perspective effect
              ..rotateY(pi / 6 * value),  // Rotate dynamically
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0,),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  screenImages[index],  // Use images from assets
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
