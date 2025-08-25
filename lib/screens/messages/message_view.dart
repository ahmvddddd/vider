import 'package:flutter/material.dart';
import '../../utils/constants/custom_colors.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_function.dart';
import 'widgets/message_header.dart';

class MessageViewScreen extends StatefulWidget {

  const MessageViewScreen({super.key});

  @override
  State<MessageViewScreen> createState() => _MessageViewScreenState();
}

class _MessageViewScreenState extends State<MessageViewScreen> {
  final TextEditingController messageController = TextEditingController();
  final List<String> messages = [];

  void sendMessage() {
    if(messageController.text.isNotEmpty) {
      setState(() {
        messages.add(messageController.text);
        messageController.clear();
      });
    }

    scrollDown();
  }

  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener to focusNode
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        //cause delay so keyboard has time to showup
        //then the amount of remaining space would be calculated
        //then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 500),
    () => scrollDown()
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, 
    duration: const Duration(seconds: 1), 
    curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunction.isDarkMode(context);
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (_, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
                floating: true,
                expandedHeight: screenHeight * 0.08,
                backgroundColor: dark ? CustomColors.dark : CustomColors.light,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.all(Sizes.sm),
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      MessageHeader(),
                    ],
                  ),
                ),
              )
            ];
          },
          body: Padding(
                      padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                      child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Sizes.xs),
                        child: Container(
                          padding: const EdgeInsets.all(Sizes.sm),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Sizes.cardRadiusLg),
                            color: CustomColors.primary
                          ),
                          child: Text(messages[index],
                                              style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white),
                                              softWrap: true,
                                              ),
                        ),
                      )
                    ]
                  );
                },
              )
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.xs),
              child: Row(
                children: [
                 Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Sizes.xs),
                      child: TextField(
                        focusNode: myFocusNode,
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Type a message',
                        hintStyle: Theme.of(context).textTheme.labelSmall,
                        fillColor: dark ? CustomColors.dark : CustomColors.light,
                        filled: true,
                        ),
                      ),
                    ),
                  ),
                        
                  //icon
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Sizes.borderRadiusLg),
                      color: CustomColors.primary,
                    ),
                    child: IconButton(
                        onPressed: sendMessage, icon: const Icon(Icons.send, color: Colors.white,)),
                  )
                ],
              ),
            )
          ],
                      ),
                    )),
    );
  }
}
