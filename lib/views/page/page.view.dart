import 'package:flutter/cupertino.dart';
import 'package:towaleti/shared/services.dart';

class DynamicPageView extends StatefulWidget {
  final String slug;

  const DynamicPageView({super.key, required this.slug});

  @override
  State<DynamicPageView> createState() => _DynamicPageViewState();
}

class _DynamicPageViewState extends State<DynamicPageView> {
  String title = '';
  String content = '';

  @override
  void initState() {
    super.initState();

    var page = Services.configs.get(key: 'page');

    if (page[widget.slug] != null) {
      title = page[widget.slug]['title'];
      content = page[widget.slug]['content'];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          title,
          style: TextStyle(
            fontFamily: "YekanBakh",
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        child: Text(
          content,
          style: TextStyle(
            color: CupertinoColors.darkBackgroundGray,
          ),
        ),
      ),
    );
  }
}
