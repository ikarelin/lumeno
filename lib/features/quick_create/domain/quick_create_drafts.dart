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
