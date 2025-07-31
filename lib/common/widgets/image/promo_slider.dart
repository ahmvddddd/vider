// ignore_for_file: library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/sizes.dart';

class PromoSlider extends StatefulWidget {
  final List<String> imageList;

  const PromoSlider({super.key, required this.imageList});

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<PromoSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenHeight * 0.30,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: screenHeight * 0.28,
              autoPlay: false,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              viewportFraction: 0.8,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
            items: widget.imageList
                .map((item) => ClipRRect(
                  borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.network(item, fit: BoxFit.contain, width: screenWidth * 0.70),
                  )))
                .toList(),
          ),

          const SizedBox(height: Sizes.sm,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageList.map((url) {
              int index = widget.imageList.indexOf(url);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? CustomColors.primary
                      : CustomColors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
