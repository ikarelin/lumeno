int resolveAvailabilityStartPrecisionMinutes({
  required int defaultDurationMinutes,
  required int requestedDurationMinutes,
}) {
  if (requestedDurationMinutes == 15) {
    return 15;
  }

  return switch (defaultDurationMinutes) {
    15 => 15,
    30 => 30,
    60 => 60,
    _ => 30,
  };
}
