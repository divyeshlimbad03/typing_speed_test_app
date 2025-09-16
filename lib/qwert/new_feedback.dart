// import '../import_export_file.dart';
//
// class NewFeedback extends StatefulWidget {
//   const NewFeedback({Key? key}) : super(key: key);
//
//   @override
//   State<NewFeedback> createState() => _NewFeedbackState();
// }
//
// class _NewFeedbackState extends State<NewFeedback> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _messageController = TextEditingController();
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _mobileController.dispose();
//     _emailController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Feedback')),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'We value your feedback',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//                 const SizedBox(height: 16),
//                 CommonTextField(label: 'Name', controller: _nameController),
//                 const SizedBox(height: 12),
//                 CommonTextField(
//                   label: 'Mobile Number',
//                   controller: _mobileController,
//                   keyboardType: TextInputType.phone,
//                 ),
//                 const SizedBox(height: 12),
//                 CommonTextField(
//                   label: 'Email',
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 const SizedBox(height: 12),
//                 CommonTextField(
//                   label: 'Feedback',
//                   controller: _messageController,
//                   maxLines: 6,
//                 ),
//                 const SizedBox(height: 12),
//
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CommonBtn(
//                         onPress: () async {
//                           final name = _nameController.text.trim();
//                           final mobile = _mobileController.text.trim();
//                           final email = _emailController.text.trim();
//                           final message = _messageController.text.trim();
//
//                           if (name.isEmpty) {
//                             Get.snackbar(
//                               'Required',
//                               'Name is required',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                             return;
//                           }
//                           if (mobile.isEmpty) {
//                             Get.snackbar(
//                               'Required',
//                               'Mobile is required',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                             return;
//                           }
//                           if (email.isEmpty) {
//                             Get.snackbar(
//                               'Required',
//                               'Email is required',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                             return;
//                           }
//                           if (message.isEmpty) {
//                             Get.snackbar(
//                               'Required',
//                               'Feedback message is required',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                             return;
//                           }
//
//                           final payload = {
//                             'app_name': APP_NAME,
//                             'name': name,
//                             'mobile': mobile,
//                             'email': email,
//                             'message': message,
//                           };
//                           print(payload);
//                           Get.snackbar(
//                             'Sending',
//                             'Submitting feedback...',
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                           try {
//                             final ok = await FeedbackService().submitFeedback(
//                               payload,
//                             );
//                             if (ok) {
//                               Get.snackbar(
//                                 'Thank you',
//                                 'Feedback submitted',
//                                 snackPosition: SnackPosition.BOTTOM,
//                               );
//                               _formKey.currentState?.reset();
//                               _nameController.clear();
//                               _mobileController.clear();
//                               _emailController.clear();
//                               _messageController.clear();
//                             } else {
//                               Get.snackbar(
//                                 'Error',
//                                 'Failed to submit feedback',
//                                 snackPosition: SnackPosition.BOTTOM,
//                               );
//                             }
//                           } catch (e) {
//                             Get.snackbar(
//                               'Error',
//                               'Failed to submit feedback: $e',
//                               snackPosition: SnackPosition.BOTTOM,
//                             );
//                           }
//                         },
//                         btnText: 'Send',
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: CommonBtn(
//                         onPress: () {
//                           _formKey.currentState?.reset();
//                           _nameController.clear();
//                           _mobileController.clear();
//                           _emailController.clear();
//                           _messageController.clear();
//                         },
//                         btnText: 'Clear',
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
