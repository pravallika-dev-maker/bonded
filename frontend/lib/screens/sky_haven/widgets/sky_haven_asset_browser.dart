import 'package:flutter/material.dart';
import '../controllers/island_state.dart';
import '../models/sky_haven_models.dart';

class SkyHavenAssetBrowser extends StatefulWidget {
  final IslandState state;
  final Function(SkyItem item) onItemSelected;

  const SkyHavenAssetBrowser({super.key, required this.state, required this.onItemSelected});

  static void show(BuildContext context, {required IslandState state, required Function(SkyItem) onItemSelected}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => SkyHavenAssetBrowser(state: state, onItemSelected: onItemSelected),
    );
  }

  @override
  State<SkyHavenAssetBrowser> createState() => _SkyHavenAssetBrowserState();
}

class _SkyHavenAssetBrowserState extends State<SkyHavenAssetBrowser> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<SkyItemCategory> _availableCategories;

  @override
  void initState() {
    super.initState();
    _availableCategories = SkyItemCategory.values
        .where((c) => c != SkyItemCategory.islandBase)
        .toList();

    _tabController = TabController(length: _availableCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1A35),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 40,
            offset: Offset(0, -10),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          if (_availableCategories.length > 1) ...[
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF9C6FE4),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
              tabs: _availableCategories.map((cat) => Tab(text: '${cat.emoji} ${cat.label}')).toList(),
            ),
            const Divider(color: Colors.white12, height: 1),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '☁️ Choose Island Base',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
          ],
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _availableCategories.map((cat) => _CategoryGrid(category: cat, onSelected: (item) {
                Navigator.pop(context);
                widget.onItemSelected(item);
              })).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final SkyItemCategory category;
  final Function(SkyItem) onSelected;

  const _CategoryGrid({required this.category, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final items = SkyHavenCatalog.byCategory(category);
    
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _AssetCard(item: items[index], onTap: () => onSelected(items[index]));
      },
    );
  }
}

class _AssetCard extends StatefulWidget {
  final SkyItem item;
  final VoidCallback onTap;

  const _AssetCard({required this.item, required this.onTap});

  @override
  State<_AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<_AssetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) {
        setState(() => _isHovered = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_isHovered ? 0.95 : 1.0),
        decoration: BoxDecoration(
          color: const Color(0xFF282442),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered ? const Color(0xFF9C6FE4).withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: const Color(0xFF9C6FE4).withOpacity(0.3),
                blurRadius: 16,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  widget.item.assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(child: Text('☁️', style: TextStyle(fontSize: 32))),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
              ),
              child: Center(
                child: Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
