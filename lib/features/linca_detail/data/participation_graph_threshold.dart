class ParticipationGraphThreshold {
  const ParticipationGraphThreshold({
    required this.label,
    required this.maxY,
    required this.interval,
  });

  factory ParticipationGraphThreshold.ten() =>
      const ParticipationGraphThreshold(
        label: '10件',
        maxY: 10,
        interval: 1,
      );

  factory ParticipationGraphThreshold.fifty() =>
      const ParticipationGraphThreshold(
        label: '50件',
        maxY: 50,
        interval: 5,
      );

  factory ParticipationGraphThreshold.hundred() =>
      const ParticipationGraphThreshold(
        label: '100件',
        maxY: 100,
        interval: 10,
      );

  static List<ParticipationGraphThreshold>
      get participationGraphThresholdList => <ParticipationGraphThreshold>[
            ParticipationGraphThreshold.ten(),
            ParticipationGraphThreshold.fifty(),
            ParticipationGraphThreshold.hundred(),
          ];

  final String label;
  final double maxY;
  final double interval;
}
