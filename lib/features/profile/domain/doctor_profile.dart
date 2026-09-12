class DoctorProfile {
  const DoctorProfile({
    required this.userId,
    required this.fullName,
    required this.specialty,
    this.defaultDurationMinutes = 30,
    this.workingDays = const [1, 2, 3, 4, 5],
    this.workdayStart = '09:00',
    this.workdayEnd = '18:00',
    this.breakStart = '13:00',
    this.breakEnd = '14:00',
  });

  final String userId;
  final String fullName;
  final String specialty;
  final int defaultDurationMinutes;
  final List<int> workingDays;
  final String workdayStart;
  final String workdayEnd;
  final String? breakStart;
  final String? breakEnd;

  DoctorProfile copyWith({
    String? userId,
    String? fullName,
    String? specialty,
    int? defaultDurationMinutes,
    List<int>? workingDays,
    String? workdayStart,
    String? workdayEnd,
    String? breakStart,
    String? breakEnd,
  }) {
    return DoctorProfile(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      specialty: specialty ?? this.specialty,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      workingDays: workingDays ?? this.workingDays,
      workdayStart: workdayStart ?? this.workdayStart,
      workdayEnd: workdayEnd ?? this.workdayEnd,
      breakStart: breakStart ?? this.breakStart,
      breakEnd: breakEnd ?? this.breakEnd,
    );
  }
}
