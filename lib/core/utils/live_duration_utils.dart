String formatLiveDuration(Duration duration) {
  final safe = duration.isNegative ? Duration.zero : duration;
  final days = safe.inDays;
  final hours = safe.inHours.remainder(24);
  final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (days > 0) {
    return '${days}d ${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}

Duration liveElapsedSince(DateTime? startedAt) {
  if (startedAt == null) return Duration.zero;
  return DateTime.now().difference(startedAt);
}
