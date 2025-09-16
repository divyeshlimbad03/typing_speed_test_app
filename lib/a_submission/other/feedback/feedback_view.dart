import 'package:flutter/material.dart';
import 'package:typing_speed_test_app/a_submission/other/feedback/feedback_controller.dart';
import 'package:typing_speed_test_app/a_submission/other/feedback/feedback_model.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  final _formKey = GlobalKey<FormState>();
  final FeedbackController controller = FeedbackController();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController mobileCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController messageCtrl = TextEditingController();

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      FeedbackModel feedback = FeedbackModel(
        appName: "MyFlutterApp",
        versionNo: "1.0",
        platform: "Android",
        personName: nameCtrl.text,
        mobile: mobileCtrl.text,
        email: emailCtrl.text,
        message: messageCtrl.text,
        remarks: "No remarks",
      );

      bool success = await controller.sendFeedback(feedback);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "✅ Feedback submitted successfully"
                : "❌ Error submitting feedback",
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        nameCtrl.clear();
        mobileCtrl.clear();
        emailCtrl.clear();
        messageCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        title: const Text(
          "Feedback",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text(
                    "We value your feedback 😊",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: nameCtrl,
                    label: "Name",
                    icon: Icons.person,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your name" : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: mobileCtrl,
                    label: "Mobile",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter mobile number" : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: emailCtrl,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || !v.contains("@")
                        ? "Enter valid email"
                        : null,
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(
                    controller: messageCtrl,
                    label: "Message",
                    icon: Icons.message,
                    maxLines: 3,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Enter your feedback" : null,
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: _submitFeedback,
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text("Submit Feedback"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
