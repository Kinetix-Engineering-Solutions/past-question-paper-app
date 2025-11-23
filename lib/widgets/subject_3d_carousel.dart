import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A brain neuron network widget with subjects scattered in multiple directions.
/// Camera stays fixed at center. When you select a node, it animates to camera position.
class Subject3DCarousel extends StatefulWidget {
  final List<SubjectOption> subjects;
  final Function(SubjectOption subject, int index) onSubjectSelected;

  const Subject3DCarousel({
    Key? key,
    required this.subjects,
    required this.onSubjectSelected,
  }) : super(key: key);

  @override
  State<Subject3DCarousel> createState() => _Subject3DCarouselState();
}

class SubjectOption {
  final String name;
  final Color color;
  final bool isAvailable;
  final String subtitle;

  SubjectOption({
    required this.name,
    required this.color,
    required this.isAvailable,
    required this.subtitle,
  });
}

class _Subject3DCarouselState extends State<Subject3DCarousel>
    with SingleTickerProviderStateMixin {
  int _focusedIndex = 0;

  // Base neuron positions - organic scatter in multiple directions
  late List<Offset> _basePositions;

  // Current animated positions for each neuron
  late List<Offset> _currentPositions;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Store start positions for animation lerp
  late List<Offset> _startPositions;

  // Drag tracking for smooth manual movement
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _generateNeuronPositions();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animation.addListener(() {
      setState(() {
        for (int i = 0; i < _currentPositions.length; i++) {
          _currentPositions[i] = Offset.lerp(
            _startPositions[i],
            _calculateTargetPosition(i),
            _animation.value,
          )!;
        }
      });
    });

    _currentPositions = List.from(_basePositions);
    _startPositions = List.from(_basePositions);
    _arrangeNodesAroundFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Generate organic neuron positions in multiple directions
  void _generateNeuronPositions() {
    _basePositions = [];
    final random = math.Random(42); // Fixed seed for consistent layout
    const minDistance = 150.0; // Minimum distance between node centers
    const maxAttempts = 200; // More attempts for better distribution

    final totalSubjects = widget.subjects.length;

    for (int i = 0; i < totalSubjects; i++) {
      bool positionFound = false;
      int attempts = 0;

      while (!positionFound && attempts < maxAttempts) {
        // Random angle for full 360° distribution
        final angle = random.nextDouble() * 2 * math.pi;

        // Random radius with preference for spreading out
        // Use a non-linear distribution to avoid clustering at center or edge
        final radiusNormalized = math.pow(random.nextDouble(), 0.7).toDouble();
        final radius = 120.0 + (radiusNormalized * 200.0); // Range: 120-320px

        final x = math.cos(angle) * radius;
        final y = math.sin(angle) * radius;
        final newPosition = Offset(x, y);

        // Check if this position is far enough from all existing positions
        bool tooClose = false;
        for (final existingPos in _basePositions) {
          final distance = (newPosition - existingPos).distance;
          if (distance < minDistance) {
            tooClose = true;
            break;
          }
        }

        if (!tooClose) {
          _basePositions.add(newPosition);
          positionFound = true;
        }

        attempts++;
      }

      // Fallback: if we couldn't find a position, use a spiral pattern
      if (!positionFound) {
        final angle =
            (i / totalSubjects) * 2 * math.pi * 2.5; // 2.5 full rotations
        final radius = 120.0 + (i / totalSubjects) * 200.0;
        final x = math.cos(angle) * radius;
        final y = math.sin(angle) * radius;
        _basePositions.add(Offset(x, y));
      }
    }
  }

  // Calculate target position for a node based on focused node
  Offset _calculateTargetPosition(int index) {
    final focusedBasePos = _basePositions[_focusedIndex];
    final offsetToCenter = -focusedBasePos;
    return _basePositions[index] + offsetToCenter + _dragOffset;
  }

  // Arrange nodes so focused node is at center
  void _arrangeNodesAroundFocus() {
    _startPositions = List.from(_currentPositions);
    _animationController.forward(from: 0.0);
  }

  void _changeFocusWithSteps(int steps) {
    setState(() {
      _focusedIndex = (_focusedIndex + steps) % widget.subjects.length;
      if (_focusedIndex < 0) _focusedIndex += widget.subjects.length;
    });
    _arrangeNodesAroundFocus();
  }

  void _snapToNearest() {
    // Find the node closest to center after drag
    double minDistance = double.infinity;
    int nearestIndex = _focusedIndex;

    for (int i = 0; i < _currentPositions.length; i++) {
      final distance = _currentPositions[i].distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }

    if (nearestIndex != _focusedIndex) {
      setState(() {
        _focusedIndex = nearestIndex;
      });
      _arrangeNodesAroundFocus();
    } else {
      // Just spring back to current focus
      _arrangeNodesAroundFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Title and description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              Text(
                'Your Subjects',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe or tap to switch subjects',
                style: textTheme.bodyMedium?.copyWith(
                  color: textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Neural network with pan gesture
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Center(
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _dragOffset += details.delta;
                    });
                  },
                  onPanEnd: (details) {
                    _isDragging = false;
                    final velocity = details.velocity.pixelsPerSecond;
                    final speed = velocity.distance;

                    // Check if it's a fast swipe
                    if (speed > 300) {
                      // Use velocity direction to determine focus change
                      int steps = (speed / 500).round().clamp(1, 3);

                      if (velocity.dx.abs() > velocity.dy.abs()) {
                        // Horizontal swipe
                        final direction = velocity.dx > 0 ? -steps : steps;
                        _changeFocusWithSteps(direction);
                      } else {
                        // Vertical swipe
                        final direction = velocity.dy > 0 ? -steps : steps;
                        _changeFocusWithSteps(direction);
                      }
                    } else {
                      // Slow drag - snap to nearest
                      _snapToNearest();
                    }

                    setState(() {
                      _dragOffset = Offset.zero;
                    });
                  },
                  onPanCancel: () {
                    setState(() {
                      _isDragging = false;
                      _dragOffset = Offset.zero;
                    });
                  },
                  child: ClipRect(
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Container(
                        color: Colors.transparent,
                        child: Stack(
                          children: [
                            // Draw neural connections
                            CustomPaint(
                              size: Size(width, height),
                              painter: _NeuralConnectionsPainter(
                                neuronPositions: _currentPositions,
                                focusedIndex: _focusedIndex,
                                colors: widget.subjects
                                    .map((s) => s.color)
                                    .toList(),
                                screenSize: Size(width, height),
                              ),
                            ),
                            // Draw neuron nodes
                            ..._buildNeuronNodes(Size(width, height)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNeuronNodes(Size screenSize) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);

    return List.generate(widget.subjects.length, (index) {
      final position = _currentPositions[index];
      final adjustedPosition = center + position;

      // Check if neuron is in viewport
      if (adjustedPosition.dx < -100 ||
          adjustedPosition.dx > screenSize.width + 100 ||
          adjustedPosition.dy < -100 ||
          adjustedPosition.dy > screenSize.height + 100) {
        return const SizedBox.shrink();
      }

      final isFocused = index == _focusedIndex;
      final nodeSize = isFocused ? 130.0 : 100.0;

      return Positioned(
        left: adjustedPosition.dx - (nodeSize / 2),
        top: adjustedPosition.dy - (nodeSize / 2),
        child: _buildNeuronNode(index, isFocused),
      );
    });
  }

  Widget _buildNeuronNode(int index, bool isFocused) {
    final subject = widget.subjects[index];
    final size = isFocused ? 130.0 : 100.0;
    final isAvailable = subject.isAvailable;

    return GestureDetector(
      onTap: () {
        if (isFocused && isAvailable) {
          // Select the subject
          widget.onSubjectSelected(subject, index);
        } else {
          // Switch focus to this node - it will animate to center
          setState(() {
            _focusedIndex = index;
          });
          _arrangeNodesAroundFocus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isAvailable ? subject.color : subject.color.withOpacity(0.4),
          border: Border.all(color: Colors.white, width: isFocused ? 5 : 3),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: subject.color.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Subject name inside node
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  subject.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isFocused ? 14 : 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Coming Soon badge for unavailable subjects
            if (!isAvailable)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SOON',
                      style: TextStyle(
                        color: subject.color,
                        fontWeight: FontWeight.bold,
                        fontSize: isFocused ? 9 : 7,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            // Lock icon for unavailable subjects (focused only)
            if (!isAvailable && isFocused)
              Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing neural network connections between subject nodes
class _NeuralConnectionsPainter extends CustomPainter {
  final List<Offset> neuronPositions;
  final int focusedIndex;
  final List<Color> colors;
  final Size screenSize;

  _NeuralConnectionsPainter({
    required this.neuronPositions,
    required this.focusedIndex,
    required this.colors,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (neuronPositions.isEmpty) return;

    final center = Offset(screenSize.width / 2, screenSize.height / 2);

    // Draw connections from focused neuron to nearby neurons
    for (int i = 0; i < neuronPositions.length; i++) {
      if (i == focusedIndex) continue;

      final startPos = center + neuronPositions[focusedIndex];
      final endPos = center + neuronPositions[i];

      // Only draw connections to nearby neurons
      final distance =
          (neuronPositions[i] - neuronPositions[focusedIndex]).distance;
      if (distance > 250) continue;

      final opacity = (1.0 - (distance / 250)).clamp(0.1, 0.4);

      _drawNeuralConnection(
        canvas,
        startPos,
        endPos,
        colors[focusedIndex % colors.length],
        colors[i % colors.length],
        opacity,
      );
    }
  }

  void _drawNeuralConnection(
    Canvas canvas,
    Offset start,
    Offset end,
    Color startColor,
    Color endColor,
    double opacity,
  ) {
    // Create organic curved path
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Slight curve for organic feel
    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + (start.dy - end.dy) * 0.1,
      (start.dy + end.dy) / 2 + (end.dx - start.dx) * 0.1,
    );

    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, end.dx, end.dy);

    // Draw connection line
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          startColor.withOpacity(opacity),
          endColor.withOpacity(opacity),
        ],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_NeuralConnectionsPainter oldDelegate) {
    return oldDelegate.focusedIndex != focusedIndex ||
        oldDelegate.neuronPositions != neuronPositions;
  }
}
