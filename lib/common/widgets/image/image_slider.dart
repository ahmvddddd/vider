import '../../../utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ImageSlider extends StatefulWidget {
  const ImageSlider({super.key});

  @override
  ImageSliderState createState() => ImageSliderState();
}

class ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.8);

  // List of asset image paths
  final List<String> images = [
    Images.carpenter,
    Images.carpenter,
    Images.carpenter,
    Images.carpenter,
    Images.carpenter,
  ];

  @override
  Widget build(BuildContext context) {
    // Get 30% of screen height
    double screenHeight = MediaQuery.of(context).size.height;
    double sliderHeight = screenHeight * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('One-Point Perspective Slider'),
      ),
      body: Center(
        child: SizedBox(
          height: sliderHeight, // Set slider height to 30% of the screen
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return _buildImageSlider(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider(int index) {
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
              ..setEntry(3, 2, 0.001) // Perspective effect
              ..rotateY(pi / 4 * value), // Rotate based on position for dynamic perspective
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
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
                  images[index], // Use images from assets
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

