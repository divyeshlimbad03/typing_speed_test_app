import 'package:http/http.dart' as http;
import 'package:typing_speed_test_app/a_submission/other/feedback/feedback_model.dart';

class FeedbackController {
  final String apiUrl =
      "http://api.aswdc.in/Api/MST_AppVersions/PostAppFeedback/AppPostFeedback";

  Future<bool> sendFeedback(FeedbackModel feedback) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: feedback.toMap(), // includes API_KEY inside model
      );

      print("Response: ${response.statusCode} ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
