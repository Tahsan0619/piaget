enum CognitiveStage {
  sensorimotor,
  preoperational,
  concreteOperational,
  formalOperational,
}

extension CognitiveStageExtension on CognitiveStage {
  String get displayName {
    switch (this) {
      case CognitiveStage.sensorimotor:
        return 'Sensorimotor (0-2 years)';
      case CognitiveStage.preoperational:
        return 'Preoperational (2-7 years)';
      case CognitiveStage.concreteOperational:
        return 'Concrete Operational (7-11 years)';
      case CognitiveStage.formalOperational:
        return 'Formal Operational (11+ years)';
    }
  }

  /// Get database-compatible enum value (snake_case)
  String get databaseValue {
    switch (this) {
      case CognitiveStage.sensorimotor:
        return 'sensorimotor';
      case CognitiveStage.preoperational:
        return 'preoperational';
      case CognitiveStage.concreteOperational:
        return 'concrete_operational';
      case CognitiveStage.formalOperational:
        return 'formal_operational';
    }
  }

  String get description {
    switch (this) {
      case CognitiveStage.sensorimotor:
        return 'Learning through senses and actions';
      case CognitiveStage.preoperational:
        return 'Symbolic but illogical thinking';
      case CognitiveStage.concreteOperational:
        return 'Logical thinking about real objects';
      case CognitiveStage.formalOperational:
        return 'Abstract and hypothetical thinking';
    }
  }

  List<String> get indicators {
    switch (this) {
      case CognitiveStage.sensorimotor:
        return [
          'Object Permanence',
          'Cause-Effect Understanding',
          'Goal-Directed Behavior',
          'Imitation',
          'Sensory Exploration',
          'Coordination of Actions',
          'Recognition of Familiar People/Objects',
          'Trial-and-Error Learning',
          'Anticipation of Events',
          'Early Mental Representation',
        ];
      case CognitiveStage.preoperational:
        return [
          'Symbolic Thinking',
          'Egocentrism',
          'Centration',
          'Lack of Conservation',
          'Animistic Thinking',
          'Irreversibility',
          'Intuitive Thought',
          'Pretend Play',
          'Perceptual Dominance',
          'Egocentric Speech',
        ];
      case CognitiveStage.concreteOperational:
        return [
          'Conservation',
          'Reversibility',
          'Decentration',
          'Classification',
          'Seriation',
          'Transitive Inference',
          'Logical Operations',
          'Cause-and-Effect Reasoning',
          'Perspective-Taking',
          'Concrete Problem Solving',
        ];
      case CognitiveStage.formalOperational:
        return [
          'Abstract Thinking',
          'Hypothetical Reasoning',
          'Hypothetico-Deductive Reasoning',
          'Systematic Problem Solving',
          'Metacognition',
          'Moral Reasoning',
          'Relativistic Thinking',
          'Propositional Logic',
          'Future Orientation',
          'Ideological Thinking',
        ];
    }
  }
}

CognitiveStage getStageBageFromAge(int age) {
  if (age <= 2) {
    return CognitiveStage.sensorimotor;
  } else if (age <= 7) {
    return CognitiveStage.preoperational;
  } else if (age <= 11) {
    return CognitiveStage.concreteOperational;
  } else {
    return CognitiveStage.formalOperational;
  }
}

/// Convert display name (e.g., "Formal Operational (11+ years)") to database enum value
String stageDisplayNameToDatabaseValue(String displayName) {
  // Remove the age range part
  final stageName = displayName.split('(')[0].trim();
  
  switch (stageName.toLowerCase()) {
    case 'sensorimotor':
      return 'sensorimotor';
    case 'preoperational':
      return 'preoperational';
    case 'concrete operational':
      return 'concrete_operational';
    case 'formal operational':
      return 'formal_operational';
    default:
      // Fallback: try to convert to snake_case
      return stageName.toLowerCase().replaceAll(' ', '_');
  }
}
