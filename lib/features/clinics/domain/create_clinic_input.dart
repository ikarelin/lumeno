class CreateClinicInput {
  const CreateClinicInput({required this.name});

  final String name;

  bool get isValid => name.trim().isNotEmpty;
}
