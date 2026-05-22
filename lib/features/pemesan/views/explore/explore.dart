import 'package:flutter/material.dart';
import '../../../../shared/widgets/events_cards/large.dart';
import '../../../../shared/widgets/searchbar.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  bool isFilterActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: CustomSearchBar(
              isFilterActive: isFilterActive,
              onFilterTap: () {
                setState(() {
                  isFilterActive = !isFilterActive;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return const EventCardLarge(
                  title: 'International Tech Conference 2026',
                  organizerName: 'Global Tech Network',
                  location: 'Convention Center, Jakarta',
                  price: 'Rp 500.000',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
