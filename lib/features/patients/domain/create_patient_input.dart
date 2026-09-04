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
