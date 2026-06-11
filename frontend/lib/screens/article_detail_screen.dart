import 'package:flutter/material.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Premium off-white backing
      
      /// 1. FIXED TOP APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2328), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'The Curator',
          style: TextStyle(
            color: Color(0xFF00365C),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: Color(0xFF1F2328), size: 22),
            onPressed: () {
              // Toggle article save state
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      /// 2. SCROLLABLE ARTICLE BODY
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Category Tag Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E9F3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PERSPECTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00365C),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              /// Article Headline Title
              const Text(
                'The Art of Digital Curation in the Age of Noise',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 18),

              /// Author Profile Row Panel
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFEAEAEA),
                    child: Icon(Icons.person_outline_rounded, size: 18, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'By Julian Vane',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2328),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Editor-in-Chief  •  6 min read',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF7A8087),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),

              /// Introductory Paragraph with Drop-Cap Accent Line
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 3.5,
                    height: 44, // Perfectly aligns to anchor the first two lines of text
                    margin: const EdgeInsets.only(top: 4, right: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00365C),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'n an era defined by the sheer volume of information, the role of the curator has shifted from a luxury to a necessity. We are no longer limited by access to knowledge, but by our capacity to filter it. The digital landscape is a vast ocean of data, much of it redundant, noise-filled, and ultimately distracting.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Color(0xFF2C3036),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'To curate is to care. It is an act of deliberate selection, a refusal of the default algorithm that prioritizes engagement over quality. When we look at the history of editorial excellence, it was always the "gatekeepers" who provided the context necessary for raw information to become meaningful insight. Today, that gatekeeping is often viewed with skepticism, yet it remains our best defense against intellectual exhaustion.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2C3036),
                ),
              ),

              const SizedBox(height: 32),

              /// 3. THE PULL-QUOTE BREAKOUT BLOCK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F9), // Soft tinted inner fill
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 120, // Spans the height of the blockquote content section
                      decoration: BoxDecoration(
                        color: const Color(0xFF005A8D),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 18),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '"Curation is the antidote to the algorithmic tyranny. It is where human taste meets structural narrative, creating a bridge between chaos and clarity."',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF00365C),
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '— Excerpt from \'The Curator\'s Manifesto\'',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A8087),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              const Text(
                'Effective digital curation involves three primary pillars: context, consistency, and character. Context ensures that a piece of information isn\'t just shared, but understood within its broader ecosystem. Consistency builds the trust required for an audience to return to a specific source. Character, perhaps the most vital, is the unique perspective—the "human touch"—that no AI can yet replicate with true soul.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2C3036),
                ),
              ),

              const SizedBox(height: 36),

              /// Sub-Section Header
              const Text(
                'The Burden of Choice',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2328),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 14),
              
              const Text(
                'The psychological toll of endless scrolling is well-documented. Decision fatigue sets in within minutes of opening a social feed. This is where \'The Curator\' steps in. By narrowing the aperture of what we consume, we paradoxically expand the depth of our understanding. It is a commitment to the "slow content" movement, prioritizing one profound thought over a thousand fleeting impressions.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2C3036),
                ),
              ),

              const SizedBox(height: 32),

              /// 4. THE KEY TAKEAWAY PANEL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE), // Blueprint highlighted tint wrap
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 3,
                      height: 110,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF1A73E8), size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Key Takeaway',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A73E8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Curators aren\'t just collectors; they are architects of relevance. By choosing what to exclude, they define the value of what remains.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2328),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              
              const Text(
                'As we move forward into an AI-augmented future, the human curator\'s role will only intensify. We will need guides who can navigate the synthetic noise, pointing us toward the authentic, the artisanal, and the human. The act of curation is, at its heart, a preservation of our shared humanity in a digital world.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Color(0xFF2C3036),
                ),
              ),

              const SizedBox(height: 40),

              /// 5. THE INTERACTIVE FOOTER BLOCK
              Row(
                children: [
                  /// Reaction Pill Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.thumb_up_outlined, size: 16, color: Color(0xFF2C3036)),
                        SizedBox(width: 8),
                        Text(
                          '1.2k',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3036),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Share Pill Button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEFF3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.share_outlined, size: 16, color: Color(0xFF2C3036)),
                        SizedBox(width: 8),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3036),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              /// Publication Timestamp Stamp
              Text(
                'Last updated Oct 24, 2023',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF9096A0),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}