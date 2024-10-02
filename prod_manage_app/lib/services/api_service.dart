import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ApiService {
  final String _baseUrl = 'https://prod-manage-backend.onrender.com';
  final Map<String, String> _jsonHeaders = {'Content-Type': 'application/json'};

  // Helper methods to handle responses
  Future<List<dynamic>> _processResponse(http.Response response) async {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro na solicitação: ${response.statusCode}');
    }
  }

  Future<void> _processVoidResponse(http.Response response,
      {int expectedStatusCode = 200}) async {
    if (response.statusCode != expectedStatusCode) {
      throw Exception('Erro ao processar solicitação: ${response.statusCode}');
    }
  }

  // Generic GET method
  Future<List<dynamic>> _getRequest(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$endpoint'),
          headers: _jsonHeaders);
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao fazer requisição GET: $e');
    }
  }

  // Generic POST method
  Future<http.Response> _postRequest(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: _jsonHeaders,
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Erro ao fazer requisição POST: $e');
    }
  }

  // Generic Patch method
  Future<http.Response> _patchRequest(
      String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  // Users API
  Future<List<dynamic>> fetchUsers() async {
    return _getRequest('users');
  }

  Future<http.Response> registerUser(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/users');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode(data);

    try {
      final response = await http.post(url, headers: headers, body: body);

      return response;
    } catch (e) {
      throw Exception('Erro ao conectar à API: $e');
    }
  }

  // CutRecords API
  Future<List<dynamic>> fetchCutRecords(int employeeId) async {
    return _getRequest('cut-records?employeeId=$employeeId');
  }

  Future<List<dynamic>> fetchAllCutRecords() async {
    return _getRequest('cut-records');
  }

  Future<void> updateStatus(int cutId, String status) async {
    final response =
        await _patchRequest('cut-records/$cutId', {'status': status});
    await _processVoidResponse(response);
  }

  Future<Uint8List?> getImage(int cutId) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/cut-records/$cutId/get-image'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Erro ao carregar a imagem');
      }
    } catch (e) {
      throw Exception('Erro ao carregar imagem: $e');
    }
  }

  Future<void> deleteCutRecord(int cutId) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/cut-records/$cutId'));
    await _processVoidResponse(response);
  }

  Future<int> saveCutRecord(Map<String, dynamic> data) async {
    final response = await _postRequest('cut-records', data);
    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      return responseData['id'];
    } else {
      throw Exception('Erro ao salvar registro: ${response.reasonPhrase}');
    }
  }

  Future<void> uploadImage(int cutRecordId, File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$_baseUrl/cut-records/$cutRecordId/upload-image"),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          await imageFile.readAsBytes(),
          filename: path.basename(imageFile.path),
        ),
      );

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Erro ao enviar imagem: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar imagem: $e');
    }
  }

  // Operations API
  Future<void> saveOperationRecord(Map<String, dynamic> data) async {
    final response = await _postRequest('operations', data);
    await _processVoidResponse(response, expectedStatusCode: 201);
  }

  Future<List<Map<String, dynamic>>> fetchOperationRecords() async {
    List<dynamic> data = await _getRequest('operations');
    return data.map((operationRecord) {
      return {
        'id': operationRecord['id'],
        'operationName': operationRecord['operationName'],
        'calculatedTime': operationRecord['calculatedTime'],
      } as Map<String, dynamic>;
    }).toList();
  }

  // Operation Set API
  Future<List<dynamic>> fetchOperationSets() async {
    return _getRequest('operation-set');
  }

  Future<void> saveOperationSet(Map<String, dynamic> operationsSet) async {
    final url = Uri.parse('$_baseUrl/operation-set');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(operationsSet),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Conjunto de operações salvo com sucesso');
      } else {
        throw Exception(
            'Erro ao salvar o conjunto de operações: ${response.body}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Falha ao salvar o conjunto de operações.');
    }
  }

  // Performance API
  Future<List<dynamic>> fetchPerformanceData() async {
    return _getRequest('performance');
  }

  Future<void> savePerformance(Map<String, dynamic> data) async {
    final response = await _postRequest('performance', data);
    await _processVoidResponse(response, expectedStatusCode: 201);
  }

  // Employees API
  Future<List<dynamic>> fetchEmployees() async {
    return _getRequest('employees');
  }

  Future<void> deleteEmployee(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/employees/$id'),
        headers: _jsonHeaders);
    await _processVoidResponse(response);
  }

  Future<http.Response> postEmployee(Map<String, dynamic> data) async {
    return _postRequest('employees', data);
  }

// Roles API
  Future<List<Map<String, dynamic>>> fetchRoles() async {
    List<dynamic> data = await _getRequest('roles');
    return data.map((role) {
      return {
        'id': role['id'],
        'title': role['title'],
      } as Map<String, dynamic>;
    }).toList();
  }

  Future<http.Response> postRole(Map<String, dynamic> data) async {
    final response = await _postRequest('roles', data);
    if (response.statusCode == 201) {
      return response;
    } else {
      throw Exception(
          'Erro ao criar cargo: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }

  Future<String> fetchRoleTitle(int roleId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/roles/$roleId'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['title'];
      } else {
        throw Exception('Erro ao carregar título do cargo');
      }
    } catch (e) {
      throw Exception('Erro ao carregar título do cargo: $e');
    }
  }
}
