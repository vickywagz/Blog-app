import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final savedArticles = [
      {
        'title': 'The Future of Minimal Computing: Why Le...',
        'author': 'Elena Vance',
        'image':
            'assets/images/minimal_computing.jpg', 
      },
      {
        'title': 'Architectural Silence: Finding Peace in...',
        'author': 'Julian Thorne',
        'image': 'assets/images/architecture.jpg',
      },
      {
        'title': 'Sustainability and Spirit: How We...',
        'author': 'Sarah Jenkins',
        'image': 'assets/images/sustainability.jpg',
      },
      {
        'title': 'Hospitality Trends: The Rise of the...',
        'author': 'Marcus Chen',
        'image': 'assets/images/hospitality.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'THE CURATOR',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Color(0xFF1F2328),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF1F2328)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            /// TITLE BLOCKS
            const Text(
              'Saved Articles',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2328),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${savedArticles.length} articles saved',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF7A8087),
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            /// VERTICAL COMPACT INTERIOR DECK
            Expanded(
              child: ListView.separated(
                itemCount: savedArticles.length,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 110,
                ), // Prevents your floating nav shell from clipped overviews
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final article = savedArticles[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Article Image Thumbnail Frame
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAEAEA),
                          borderRadius: BorderRadius.circular(16),
                          // Once images are wired, toggle this decoration rule:
                          /* image: DecorationImage(
                            image: AssetImage(article['image']!),
                            fit: BoxFit.cover,
                          ), */
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                        ), // Fallback image placeholder
                      ),
                      const SizedBox(width: 16),

                      /// Mid Deck Meta Details Text Panel
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              article['title']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2328),
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article['author']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7A8087),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      /// Dynamic Save Context Trigger Icon
                      IconButton(
                        icon: const Icon(
                          Icons
                              .bookmark_rounded, // Styled matching the solid visual selection on your blueprint
                          color: Color(0xFF005A8D),
                          size: 24,
                        ),
                        onPressed: () {
                          // Connect your state management listener here (e.g. context.read<PostProvider>().toggleSave(id))
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
