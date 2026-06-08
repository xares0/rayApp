import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tabs/discover_tab.dart';
import 'tabs/gallery_tab.dart';
import 'tabs/recommend_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 16),
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: Colors.transparent,
            tabs: [
              Tab(text: '推荐'),
              Tab(text: '风采'),
              Tab(text: '发现'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            RecommendTab(),
            GalleryTab(),
            DiscoverTab(),
          ],
        ),
      ),
    );
  }
}
