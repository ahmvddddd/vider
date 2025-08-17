import 'package:flutter/material.dart';
import '../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../common/widgets/layouts/listview.dart';
import '../../common/widgets/texts/section_heading.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';

class ServiceProfileScreen extends StatelessWidget {
  const ServiceProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(title: Text('Service Profile')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileImage(
              imageAvatar: Images.carpenter,
              fullname: 'Provider Name',
              ratingColor: Colors.brown,
              rating: 2,
              service: 'Service',
              hourlyRate: 100,
            ),
        
            const SizedBox(height: Sizes.sm),
            Container(
              padding: const EdgeInsets.all(Sizes.spaceBtwItems),
              decoration: BoxDecoration(
                color:
                    dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Services(services: 'services', skillsLength: 4),
        
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SectionHeading(title: 'About', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  Text(
                    'Hi everyone! We would love to introduce the design concept our team developed for a freelance marketplace mobile application. Specialists can find work opportunities, while employers can hire freelancers for projects. Lets explore its features.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                  ),
        
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SectionHeading(title: 'Portfolio', showActionButton: false),
                  const SizedBox(height: Sizes.sm),
                  Portfolio(imageLength: 3, imageList: Images.carpenter),

                  const SizedBox(height: Sizes.spaceBtwSections,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String imageAvatar;
  final String fullname;
  final Color ratingColor;
  final double rating;
  final String service;
  final double hourlyRate;

  const ProfileImage({
    super.key,
    required this.imageAvatar,
    required this.fullname,
    required this.ratingColor,
    required this.rating,
    required this.service,
    required this.hourlyRate,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(imageAvatar)),
            border: Border.all(
              color: dark ? CustomColors.darkGrey : CustomColors.darkGrey,
              width: 2,
            ),
            shape: BoxShape.circle
          ),
        ),
    
        const SizedBox(height: Sizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fullname,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: dark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
    
            const SizedBox(width: Sizes.xs),
            RoundedContainer(
              backgroundColor: ratingColor,
              radius: Sizes.cardRadiusXs,
              padding: const EdgeInsets.symmetric(horizontal: Sizes.xs + 2, vertical: 2),
              child: Center(
                child: Text(
                  rating.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        Text(service, style: Theme.of(context).textTheme.bodySmall),
        Text(
          '\$$hourlyRate',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: CustomColors.success,
            fontFamily: 'JosefinSans',
          ),
        ),
    
        const SizedBox(height: Sizes.sm),
      ],
    );
  }
}

class Services extends StatelessWidget {
  final String services;
  final int skillsLength;
  const Services({
    super.key,
    required this.services,
    required this.skillsLength,
  });

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    return HomeListView(
      sizedBoxHeight: MediaQuery.of(context).size.height * 0.06,
      scrollDirection: Axis.horizontal,
      seperatorBuilder: (context, index) => const SizedBox(width: Sizes.sm),
      itemCount: skillsLength,
      itemBuilder:
          (context, index) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Sizes.cardRadiusSm),
              color: dark ? Colors.black : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 2,
              horizontal: Sizes.xs + 1,
            ),
            child: Center(
              child: Text(
                services,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: dark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
    );
  }
}

class Portfolio extends StatelessWidget {
  final String imageList;
  final int imageLength;
  const Portfolio({
    super.key,
    required this.imageLength,
    required this.imageList,
  });

  @override
  Widget build(BuildContext context) {
    return HomeListView(
      sizedBoxHeight: MediaQuery.of(context).size.height * 0.40,
      scrollDirection: Axis.horizontal,
      seperatorBuilder: (context, index) => const SizedBox(width: Sizes.sm),
      itemCount: imageLength,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
          child: Image.asset(
            imageList,
            width: MediaQuery.of(context).size.height * 0.40,
            height: MediaQuery.of(context).size.height * 0.30,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
