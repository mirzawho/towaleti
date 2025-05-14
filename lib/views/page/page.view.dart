import 'package:flutter/material.dart';

class DynamicPageView extends StatefulWidget {
  final String slug;

  const DynamicPageView({super.key, required this.slug});

  @override
  State<DynamicPageView> createState() => _DynamicPageViewState();
}

class _DynamicPageViewState extends State<DynamicPageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
