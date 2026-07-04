/// Sort options for goals list.
enum GoalSortOption {
  recentlyUpdated('Recently updated'),
  deadlineAsc('Deadline (soonest)'),
  deadlineDesc('Deadline (latest)'),
  titleAsc('Title (A–Z)'),
  titleDesc('Title (Z–A)'),
  progressAsc('Progress (low–high)'),
  progressDesc('Progress (high–low)'),
  priorityDesc('Priority (high–low)');

  const GoalSortOption(this.label);

  final String label;
}
