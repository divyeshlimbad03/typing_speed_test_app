class FeedbackModel {
  String appName;
  String versionNo;
  String platform;
  String personName;
  String mobile;
  String email;
  String message;
  String remarks;

  FeedbackModel({
    required this.appName,
    required this.versionNo,
    required this.platform,
    required this.personName,
    required this.mobile,
    required this.email,
    required this.message,
    required this.remarks,
  });

  Map<String, String> toMap() {
    return {
      "API_KEY": "1234", // ✅ send key with body
      "AppName": appName,
      "VersionNo": versionNo,
      "Platform": platform,
      "PersonName": personName,
      "Mobile": mobile,
      "Email": email,
      "Message": message,
      "Remarks": remarks,
    };
  }
}
