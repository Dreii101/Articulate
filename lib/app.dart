import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalogue.dart';
import 'advanced/advanced_page.dart';
import 'providers.dart';
import 'practice_page.dart';
import 'theme.dart';
import 'writing/writing_page.dart';
import 'reading/reading_page.dart';
import 'speech/speech_page.dart';
import 'memory/memory_page.dart';
import 'debate/debate_page.dart';
import 'impromptu/impromptu_page.dart';
import 'history/history_page.dart';
import 'data/data_page.dart';

class ArticulateApp extends ConsumerStatefulWidget {
  const ArticulateApp({super.key});
  @override
  ConsumerState<ArticulateApp> createState() => _ArticulateAppState();
}

class _ArticulateAppState extends ConsumerState<ArticulateApp> {
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  Future<void> _save(String key, String value) async {
    try {
      await ref.read(repositoryProvider).saveSetting(key, value);
    } catch (_) {
      _messenger.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Could not save the setting. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final saved = ref.watch(settingsProvider);
    final values = saved.value ?? const <String, String>{};
    final theme =
        ThemeMode.values.where((t) => t.name == values['theme']).firstOrNull ??
        ThemeMode.system;
    final reduceMotion = values['reduceMotion'] == 'true';
    return MaterialApp(
      scaffoldMessengerKey: _messenger,
      title: 'Articulate',
      debugShowCheckedModeBanner: false,
      theme: articulateTheme(Brightness.light),
      darkTheme: articulateTheme(Brightness.dark),
      themeMode: theme,
      themeAnimationDuration:
          reduceMotion ||
              WidgetsBinding
                  .instance
                  .platformDispatcher
                  .accessibilityFeatures
                  .disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 180),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: media.disableAnimations || reduceMotion,
          ),
          child: child!,
        );
      },
      home: _Shell(
        theme: theme,
        reduceMotion: reduceMotion,
        onThemeChanged: (value) => _save('theme', value.name),
        onMotionChanged: (value) => _save('reduceMotion', '$value'),
      ),
    );
  }
}

const _destinations = ['Today', 'Practice', 'History', 'Settings'];
const _icons = [
  Icons.wb_sunny_outlined,
  Icons.grid_view_outlined,
  Icons.history_outlined,
  Icons.tune_outlined,
];

class _Shell extends StatefulWidget {
  const _Shell({
    required this.theme,
    required this.reduceMotion,
    required this.onThemeChanged,
    required this.onMotionChanged,
  });
  final ThemeMode theme;
  final bool reduceMotion;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onMotionChanged;
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _selected = 0;
  void _select(int value) => setState(() => _selected = value);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final wide =
        media.size.width >= 900 &&
        media.size.height >= 650 &&
        media.textScaler.scale(1) <= 1.5;
    final pages = [
      _Today(onExplore: () => _select(1), onHistory: () => _select(2)),
      const _Practice(),
      _History(onExplore: () => _select(1)),
      _Settings(
        theme: widget.theme,
        reduceMotion: widget.reduceMotion,
        onThemeChanged: widget.onThemeChanged,
        onMotionChanged: widget.onMotionChanged,
      ),
    ];
    final content = FocusTraversalGroup(child: pages[_selected]);
    return Scaffold(
      appBar: wide ? null : AppBar(title: const _Brand(), toolbarHeight: 72),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Container(
                width: 228,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  border: Border(
                    right: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 34, 20, 48),
                      child: _Brand(),
                    ),
                    for (var i = 0; i < _destinations.length; i++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Material(
                          type: MaterialType.transparency,
                          child: ListTile(
                            key: ValueKey('nav-$i'),
                            selected: _selected == i,
                            selectedTileColor: colors.surfaceContainerHighest,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: Icon(_icons[i]),
                            title: Text(_destinations[i]),
                            onTap: () => _select(i),
                          ),
                        ),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.spa_outlined, color: colors.primary),
                          const SizedBox(height: 12),
                          Text(
                            'A little practice.\nA clearer voice.',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'OFFLINE • RELEASE CANDIDATE',
                            style: TextStyle(fontSize: 10, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: content),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _selected,
              onDestinationSelected: _select,
              destinations: [
                for (var i = 0; i < _destinations.length; i++)
                  NavigationDestination(
                    key: ValueKey('nav-$i'),
                    icon: Icon(_icons[i]),
                    label: _destinations[i],
                  ),
              ],
            ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.graphic_eq_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
      const SizedBox(width: 9),
      const Flexible(
        child: Text(
          'Articulate',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 23,
            letterSpacing: -.8,
          ),
        ),
      ),
    ],
  );
}

class _Page extends StatelessWidget {
  const _Page({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final String id, eyebrow, title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey(id),
    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width < 600 ? 20 : 40),
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Eyebrow(eyebrow),
            const SizedBox(height: 10),
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 10),
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            ...children,
          ],
        ),
      ),
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class _Today extends StatelessWidget {
  const _Today({required this.onExplore, required this.onHistory});
  final VoidCallback onExplore, onHistory;
  @override
  Widget build(BuildContext context) => _Page(
    id: 'today',
    eyebrow: 'Your communication studio',
    title: 'Make room for your voice.',
    subtitle: 'A quiet space to think clearly and express yourself.',
    children: [
      TodayProgress(onExplore: onExplore, onHistory: onHistory),
      const AdvancedPracticeLink(),
      _Surface(
        padding: EdgeInsets.zero,
        child: LayoutBuilder(
          builder: (context, box) {
            final copy = Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Eyebrow('Small steps. Meaningful growth.'),
                  const SizedBox(height: 16),
                  Text(
                    'Good ideas deserve\na clear voice.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Explore six ways to develop your communication. Find a skill that feels useful to you today.',
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    key: const ValueKey('explore'),
                    onPressed: onExplore,
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Explore the modules'),
                  ),
                ],
              ),
            );
            final art = ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/finding-your-voice.png',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                cacheWidth: 768,
                height: box.maxWidth > 700 ? 300 : 200,
                width: double.infinity,
              ),
            );
            if (box.maxWidth > 700 &&
                MediaQuery.textScalerOf(context).scale(1) < 1.5) {
              return Row(
                children: [
                  Expanded(flex: 6, child: copy),
                  Expanded(flex: 5, child: art),
                ],
              );
            }
            return Column(children: [copy, art]);
          },
        ),
      ),
      const SizedBox(height: 18),
      const _Notice(
        'Write and revise, read and reflect, or rehearse and listen in Speech Studio.',
      ),
      const SizedBox(height: 32),
      _SectionTitle(
        'Find your starting point',
        action: TextButton(
          onPressed: onExplore,
          child: const Text('View all six'),
        ),
      ),
      const SizedBox(height: 16),
      _ModuleGrid(items: [modules[0], modules[2], modules[5]]),
      const SizedBox(height: 32),
      _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow('The approach'),
            const SizedBox(height: 10),
            Text(
              'One idea. One attempt. One improvement.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose a skill, save an attempt, and reflect on one useful change. Your drafts, recordings and reviews stay on this device.',
            ),
          ],
        ),
      ),
    ],
  );
}

class _Practice extends StatelessWidget {
  const _Practice();
  @override
  Widget build(BuildContext context) => const _Page(
    id: 'practice',
    eyebrow: 'Six ways to grow',
    title: 'Choose your direction.',
    subtitle: 'Explore a skill, read an exercise, and picture your next step.',
    children: [
      _Notice(
        'All six modules are ready, including Debate Arena and Impromptu Arena. All practice stays on this device.',
      ),
      SizedBox(height: 24),
      AdvancedPracticeLink(),
      SizedBox(height: 16),
      _ModuleGrid(items: modules),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.spaceBetween,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 24,
    runSpacing: 8,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      ?action,
    ],
  );
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.items});
  final List<TrainingModule> items;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final scale = MediaQuery.textScalerOf(context).scale(1);
      final columns = box.maxWidth >= 930 && scale <= 1.3
          ? 3
          : box.maxWidth >= 620 && scale <= 1.5
          ? 2
          : 1;
      final width = (box.maxWidth - (columns - 1) * 16) / columns;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final module in items)
            SizedBox(
              width: width,
              child: _Surface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              module.icon,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Eyebrow(
                            {
                                  'writing',
                                  'reading',
                                  'speech',
                                  'memory',
                                  'debate',
                                  'impromptu',
                                }.contains(module.id)
                                ? 'Ready to practice'
                                : 'Preview',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      module.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(module.description),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      key: ValueKey('module-${module.id}'),
                      onPressed: () => _openModule(context, module),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: Text(
                        module.id == 'writing'
                            ? 'Open Writing Studio'
                            : module.id == 'reading'
                            ? 'Open Reading Lab'
                            : module.id == 'speech'
                            ? 'Open Speech Studio'
                            : module.id == 'memory'
                            ? 'Open Memory Trainer'
                            : module.id == 'debate'
                            ? 'Open Debate Arena'
                            : module.id == 'impromptu'
                            ? 'Open Impromptu Arena'
                            : 'Explore preview',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

void _openModule(BuildContext context, TrainingModule module) {
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 180),
      reverseTransitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) =>
          module.id == 'writing'
          ? const WritingStudioPage()
          : module.id == 'reading'
          ? const ReadingLabPage()
          : module.id == 'speech'
          ? const SpeechStudioPage()
          : module.id == 'memory'
          ? const MemoryLibraryPage()
          : module.id == 'debate'
          ? const DebateLibraryPage()
          : module.id == 'impromptu'
          ? const ImpromptuSetupPage()
          : ModulePreviewPage(module: module),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class ModulePreviewPage extends ConsumerStatefulWidget {
  const ModulePreviewPage({super.key, required this.module});
  final TrainingModule module;
  @override
  ConsumerState<ModulePreviewPage> createState() => _ModulePreviewPageState();
}

class _ModulePreviewPageState extends ConsumerState<ModulePreviewPage> {
  int _level = 0;
  bool _creating = false;
  Future<void> _draft() async {
    setState(() => _creating = true);
    try {
      final exercise = ref
          .read(exercisesProvider)
          .singleWhere(
            (e) =>
                e.id == '${widget.module.id}-${levels[_level].toLowerCase()}',
          );
      final id = await ref
          .read(repositoryProvider)
          .createDraft(exercise, DateTime.now());
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => savedPracticePage(id, widget.module.id),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The draft could not be opened. Your saved work has not been changed.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = widget.module.previews[_level];
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.name)),
      body: SafeArea(
        child: _Page(
          id: 'preview-${widget.module.id}',
          eyebrow: 'Module preview',
          title: widget.module.shortName,
          subtitle: widget.module.description,
          children: [
            const _Notice(
              'Read a sample exercise below. Guided practice in this module is coming later.',
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < levels.length; i++)
                  ChoiceChip(
                    key: ValueKey('level-$i'),
                    label: Text(levels[i]),
                    selected: _level == i,
                    onSelected: (_) => setState(() => _level = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _Surface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Eyebrow('${levels[_level]} • Exercise preview'),
                  const SizedBox(height: 16),
                  Semantics(
                    header: true,
                    child: Text(
                      preview.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SelectableText(
                    preview.prompt,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 16),
                  const _Eyebrow('What you’ll work on'),
                  const SizedBox(height: 8),
                  Text(
                    preview.focus,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('create-draft'),
              onPressed: _creating ? null : _draft,
              icon: const Icon(Icons.note_add_outlined),
              label: Text(
                _creating ? 'Opening draft…' : 'Save a practice draft',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use a saved response and stage timer. Module-specific practice and recording are coming later.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Icon(
          Icons.info_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(message)),
    ],
  );
}

class _History extends ConsumerWidget {
  const _History({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _Page(
    id: 'history',
    eyebrow: 'Your journey',
    title: 'Progress with perspective.',
    subtitle:
        'A place for your work, your reflections, and the changes you notice.',
    children: [HistoryPanel(onExplore: onExplore)],
  );
}

class _Settings extends StatelessWidget {
  const _Settings({
    required this.theme,
    required this.reduceMotion,
    required this.onThemeChanged,
    required this.onMotionChanged,
  });
  final ThemeMode theme;
  final bool reduceMotion;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onMotionChanged;
  @override
  Widget build(BuildContext context) => _Page(
    id: 'settings',
    eyebrow: 'Make yourself comfortable',
    title: 'Your space, your way.',
    subtitle: 'Simple choices for a more comfortable experience.',
    children: [
      _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Follow your device, or choose a light or dark space.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final mode in ThemeMode.values)
                  ChoiceChip(
                    key: ValueKey('theme-${mode.name}'),
                    label: Text(switch (mode) {
                      ThemeMode.system => 'System',
                      ThemeMode.light => 'Light',
                      ThemeMode.dark => 'Dark',
                    }),
                    selected: theme == mode,
                    onSelected: (_) => onThemeChanged(mode),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduce motion'),
              subtitle: const Text(
                'Use immediate page and theme changes. Your device’s reduced-motion setting is always respected.',
              ),
              value: reduceMotion,
              onChanged: onMotionChanged,
            ),
            const SizedBox(height: 8),
            const Text('Appearance choices are saved on this device.'),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _Surface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local by design',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            const Text(
              'Practice stays in local app storage. Exporting writes a plain archive to the destination you choose. No account is needed.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('open-data-management'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const DataManagementPage(),
                ),
              ),
              icon: const Icon(Icons.storage_outlined),
              label: const Text('Data & privacy'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const _Notice(
        'Articulate • Local practice 1.1.0 RC\nBuilt for thoughtful practice on Android and Windows.',
      ),
      const SizedBox(height: 12),
      TextButton(
        onPressed: () => showLicensePage(
          context: context,
          applicationName: 'Articulate',
          applicationVersion: '1.1.0 RC (12)',
        ),
        child: const Text('Open-source licenses'),
      ),
    ],
  );
}
