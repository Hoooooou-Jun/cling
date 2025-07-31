import 'package:cling/core/color.dart';
import 'package:cling/presentation/main/pages/home_view.dart';
import 'package:cling/presentation/main/pages/profile_view.dart';
import 'package:cling/presentation/main/pages/feed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Widget> _views = [HomeView(), FeedView(), ProfileView()];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _views.length, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabController.index;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cling'),
        backgroundColor: primaryColor,
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Material(
          color: primaryColor,
          child: TabBar(
            controller: _tabController,
            indicatorColor: secondaryDeep,
            labelColor: primaryDeep,
            tabs: <Widget>[
              Tab(
                icon: Icon(idx == 0 ? Icons.home : Icons.home_outlined),
                text: '홈',
              ),
              Tab(
                icon: Icon(idx == 1 ? Icons.rss_feed : Icons.rss_feed_outlined),
                text: '피드',
              ),
              Tab(
                icon: Icon(idx == 2 ? Icons.person : Icons.person_outline),
                text: '내 정보',
              ),
            ],
          ),
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: _views,
      ),
    );
  }
}
