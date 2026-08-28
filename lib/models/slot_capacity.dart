enum SlotCrowdStatus {
  fastPick,   // < 8 active orders (Low queue)
  busy,       // 8-19 active orders (Moderate)
  capReached, // >= 20 active orders (Disabled)
}

class SlotCapacity {
  final String slotTime;
  final int activeOrdersCount;
  final int maxCap;
  final bool isManuallyLocked;

  const SlotCapacity({
    required this.slotTime,
    required this.activeOrdersCount,
    this.maxCap = 20,
    this.isManuallyLocked = false,
  });

  SlotCrowdStatus get crowdStatus {
    if (isManuallyLocked || activeOrdersCount >= maxCap) {
      return SlotCrowdStatus.capReached;
    }
    if (activeOrdersCount >= 8) {
      return SlotCrowdStatus.busy;
    }
    return SlotCrowdStatus.fastPick;
  }

  bool get isAvailable => crowdStatus != SlotCrowdStatus.capReached;

  double get occupancyPercentage => (activeOrdersCount / maxCap).clamp(0.0, 1.0);

  String get badgeLabel {
    switch (crowdStatus) {
      case SlotCrowdStatus.fastPick:
        return 'Fast Pick';
      case SlotCrowdStatus.busy:
        return 'Busy ($activeOrdersCount/$maxCap)';
      case SlotCrowdStatus.capReached:
        return 'Cap Reached (20/20)';
    }
  }
}
