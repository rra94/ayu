/// Shared context built by ObservationAgent, read by individual agents.
/// Lets observations inform which agents fire and what they prioritize.
class AgentContext {
  bool gymToday = false;
  bool sedentaryDay = false;
  bool poorSleep = false;
  bool lowMood = false;
  bool pressureDrop = false;
  bool highCaffeine = false;
  bool lowProtein = false;
  String? currentPlace; // coffee_shop, grocery, restaurant, gym, pharmacy
  String? currentPlaceName;
  final Set<String> observationTypes = {};

  /// Observations already covered these topics — agents should skip them
  bool isAlreadyCovered(String agentType) {
    // If observation engine already flagged gym+protein, don't also show nutrient_gap for protein
    if (agentType == 'nutrient_gap' && observationTypes.contains('gym_protein')) return true;
    // If sedentary+sleep observation fired, don't also show sedentary agent
    if (agentType == 'sedentary' && observationTypes.contains('sedentary_sleep')) return true;
    // If pressure+mood fired, don't also show outdoor_time
    if (agentType == 'outdoor_time' && observationTypes.contains('pressure_mood')) return true;
    return false;
  }
}
