class PatientDraft {
  const PatientDraft({this.name = '', this.phone = '', this.note = ''});

  final String name;
  final String phone;
  final String note;

  PatientDraft copyWith({String? name, String? phone, String? note}) {
    return PatientDraft(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
    );
  }
}

class ClinicDraft {
  const ClinicDraft({this.name = ''});

  final String name;

  ClinicDraft copyWith({String? name}) {
    return ClinicDraft(name: name ?? this.name);
  }
}

class CreatePatientInput {
  const CreatePatientInput({
    required this.name,
    this.phone = '',
    this.note = '',
  });

  final String name;
  final String phone;
  final String note;

  bool get isValid => name.trim().isNotEmpty && phone.trim().isNotEmpty;
}

class CreateClinicInput {
  const CreateClinicInput({required this.name});

  final String name;

  bool get isValid => name.trim().isNotEmpty;
}

class CreateVisitInput {
  const CreateVisitInput({
    required this.patientId,
    required this.clinicId,
    required this.startsAt,
    required this.durationMinutes,
    this.note = '',
  });

  final String patientId;
  final String clinicId;
  final DateTime startsAt;
  final int durationMinutes;
  final String note;

  bool get isValid =>
      patientId.trim().isNotEmpty &&
      clinicId.trim().isNotEmpty &&
      durationMinutes > 0;

  DateTime get endsAt => startsAt.add(Duration(minutes: durationMinutes));
}
