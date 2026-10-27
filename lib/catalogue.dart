import 'package:flutter/material.dart';

class ExercisePreview {
  const ExercisePreview(this.title, this.prompt, this.focus);
  final String title;
  final String prompt;
  final String focus;
}

class TrainingModule {
  const TrainingModule(
    this.id,
    this.name,
    this.shortName,
    this.description,
    this.icon,
    this.previews,
  );
  final String id;
  final String name;
  final String shortName;
  final String description;
  final IconData icon;
  final List<ExercisePreview> previews;
}

const levels = ['Beginner', 'Intermediate', 'Advanced'];
const modules = [
  TrainingModule(
    'writing',
    'Writing Studio',
    'Write with clarity',
    'Turn a thought into words that connect.',
    Icons.edit_note_outlined,
    [
      ExercisePreview(
        'Make the everyday clear',
        'Explain how to prepare your favorite simple meal to someone who has never cooked it. Use 100–150 words and a clear sequence.',
        'One purpose, clear steps, useful details.',
      ),
      ExercisePreview(
        'Build a supported argument',
        'Should students have one day each week without scheduled classes? Write 300–500 words. Give two reasons, a concrete example, and a fair counterargument.',
        'A clear claim with relevant support.',
      ),
      ExercisePreview(
        'One idea, two audiences',
        'Explain how recommendation algorithms shape what people see. Write one version for a younger student and another for a school administrator. Note what you changed and why.',
        'Audience awareness without losing nuance.',
      ),
    ],
  ),
  TrainingModule(
    'reading',
    'Reading Lab',
    'Read beyond the words',
    'Find the main idea. Ask a better question.',
    Icons.menu_book_outlined,
    [
      ExercisePreview(
        'Find the main idea',
        'A neighborhood library moved its opening time from nine to eight. Morning visitors increased, but afternoon attendance stayed the same. Staff will review the change after a month.\n\nWhat changed, and what does the library still need to learn?',
        'Separate what the passage says from what you assume.',
      ),
      ExercisePreview(
        'Look for the missing evidence',
        'A café owner says reusable cups increased sales because sales rose after the cups were introduced. During the same month, the café also extended its opening hours.\n\nWhat other explanation should be considered? What evidence would help?',
        'Distinguish an observation from a causal claim.',
      ),
      ExercisePreview(
        'Compare two positions',
        'Position A: A later school start gives students more time to rest.\nPosition B: A later start complicates transport and family schedules.\n\nSummarize the strongest concern on each side. Propose information that would help evaluate both positions.',
        'Fair synthesis and evidence-aware conclusions.',
      ),
    ],
  ),
  TrainingModule(
    'speech',
    'Speech Studio',
    'Give your ideas a voice',
    'Prepare, rehearse, and learn by listening.',
    Icons.mic_none_outlined,
    [
      ExercisePreview(
        'An introduction that connects',
        'Plan a one-minute introduction about an interest you care about. Open with a specific moment, explain why it matters, and finish with one memorable thought.',
        'An opening, a main point, and a clear close.',
      ),
      ExercisePreview(
        'Explain something useful',
        'Prepare a three-minute explanation of a skill you know. Include one example and a transition between each main idea.',
        'Structure, intelligibility, and purposeful transitions.',
      ),
      ExercisePreview(
        'Speak to a skeptical audience',
        'Prepare a five-minute proposal to improve a shared space. Acknowledge a reasonable objection and explain the tradeoff behind your recommendation.',
        'Audience needs, emphasis, and a qualified conclusion.',
      ),
    ],
  ),
  TrainingModule(
    'memory',
    'Memory Trainer',
    'Make the words your own',
    'Build recall, one meaningful section at a time.',
    Icons.psychology_outlined,
    [
      ExercisePreview(
        'Remember the message',
        'Read this short message: “Clear communication begins with attention. Listen for the question before planning the answer. Then choose one useful idea and explain it simply.”\n\nImagine recalling its three ideas using only three keywords.',
        'Recall the meaning before checking the wording.',
      ),
      ExercisePreview(
        'Connect the sections',
        'Choose a short speech and divide it into an opening, two main ideas, and a close. Give each section a keyword and identify the transition to the next.',
        'Recall both ideas and the links between them.',
      ),
      ExercisePreview(
        'Recover your place',
        'Choose a familiar speech. Imagine starting from a middle section, then continuing to the close. Identify a phrase that would help you recover after forgetting a line.',
        'Flexible recall and graceful recovery.',
      ),
    ],
  ),
  TrainingModule(
    'debate',
    'Debate Arena',
    'Build a stronger argument',
    'Consider another view. Respond with purpose.',
    Icons.forum_outlined,
    [
      ExercisePreview(
        'A reason worth hearing',
        'Motion: Libraries should stay open on weekends. Choose a position and outline one claim, one reason, and one example. Identify which parts would need factual evidence.',
        'Connect your support to your claim.',
      ),
      ExercisePreview(
        'Respond to the real concern',
        'Motion: Schools should replace some printed materials with digital copies.\nScripted opposing view: “Some students cannot reliably access a device.”\n\nOutline a rebuttal that addresses access directly.',
        'Respond fairly instead of changing the subject.',
      ),
      ExercisePreview(
        'Defend a qualified position',
        'Motion: Cities should restrict private vehicles in busy centers. Explain your position, acknowledge a serious cost, and state a condition that might change your conclusion.',
        'Weigh tradeoffs and make uncertainty visible.',
      ),
    ],
  ),
  TrainingModule(
    'impromptu',
    'Impromptu Arena',
    'Think on your feet',
    'Meet an unexpected question with a clear idea.',
    Icons.bolt_outlined,
    [
      ExercisePreview(
        'A small change that helped',
        'What is one small change that made your day easier? Consider a point, a reason, an example, and a closing thought. Suggested future practice: 30 seconds to prepare, 60 seconds to answer.',
        'Answer directly with one concrete example.',
      ),
      ExercisePreview(
        'Explain your choice',
        'If you could improve one public space in your neighborhood, which would you choose and why? Suggested future practice: 15 seconds to prepare, 90 seconds to answer.',
        'Choose a direction and organize the explanation.',
      ),
      ExercisePreview(
        'Handle an unexpected follow-up',
        'You proposed a new community activity. Someone asks: “What would you do if very few people came?” Explain an adaptable response without pretending to know the outcome.',
        'Coherence, adaptability, and honest uncertainty.',
      ),
    ],
  ),
];
