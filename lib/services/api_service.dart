/// REST API layer — ready for backend integration by the team.
class ApiService {
  const ApiService();

  Future<Map<String, dynamic>> get(String endpoint) async {
    throw UnimplementedError('API endpoint not configured: $endpoint');
  }
}
