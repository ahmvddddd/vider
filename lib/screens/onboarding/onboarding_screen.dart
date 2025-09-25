import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../screens/authentication/auth_screen.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/image_strings.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import '../../utils/helpers/responsive_size.dart';

// Riverpod state provider for current index
final currentIndexProvider = StateProvider<int>((ref) => 0);

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _pages = [
    {
      'words': ['Appear', 'In Map', 'Search'],
      'text': 'Welcome to Vider',
    },
    {
      'words': ['Accept', 'Jobs', 'Effortlessly '],
      'text': 'In App Messaging',
    },
    {
      'words': ['Execute Job', 'And', 'Get Paid'],
      'text': 'Provider Locations',
    },
  ];

  final List<Map<String, dynamic>> pageTexts = [
    {
      'pageText':
          'Hire from different categories of service providers',
    },
    {
      'pageText':
          'Send and receive messages from providers.',
    },
    {
      'pageText':
          'View a provider\'s location on the map to confirm they are nearby.',
    },
  ];

  final List<Map<String, dynamic>> images = [
    {'image': Images.onboarding1},
    {'image': Images.onboarding2},
    {'image': Images.onboarding3},
  ];

  void _nextPage() {
    final currentIndex = ref.read(currentIndexProvider);
    if (currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      ref.read(currentIndexProvider.notifier).state++;
    } else {
      HelperFunction.navigateScreen(context, const AuthScreen());
    }
  }

  Widget _buildIndicator(int index, int currentIndex) {
    final isActive = index == currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: responsiveSize(context, 4.0)),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? CustomColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentIndexProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged:
                  (index) =>
                      ref.read(currentIndexProvider.notifier).state = index,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: screenHeight * 0.70,
                      width: screenWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            images[index]['image'],
                          ), // or NetworkImage(...)
                          fit:
                              BoxFit.cover, // BoxFit.cover, contain, fill, etc.
                        ),
                        color: CustomColors.primary.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(Sizes.xl),
                          bottomRight: Radius.circular(Sizes.xl),
                        ),
                      ),
                      child: SizedBox.shrink(),
                    ),
                    SizedBox(height: responsiveSize(context, Sizes.spaceBtwSections)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsiveSize(context, Sizes.spaceBtwItems),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pages[index]['text'],
                            style: Theme.of(context).textTheme.headlineSmall!
                                .copyWith(color: CustomColors.primary),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: responsiveSize(context, Sizes.sm)),
                          SizedBox(
                            width: screenWidth * 0.80,
                            child: Text(
                              pageTexts[index]['pageText'],
                              style: Theme.of(context).textTheme.bodySmall,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsiveSize(context, 16), vertical: responsiveSize(context, 16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index, currentIndex),
                  ),
                ),
                TextButton(
                  onPressed: _nextPage,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.all(responsiveSize(context, Sizes.xs)),
                    backgroundColor: CustomColors.primary,
                  ),
                  child: Text(
                    currentIndex == _pages.length - 1 ? 'Finish' : 'Next',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium!.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
