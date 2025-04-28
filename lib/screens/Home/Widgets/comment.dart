// // comment.dart
// import 'package:flutter/material.dart';
// import 'package:frontend/services/post_service.dart';

// class CommentBox extends StatefulWidget {
//   final VoidCallback onClose;
//   final int?
//       postId; // Add postId parameter to identify which post to comment on

//   const CommentBox({
//     Key? key,
//     required this.onClose,
//     this.postId,
//   }) : super(key: key);

//   @override
//   State<CommentBox> createState() => _CommentBoxState();
// }

// class _CommentBoxState extends State<CommentBox> {
//   final TextEditingController _commentController = TextEditingController();
//   final PostService _postService = PostService();
//   bool isLoading = false;
//   List<Map<String, dynamic>> comments = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.postId != null) {
//       _loadComments();
//     }
//   }

//   Future<void> _loadComments() async {
//     if (widget.postId == null) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final fetchedComments = await _postService.getComments(widget.postId!);
//       setState(() {
//         comments = fetchedComments;
//         isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading comments: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _submitComment() async {
//     if (_commentController.text.trim().isEmpty || widget.postId == null) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final success = await _postService.addComment(
//         widget.postId!,
//         _commentController.text.trim(),
//       );

//       if (success) {
//         _commentController.clear();
//         // Reload comments to show the new one
//         await _loadComments();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to add comment')),
//         );
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Header with title and close button
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Comments',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: widget.onClose,
//               ),
//             ],
//           ),

//           // Comments list
//           if (isLoading && comments.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Center(child: CircularProgressIndicator()),
//             )
//           else if (comments.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Center(child: Text('No comments yet')),
//             )
//           else
//             Container(
//               height: 200, // Fixed height for comments section
//               child: ListView.builder(
//                 itemCount: comments.length,
//                 itemBuilder: (context, index) {
//                   final comment = comments[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const CircleAvatar(
//                           radius: 16,
//                           // Use actual profile image if available
//                           backgroundImage:
//                               AssetImage('images/default_profile.png'),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               RichText(
//                                 text: TextSpan(
//                                   style: const TextStyle(color: Colors.black),
//                                   children: [
//                                     TextSpan(
//                                       text: '${comment['username']} ',
//                                       style: const TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     TextSpan(text: comment['comment']),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 _getTimeAgo(
//                                     DateTime.parse(comment['created_at'])),
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),

//           // Comment input field
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: Row(
//               children: [
//                 const CircleAvatar(
//                   radius: 16,
//                   backgroundImage: AssetImage('images/default_profile.png'),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: TextField(
//                     controller: _commentController,
//                     decoration: const InputDecoration(
//                       hintText: 'Add a comment...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(20)),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     ),
//                     maxLines: 1,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 isLoading
//                     ? const SizedBox(
//                         width: 24,
//                         height: 24,
//                         child: CircularProgressIndicator(strokeWidth: 2),
//                       )
//                     : IconButton(
//                         icon: const Icon(Icons.send),
//                         onPressed: _submitComment,
//                       ),
//               ],
//             ),
//           ),

//           // Add padding for bottom insets (keyboard)
//           SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
//         ],
//       ),
//     );
//   }

//   // Helper method to format the time ago - same as in Tile
//   String _getTimeAgo(DateTime dateTime) {
//     final difference = DateTime.now().difference(dateTime);

//     if (difference.inDays > 0) {
//       return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }
// }
