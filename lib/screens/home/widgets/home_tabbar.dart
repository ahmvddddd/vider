import 'package:flutter/material.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/custom_shapes/cards/category_card.dart';
import '../../../utils/constants/custom_colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';

class HomeTabbar extends StatelessWidget {
  final List<String> categories = [
    'Design',
    'Writing',
    'Programming',
    'Marketing',
    'Music',
  ];

  final Map<String, List<String>> freelancers = {
    'Design': ['Alice', 'Ben', 'Cara', 'Derek', 'Ella'],
    'Writing': ['Fiona', 'George', 'Hannah', 'Ian', 'Jenny'],
    'Programming': ['Kevin', 'Laura', 'Mike', 'Nina', 'Oscar'],
    'Marketing': ['Pam', 'Quincy', 'Rachel', 'Steve', 'Tina'],
    'Music': ['Uma', 'Victor', 'Wendy', 'Xander', 'Yara'],
  };
  

  HomeTabbar({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: TAppBar(
        title: Text('All Categories',
        style: Theme.of(context).textTheme.headlineSmall,),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.spaceBtwItems),
          child: Column(
            children: [
              DefaultTabController(
                length: categories.length,
                child: Builder(
                  builder: (context) {
                    final TabController tabController = DefaultTabController.of(context);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                          child: AnimatedBuilder(
                            animation: tabController,
                            builder: (context, _) {
                              return TabBar(
                                isScrollable: true,
                                labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                                indicator: const BoxDecoration(),
                                indicatorColor: Colors.transparent,
                                tabs: List.generate(categories.length, (index) {
                                  final isSelected = tabController.index == index;
              
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.md,
                                      vertical: Sizes.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? CustomColors.primary
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow:
                                          isSelected
                                              ? [
                                                BoxShadow(
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor.withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                              : [],
                                    ),
                                    child: Text(
                                      categories[index],
                                  
                             style: Theme.of(
                                        context,
                                      ).textTheme.labelLarge!.copyWith(
                                        color:
                                            isSelected ? Colors.white : Colors.blueGrey,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: screenHeight,
                          child: TabBarView(
                            children:
                                categories.map((category) {
                                  final list = freelancers[category]!;
                                  return ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Sizes.md,
                                    ),
                                    itemCount: list.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: Sizes.md,),
                                    itemBuilder: (context, index) {
                                      return CategoryCard(
                                        imageAvatar: Images.carpenter,
                                        fullname: list[index],
                                        ratingColor: Colors.brown,
                                        rating: 2,
                                        service: category,
                                        description:
                                            'Hi everyone! We would love to introduce the design concept our team developed for a freelance marketplace mobile application. Specialists can find work opportunities, while employers can hire freelancers for projects. Lets explore its features.',
                                        hourlyRate: 50,
                                      );
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
