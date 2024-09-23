import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class ApiService {
  //final String _baseUrl = 'http://192.168.1.2:3000';
  final String _baseUrl = 'https://prod-manage.onrender.com';

  // Users API
  Future<List<dynamic>> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }

  // CutRecords API
  Future<List<dynamic>> fetchCutRecords(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cut-records?employeeId=$employeeId'),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao buscar registros de corte: $e');
    }
  }

  Future<List<dynamic>> fetchAllCutRecords() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/cut-records'));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao buscar todos os registros de corte: $e');
    }
  }

  Future<void> updateStatus(int cutId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/cut-records/$cutId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}),
      );
      await _processVoidResponse(response);
    } catch (e) {
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  Future<Uint8List?> getImage(int cutId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cut-records/$cutId/get-image'),
      );
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
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/cut-records/$cutId'),
      );
      await _processVoidResponse(response);
    } catch (e) {
      throw Exception('Erro ao deletar registro de corte: $e');
    }
  }

  Future<int> saveRegistroCorte(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cut-records'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['id'];
      } else {
        throw Exception('Erro ao salvar registro: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
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
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/operations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      await _processVoidResponse(response, expectedStatusCode: 201);
    } catch (e) {
      throw Exception('Erro ao salvar registro de operação: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchOperationRecords() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/operations'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((operationRecord) {
          return {
            'id': operationRecord['id'],
            'operationName': operationRecord['operationName'],
            'calculatedTime': operationRecord['calculatedTime'],
          };
        }).toList();
      } else {
        throw Exception(
            'Erro ao buscar registros de operação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar registros de operação: $e');
    }
  }

  // Performance API
  Future<List<dynamic>> fetchPerformanceData() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/performance'));
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao buscar dados de desempenho: $e');
    }
  }

  Future<void> savePerformance(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/performance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      await _processVoidResponse(response, expectedStatusCode: 201);
    } catch (e) {
      throw Exception('Erro ao salvar dados de desempenho: $e');
    }
  }

  // Employees API
  Future<List<dynamic>> fetchEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/employees'),
        headers: {'Content-Type': 'application/json'},
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Erro ao buscar funcionários: $e');
    }
  }

  Future<http.Response?> postEmployee(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/employees'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Erro ao adicionar funcionário: $e');
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/employees/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      await _processVoidResponse(response);
    } catch (e) {
      throw Exception('Erro ao deletar funcionário: $e');
    }
  }

  // Roles API
  Future<http.Response?> postRole(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/roles'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
            'Erro ao criar cargo: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erro de conexão: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchRoles() async {
    final url = Uri.parse('$_baseUrl/roles');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Converter cada item para Map<String, dynamic>
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Falha na solicitação: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Erro ao chamar a API: $e');
      throw Exception('Erro ao chamar a API');
    }
  }

  Future<String> fetchRoleTitle(int roleId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/roles/$roleId'),
      );
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

  // Helper methods
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
      throw Exception(
          'Erro ao processar a solicitação: ${response.statusCode}');
    }
  }
}
