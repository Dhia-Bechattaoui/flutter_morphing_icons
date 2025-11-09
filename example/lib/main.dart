import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';

void main() {
  runApp(const MorphingIconsApp());
}

class MorphingIconsApp extends StatelessWidget {
  const MorphingIconsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Morphing Icons Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MorphingIconsDemo(),
    );
  }
}

class MorphingIconsDemo extends StatefulWidget {
  const MorphingIconsDemo({super.key});

  @override
  State<MorphingIconsDemo> createState() => _MorphingIconsDemoState();
}

class _MorphingIconsDemoState extends State<MorphingIconsDemo> {
  final GlobalKey _previewKey = GlobalKey();
  final List<String> _animationTypes = const [
    'Cross Fade',
    'Scale',
    'Slide',
    'Rotate',
    'Custom',
  ];

  final Map<String, Curve> _curveOptions = const {
    'Ease In Out': Curves.easeInOut,
    'Ease Out Back': Curves.easeOutBack,
    'Linear': Curves.linear,
    'Fast Out Slow In': Curves.fastOutSlowIn,
  };

  int _currentAnimationType = 0;
  int _previewStateIndex = 0;
  double _durationMs = 400;
  double _scaleFactor = 1.25;
  double _slideOffset = 28;
  double _rotationTurns =
      0.6; // expressed in turns for UX, converted to radians
  Curve _selectedCurve = Curves.easeInOut;
  Timer? _previewKickTimer;
  bool _customFade = true;
  bool _customScale = false;
  bool _customSlide = false;
  bool _customRotate = false;
  List<Widget> get _previewStates => const [
        Icon(Icons.favorite_border, size: 72, color: Colors.red),
        Icon(Icons.favorite, size: 72, color: Colors.red),
        Icon(Icons.favorite, size: 72, color: Colors.pink),
        Icon(Icons.favorite, size: 72, color: Colors.purple),
      ];

  MorphingAnimationConfig get _currentConfig {
    final duration = Duration(milliseconds: _durationMs.round());

    switch (_currentAnimationType) {
      case 1:
        return MorphingAnimationConfig.scale(
          duration: duration,
          curve: _selectedCurve,
          scaleFactor: _scaleFactor,
        );
      case 2:
        return MorphingAnimationConfig.slide(
          duration: duration,
          curve: _selectedCurve,
          slideOffset: Offset(0, -_slideOffset),
        );
      case 3:
        return MorphingAnimationConfig.rotate(
          duration: duration,
          curve: _selectedCurve,
          rotationAngle: _rotationTurns * 3.141592653589793 * 2,
        );
      case 4:
        final fadeSelected = _customFade;
        final scaleSelected = _customScale;
        final slideSelected = _customSlide;
        final rotateSelected = _customRotate;

        final selectedCount = [
          fadeSelected,
          scaleSelected,
          slideSelected,
          rotateSelected
        ].where((e) => e).length;

        if (selectedCount == 0 ||
            (fadeSelected &&
                !scaleSelected &&
                !slideSelected &&
                !rotateSelected)) {
          return MorphingAnimationConfig.crossFade(
            duration: duration,
            curve: _selectedCurve,
          );
        }

        if (!fadeSelected &&
            scaleSelected &&
            !slideSelected &&
            !rotateSelected) {
          return MorphingAnimationConfig.scale(
            duration: duration,
            curve: _selectedCurve,
            scaleFactor: _scaleFactor,
          );
        }

        if (!fadeSelected &&
            slideSelected &&
            !scaleSelected &&
            !rotateSelected) {
          return MorphingAnimationConfig.slide(
            duration: duration,
            curve: _selectedCurve,
            slideOffset: Offset(0, -_slideOffset),
          );
        }

        if (!fadeSelected &&
            rotateSelected &&
            !scaleSelected &&
            !slideSelected) {
          return MorphingAnimationConfig.rotate(
            duration: duration,
            curve: _selectedCurve,
            rotationAngle: _rotationTurns * 2 * math.pi,
          );
        }

        return MorphingAnimationConfig.custom(
          duration: duration,
          curve: _selectedCurve,
          parameters: {
            'fade': fadeSelected,
            'scale': scaleSelected,
            'scaleFactor': _scaleFactor,
            'slide': slideSelected,
            'slideOffset': Offset(0, -_slideOffset),
            'rotate': rotateSelected,
            'rotationAngle': _rotationTurns * 2 * math.pi,
          },
        );
      default:
        return MorphingAnimationConfig.crossFade(
          duration: duration,
          curve: _selectedCurve,
        );
    }
  }

  void _goToState(int stateIndex) {
    final target = stateIndex % _previewStates.length;
    final state = _previewKey.currentState;
    if (state == null) return;

    (state as dynamic).goTo(target);
    setState(() {
      _previewStateIndex = target;
    });
  }

  void _nextState() {
    final nextIndex = (_previewStateIndex + 1) % _previewStates.length;
    _goToState(nextIndex);
  }

  void _previousState() {
    final prevIndex = (_previewStateIndex - 1 + _previewStates.length) %
        _previewStates.length;
    _goToState(prevIndex);
  }

  void _resetState() {
    _goToState(0);
  }

  void _queuePreviewKick() {
    _previewKickTimer?.cancel();
    _previewKickTimer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      final state = _previewKey.currentState;
      if (state == null) return;

      if (_currentAnimationType == _animationTypes.length - 1) {
        final requiresStateChange =
            _customScale || _customSlide || _customRotate;
        if (requiresStateChange) {
          final nextIndex = (_previewStateIndex + 1) % _previewStates.length;
          (state as dynamic).goTo(nextIndex);
          setState(() => _previewStateIndex = nextIndex);
        } else {
          (state as dynamic).replay();
        }
      } else {
        _nextState();
      }
    });
  }

  @override
  void dispose() {
    _previewKickTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Morphing Icons Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInteractivePreview(context),
                const SizedBox(height: 32),
                _FeatureSection(
                  title: 'Animation Types',
                  description:
                      'Compare built-in animation styles and see how the transitions behave.',
                  children: [
                    _FeatureTile(
                      title: 'Cross Fade',
                      description:
                          'Simple fade between states. Perfect when you want the quickest visual change.',
                      preview: AutoMorphingPreview(
                        states: const [
                          Icon(Icons.wifi_off, size: 48),
                          Icon(Icons.wifi, size: 48, color: Colors.blue),
                        ],
                        config: MorphingAnimationConfig.crossFade(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Scale',
                      description:
                          'Adds emphasis with scale and fade. Customize duration, curve, and scale factor.',
                      preview: AutoMorphingPreview(
                        states: const [
                          Icon(Icons.play_arrow, size: 48, color: Colors.green),
                          Icon(Icons.pause, size: 48, color: Colors.green),
                        ],
                        config: MorphingAnimationConfig.scale(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.elasticOut,
                          scaleFactor: 1.35,
                        ),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Slide',
                      description:
                          'Slide-in transitions with adjustable offset for directional emphasis.',
                      preview: AutoMorphingPreview(
                        states: const [
                          Icon(Icons.cloud, size: 48, color: Colors.indigo),
                          Icon(Icons.cloud_download,
                              size: 48, color: Colors.indigo),
                          Icon(Icons.cloud_done,
                              size: 48, color: Colors.indigo),
                        ],
                        config: MorphingAnimationConfig.slide(
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          slideOffset: const Offset(0, -24),
                        ),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Rotate',
                      description:
                          'Rotational morphing that works well for refresh or sync indicators.',
                      preview: AutoMorphingPreview(
                        states: const [
                          Icon(Icons.refresh, size: 48, color: Colors.orange),
                          Icon(Icons.sync, size: 48, color: Colors.orange),
                          Icon(Icons.done, size: 48, color: Colors.green),
                        ],
                        config: MorphingAnimationConfig.rotate(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOutBack,
                          rotationAngle: 3.141592653589793,
                        ),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Custom',
                      description:
                          'Create bespoke animations by combining transforms, opacity, and more.',
                      preview: AutoMorphingPreview(
                        states: const [
                          Icon(Icons.bolt, size: 48, color: Colors.amber),
                          Icon(Icons.bolt_outlined,
                              size: 48, color: Colors.amber),
                        ],
                        config: MorphingAnimationConfig.custom(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutQuart,
                          builder: (child, animation) {
                            return Transform.scale(
                              scale: 0.8 + (animation.value * 0.4),
                              child: Transform.rotate(
                                angle: animation.value * 1.2,
                                child: Opacity(
                                  opacity: animation.value,
                                  child: child,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _FeatureSection(
                  title: 'Flexible Content',
                  description:
                      'Morph any widget—not just icons. Mix shapes, colors, and custom layouts.',
                  children: [
                    _FeatureTile(
                      title: 'Status Indicator',
                      description: 'Swap between success and error chips.',
                      preview: AutoMorphingPreview(
                        states: [
                          _StatusChip(
                            color: Colors.green,
                            label: 'Success',
                            icon: Icons.check,
                          ),
                          _StatusChip(
                            color: Colors.red,
                            label: 'Error',
                            icon: Icons.error,
                          ),
                          _StatusChip(
                            color: Colors.orange,
                            label: 'Warning',
                            icon: Icons.warning,
                          ),
                        ],
                        config: MorphingAnimationConfig.slide(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          slideOffset: const Offset(16, 0),
                        ),
                      ),
                    ),
                    _FeatureTile(
                      title: 'Custom Widgets',
                      description:
                          'Animate between any Flutter widgets, including complex layouts.',
                      preview: AutoMorphingPreview(
                        states: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.calendar_today,
                                color: Colors.blue),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.event_available,
                                color: Colors.purple),
                          ),
                        ],
                        config: MorphingAnimationConfig.crossFade(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _FeatureSection(
                  title: 'Responsive Layouts',
                  description:
                      'The widget adapts to any layout. Resize the window or rotate your device to see it in action.',
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: LayoutBuilder(
                          builder: (context, box) {
                            final isWide = box.maxWidth > 500;
                            final itemSize = isWide ? 96.0 : 72.0;
                            final states = [
                              const Icon(Icons.light_mode,
                                  color: Colors.amber, size: 48),
                              const Icon(Icons.dark_mode,
                                  color: Colors.deepPurple, size: 48),
                            ];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dynamic sizing (${isWide ? 'wide' : 'compact'} layout)',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: List.generate(
                                    isWide ? 6 : 4,
                                    (_) => SizedBox(
                                      width: itemSize,
                                      height: itemSize,
                                      child: Center(
                                        child: AutoMorphingPreview(
                                          states: states,
                                          config:
                                              MorphingAnimationConfig.rotate(
                                            duration: const Duration(
                                                milliseconds: 450),
                                            curve: Curves.easeInOut,
                                            rotationAngle:
                                                3.141592653589793 / 2,
                                          ),
                                          interval: const Duration(
                                              milliseconds: 1200),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _FeatureSection(
                  title: 'Multiple Instances',
                  description:
                      'Run many morphing icons at once to showcase the lightweight animations.',
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(
                            8,
                            (index) => AutoMorphingPreview(
                              states: const [
                                Icon(Icons.bookmark_border, size: 36),
                                Icon(Icons.bookmark,
                                    size: 36, color: Colors.teal),
                              ],
                              config: MorphingAnimationConfig.crossFade(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              ),
                              interval:
                                  Duration(milliseconds: 700 + (index * 80)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInteractivePreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interactive Preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Experiment with configurations and trigger state changes programmatically.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Center(
              child: MorphingIcon(
                key: _previewKey,
                states: _previewStates,
                config: _currentConfig,
                onStateChanged: (state) {
                  if (!mounted) return;
                  final schedulerPhase =
                      SchedulerBinding.instance.schedulerPhase;
                  if (schedulerPhase == SchedulerPhase.idle ||
                      schedulerPhase == SchedulerPhase.postFrameCallbacks) {
                    setState(() => _previewStateIndex = state);
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _previewStateIndex = state);
                      }
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _previousState,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
                FilledButton.icon(
                  onPressed: _nextState,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                ),
                FilledButton.tonalIcon(
                  onPressed: _resetState,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Current State: $_previewStateIndex · Animation: ${_animationTypes[_currentAnimationType]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ConfigDropdown<String>(
                  label: 'Animation Type',
                  value: _animationTypes[_currentAnimationType],
                  items: _animationTypes,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _currentAnimationType = _animationTypes.indexOf(value);
                      if (_currentAnimationType != _animationTypes.length - 1) {
                        _customFade = true;
                        _customScale = false;
                      }
                    });
                    _queuePreviewKick();
                  },
                ),
                _ConfigDropdown<String>(
                  label: 'Curve',
                  value: _curveOptions.entries
                      .firstWhere(
                        (entry) => entry.value == _selectedCurve,
                        orElse: () => _curveOptions.entries.first,
                      )
                      .key,
                  items: _curveOptions.keys.toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCurve = _curveOptions[value]!;
                    });
                    _queuePreviewKick();
                  },
                ),
                _ConfigSlider(
                  label: 'Duration (${_durationMs.round()}ms)',
                  min: 150,
                  max: 1200,
                  value: _durationMs,
                  onChanged: (value) => setState(() {
                    _durationMs = value;
                  }),
                  onChangeEnd: (_) => _queuePreviewKick(),
                ),
                if (_currentAnimationType == 1 ||
                    (_currentAnimationType == 4 && _customScale))
                  _ConfigSlider(
                    label: 'Scale Factor (${_scaleFactor.toStringAsFixed(2)}x)',
                    min: 1,
                    max: 1.8,
                    value: _scaleFactor,
                    onChanged: (value) => setState(() {
                      _scaleFactor = value;
                    }),
                    onChangeEnd: (_) => _queuePreviewKick(),
                  ),
                if (_currentAnimationType == 2 ||
                    (_currentAnimationType == 4 && _customSlide))
                  _ConfigSlider(
                    label:
                        'Slide Offset (${_slideOffset.toStringAsFixed(0)}px)',
                    min: 0,
                    max: 60,
                    value: _slideOffset,
                    onChanged: (value) => setState(() {
                      _slideOffset = value;
                    }),
                    onChangeEnd: (_) => _queuePreviewKick(),
                  ),
                if (_currentAnimationType == 3 ||
                    (_currentAnimationType == 4 && _customRotate))
                  _ConfigSlider(
                    label:
                        'Rotation (${_rotationTurns.toStringAsFixed(2)} turns)',
                    min: 0,
                    max: 1.5,
                    value: _rotationTurns,
                    onChanged: (value) => setState(() {
                      _rotationTurns = value;
                    }),
                    onChangeEnd: (_) => _queuePreviewKick(),
                  ),
              ],
            ),
            if (_currentAnimationType == _animationTypes.length - 1)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilterChip(
                      label: const Text('Fade'),
                      selected: _customFade,
                      onSelected: (value) {
                        setState(() {
                          _customFade = value;
                          if (!_customFade &&
                              !_customScale &&
                              !_customSlide &&
                              !_customRotate) {
                            _customFade = true;
                          }
                        });
                        _queuePreviewKick();
                      },
                    ),
                    FilterChip(
                      label: const Text('Scale'),
                      selected: _customScale,
                      onSelected: (value) {
                        setState(() {
                          _customScale = value;
                          if (!_customFade &&
                              !_customScale &&
                              !_customSlide &&
                              !_customRotate) {
                            _customFade = true;
                          }
                        });
                        _queuePreviewKick();
                      },
                    ),
                    FilterChip(
                      label: const Text('Slide'),
                      selected: _customSlide,
                      onSelected: (value) {
                        setState(() {
                          _customSlide = value;
                          if (!_customFade &&
                              !_customScale &&
                              !_customSlide &&
                              !_customRotate) {
                            _customFade = true;
                          }
                        });
                        _queuePreviewKick();
                      },
                    ),
                    FilterChip(
                      label: const Text('Rotate'),
                      selected: _customRotate,
                      onSelected: (value) {
                        setState(() {
                          _customRotate = value;
                          if (!_customFade &&
                              !_customScale &&
                              !_customSlide &&
                              !_customRotate) {
                            _customFade = true;
                          }
                        });
                        _queuePreviewKick();
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConfigDropdown<T> extends StatelessWidget {
  const _ConfigDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          DropdownButtonFormField<T>(
            initialValue: value,
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ConfigSlider extends StatelessWidget {
  const _ConfigSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.onChangeEnd,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Slider(
            min: min,
            max: max,
            value: value.clamp(min, max),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ],
      ),
    );
  }
}

class _FeatureSection extends StatelessWidget {
  const _FeatureSection({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: children,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.description,
    required this.preview,
  });

  final String title;
  final String description;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              Center(child: preview),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.color,
    required this.label,
    required this.icon,
  });

  final Color color;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AutoMorphingPreview extends StatefulWidget {
  const AutoMorphingPreview({
    super.key,
    required this.states,
    required this.config,
    this.interval = const Duration(seconds: 2),
  });

  final List<Widget> states;
  final MorphingAnimationConfig config;
  final Duration interval;

  @override
  State<AutoMorphingPreview> createState() => _AutoMorphingPreviewState();
}

class _AutoMorphingPreviewState extends State<AutoMorphingPreview> {
  final GlobalKey _key = GlobalKey();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(widget.interval, (_) => _advance());
    });
  }

  void _advance() {
    final state = _key.currentState;
    if (!mounted || state == null) return;
    _currentIndex = (_currentIndex + 1) % widget.states.length;
    (state as dynamic).goTo(_currentIndex);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MorphingIcon(
      key: _key,
      states: widget.states,
      config: widget.config,
    );
  }
}
