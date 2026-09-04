import 'clinic_membership.dart';

abstract interface class ClinicMembershipRepository {
  Future<List<ClinicMembership>> fetchActiveClinicMemberships();

  Future<void> setDefaultClinic({required String clinicId});
}
