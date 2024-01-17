class RequestBaseModel {
}

class ResponseBaseModel {
  int usedTokens;

  ResponseBaseModel({required this.usedTokens});

  Map toJson() => {'usedTokens': usedTokens};
}

class SimpleResponse extends ResponseBaseModel {
  String message;

  SimpleResponse({required this.message, required super.usedTokens});

  static SimpleResponse fromJson(Map<String, dynamic> json, {int? usedTokens}) {
    return SimpleResponse(
      message: json['message'],
      usedTokens: usedTokens ?? json['usedTokens'],
    );
  }

  @override
  Map toJson() => {
        'message': message,
        'usedTokens': usedTokens,
      };
}
