class AIResponse {
  final String serviceName;
  final String response;
  final bool isError;
  final DateTime timestamp;

  AIResponse({
    required this.serviceName,
    required this.response,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AIResponse.error(String serviceName, String error) {
    return AIResponse(serviceName: serviceName, response: error, isError: true);
  }
}
