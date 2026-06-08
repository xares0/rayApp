import 'package:flutter/material.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Explore Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _CategoryCard(title: 'Nature', color: Colors.green),
              _CategoryCard(title: 'Portraits', color: Colors.purple),
              _CategoryCard(title: 'Urban', color: Colors.blueGrey),
              _CategoryCard(title: 'Macro', color: Colors.orange),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Trending Topics',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const ListTile(
            leading: Text('# 1',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            title: Text('#SunsetLovers'),
            trailing: Icon(Icons.chevron_right)),
        const ListTile(
            leading: Text('# 2',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            title: Text('#StreetPhotography'),
            trailing: Icon(Icons.chevron_right)),
        const ListTile(
            leading: Text('# 3',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            title: Text('#BlackAndWhite'),
            trailing: Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final Color color;

  const _CategoryCard({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
