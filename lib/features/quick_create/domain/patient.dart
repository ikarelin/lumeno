class Patient {
  const Patient({
    required this.id,
    required this.name,
    this.phone = '',
    this.note = '',
  });

  final String id;
  final String name;
  final String phone;
  final String note;
}
