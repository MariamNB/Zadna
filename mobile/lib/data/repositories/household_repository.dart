import '../../core/api/api_client.dart';
import '../models/household.dart';

class HouseholdRepository {
  final ApiClient _client;
  HouseholdRepository(this._client);

  Future<List<HouseholdSummary>> listHouseholds() async {
    final response = await _client.dio.get('/household/available');
    return (response.data as List)
        .map((e) => HouseholdSummary.fromJson(e))
        .toList();
  }

  Future<List<HouseholdMember>> listMembers() async {
    final response = await _client.dio.get('/household/members');
    return (response.data as List)
        .map((e) => HouseholdMember.fromJson(e))
        .toList();
  }

  Future<List<HouseholdInvitation>> listInvitations(
      {bool incoming = false}) async {
    final response = await _client.dio.get(incoming
        ? '/household/invitations/incoming'
        : '/household/invitations');
    return (response.data as List)
        .map((e) => HouseholdInvitation.fromJson(e))
        .toList();
  }

  Future<void> invite(String email, String role) async {
    await _client.dio
        .post('/household/invitations', data: {'email': email, 'role': role});
  }

  Future<void> respond(String id, {required bool accept}) async {
    await _client.dio
        .post('/household/invitations/$id/${accept ? 'accept' : 'decline'}');
  }

  Future<void> revoke(String id) =>
      _client.dio.delete('/household/invitations/$id');
  Future<void> remove(String id) =>
      _client.dio.delete('/household/members/$id');
  Future<void> changeRole(String id, String role) =>
      _client.dio.patch('/household/members/$id', data: {'role': role});
  Future<void> rename(String name) =>
      _client.dio.patch('/household', data: {'name': name});
}
