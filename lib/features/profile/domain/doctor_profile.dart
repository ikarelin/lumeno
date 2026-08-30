class DoctorProfile {
  const DoctorProfile({
    required this.userId,
    required this.fullName,
    required this.specialty,
  });

  final String userId;
  final String fullName;
  final String specialty;

  DoctorProfile copyWith({
    String? userId,
    String? fullName,
    String? specialty,
  }) {
    return DoctorProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
    );
  }
}
