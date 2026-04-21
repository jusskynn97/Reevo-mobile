import 'package:flutter/material.dart';
import 'package:reevo/core/theme/color.dart';

class CommentsBottomSheet extends StatelessWidget {
  const CommentsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Placeholder for balance
                const Text(
                  '842 Comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.grey5,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Top Comments',
                      style: TextStyle(
                        color: AppColors.brand,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: 100,
                      color: AppColors.brand,
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const Text(
                  'Recent',
                  style: TextStyle(
                    color: AppColors.grey3,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.grey5, height: 1),

          // Comments List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildCommentItem(index);
              },
            ),
          ),

          // Comment Input
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.grey5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emojis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Text('🔥', style: TextStyle(fontSize: 24)),
                    Text('🤩', style: TextStyle(fontSize: 24)),
                    Text('🚀', style: TextStyle(fontSize: 24)),
                    Text('🤯', style: TextStyle(fontSize: 24)),
                    Text('👏', style: TextStyle(fontSize: 24)),
                    Text('✨', style: TextStyle(fontSize: 24)),
                    Text('💯', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.grey5,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(color: AppColors.grey3),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const Icon(Icons.alternate_email, color: AppColors.grey3, size: 20),
                            const SizedBox(width: 8),
                            const Icon(Icons.emoji_emotions_outlined, color: AppColors.grey3, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.grey5,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: AppColors.brand, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.purple,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@user_$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${index + 1}h ago',
                      style: const TextStyle(
                        color: AppColors.grey3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'This is a mock comment for the video. The lighting here is amazing! 🔥',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reply',
                  style: TextStyle(
                    color: AppColors.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Icon(Icons.favorite_border, color: AppColors.grey3, size: 20),
              const SizedBox(height: 4),
              Text(
                '${(index * 123) % 1000}',
                style: const TextStyle(color: AppColors.grey3, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
