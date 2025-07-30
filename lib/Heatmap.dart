import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;

class FootballHeatmap extends StatefulWidget {
  const FootballHeatmap({super.key});

  @override
  State<FootballHeatmap> createState() => _FootballHeatmapState();
}

class _FootballHeatmapState extends State<FootballHeatmap>
    with TickerProviderStateMixin {
  List<Offset> playerPositions = [];
  double intensity = 0.8;
  bool showContours = true;
  bool showPoints = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _generateRealisticPlayerPositions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateRealisticPlayerPositions() {
    final random = Random();
    playerPositions.clear();

    for (int i = 0; i < 200; i++) {
      playerPositions.add(Offset(
        random.nextDouble() * 105,
        random.nextDouble() * 22 + 5,
      ));
    }

    for (int i = 0; i < 400; i++) {
      playerPositions.add(Offset(
        random.nextDouble() * 105,
        random.nextDouble() * 24 + 22,
      ));
    }

    for (int i = 0; i < 150; i++) {
      playerPositions.add(Offset(
        random.nextDouble() * 105,
        random.nextDouble() * 22 + 46,
      ));
    }

    _addHotspot(52.5, 15, 80);
    _addHotspot(20, 34, 60);
    _addHotspot(85, 34, 60);
    _addHotspot(52.5, 34, 100);

    setState(() {});
  }

  void _addHotspot(double x, double y, int count) {
    final random = Random();
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final radius = random.nextGaussian() * 8 + 5;
      final dx = cos(angle) * radius;
      final dy = sin(angle) * radius;
      
      final newX = (x + dx).clamp(0.0, 105.0);
      final newY = (y + dy).clamp(0.0, 68.0);
      
      playerPositions.add(Offset(newX, newY));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text('Football Heat Map Analytics'),
        actions: [
          IconButton(
            icon: Icon(showContours ? Icons.waves : Icons.grain),
            onPressed: () => setState(() => showContours = !showContours),
          ),
          IconButton(
            icon: Icon(showPoints ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => showPoints = !showPoints),
          ),
        ],
      ),
      body: Column(
        children: [
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
                              child: Column(
              children: [
                Row(
                  children: [
                    const Text('Intensity: ', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: Slider(
                        value: intensity,
                        min: 0.1,
                        max: 2.0,
                        divisions: 19,
                        onChanged: (value) => setState(() => intensity = value),
                        activeColor: Colors.green[400],
                      ),
                    ),
                    Text('${(intensity * 100).toInt()}%', 
                         style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _generateRealisticPlayerPositions,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Regenerate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _generateFormationBased(),
                      icon: const Icon(Icons.sports_soccer),
                      label: const Text('4-4-2 Formation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 105 / 68,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: FootballHeatmapPainter(
                            positions: playerPositions,
                            intensity: intensity,
                            showContours: showContours,
                            showPoints: showPoints,
                            animationValue: _animationController.value,
                          ),
                          size: Size.infinite,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Low Activity  ', style: TextStyle(color: Colors.white70)),
                Container(
                  height: 20,
                  width: 100,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                      ],
                    ),
                  ),
                ),
                const Text('  High Activity', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _generateFormationBased() {
    playerPositions.clear();
    final random = Random();

    final formations = [
      [52.5, 62],
      [15, 50], [35, 48], [70, 48], [90, 50],
      [20, 35], [40, 32], [65, 32], [85, 35],
      [40, 18], [65, 18],
    ];

    for (var pos in formations) {
      for (int i = 0; i < 50; i++) {
        final dx = random.nextGaussian() * 8;
        final dy = random.nextGaussian() * 6;
        final x = (pos[0] + dx).clamp(0.0, 105.0);
        final y = (pos[1] + dy).clamp(0.0, 68.0);
        playerPositions.add(Offset(x, y));
      }
    }

    setState(() {});
  }
}

class FootballHeatmapPainter extends CustomPainter {
  final List<Offset> positions;
  final double intensity;
  final bool showContours;
  final bool showPoints;
  final double animationValue;

  FootballHeatmapPainter({
    required this.positions,
    required this.intensity,
    required this.showContours,
    required this.showPoints,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawFootballPitch(canvas, size);

    if (positions.isEmpty) return;

    const gridWidth = 84;
    const gridHeight = 54;
    final densityGrid = List.generate(
      gridHeight,
      (_) => List.filled(gridWidth, 0.0),
    );

    for (var pos in positions) {
      final gridX = (pos.dx / 105 * (gridWidth - 1)).round();
      final gridY = (pos.dy / 68 * (gridHeight - 1)).round();

      for (int y = 0; y < gridHeight; y++) {
        for (int x = 0; x < gridWidth; x++) {
          final distance = sqrt(pow(x - gridX, 2) + pow(y - gridY, 2));
          final influence = exp(-distance * distance / (50 * intensity));
          densityGrid[y][x] += influence;
        }
      }
    }

    double maxDensity = 0;
    for (var row in densityGrid) {
      for (var cell in row) {
        if (cell > maxDensity) maxDensity = cell;
      }
    }

    if (maxDensity == 0) return;

    _drawHeatmap(canvas, size, densityGrid, maxDensity);

    if (showContours) {
      _drawContours(canvas, size, densityGrid, maxDensity);
    }

    if (showPoints) {
      _drawPoints(canvas, size);
    }
  }

  void _drawFootballPitch(Canvas canvas, Size size) {
    final pitchPaint = Paint()
      ..color = const Color(0xFF2D5A3D)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), pitchPaint);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      linePaint,
    );

    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      linePaint,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      size.height * 0.12,
      linePaint,
    );

    final goalWidth = size.height * 0.32;
    final goalHeight = size.width * 0.05;
    
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - goalWidth / 2,
        0,
        goalWidth,
        goalHeight,
      ),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        centerX - goalWidth / 2,
        size.height - goalHeight,
        goalWidth,
        goalHeight,
      ),
      linePaint,
    );

    final penaltyWidth = size.height * 0.65;
    final penaltyHeight = size.width * 0.17;

    canvas.drawRect(
      Rect.fromLTWH(
        centerX - penaltyWidth / 2,
        0,
        penaltyWidth,
        penaltyHeight,
      ),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        centerX - penaltyWidth / 2,
        size.height - penaltyHeight,
        penaltyWidth,
        penaltyHeight,
      ),
      linePaint,
    );
  }

  void _drawHeatmap(Canvas canvas, Size size, List<List<double>> densityGrid, double maxDensity) {
    final gridHeight = densityGrid.length;
    final gridWidth = densityGrid[0].length;

    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        final density = densityGrid[y][x] / maxDensity;
        if (density < 0.1) continue;

        final rect = Rect.fromLTWH(
          x * size.width / gridWidth,
          y * size.height / gridHeight,
          size.width / gridWidth + 1,
          size.height / gridHeight + 1,
        );

        final color = _getHeatColor(density);
        final paint = Paint()
          ..color = color.withOpacity(density * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawContours(Canvas canvas, Size size, List<List<double>> densityGrid, double maxDensity) {
    final contourLevels = [0.2, 0.4, 0.6, 0.8];
    final gridHeight = densityGrid.length;
    final gridWidth = densityGrid[0].length;

    for (double level in contourLevels) {
      final contourPaint = Paint()
        ..color = _getHeatColor(level).withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int y = 1; y < gridHeight - 1; y++) {
        for (int x = 1; x < gridWidth - 1; x++) {
          final currentDensity = densityGrid[y][x] / maxDensity;
          
          if (currentDensity >= level) {
            final neighbors = [
              densityGrid[y-1][x] / maxDensity < level,
              densityGrid[y+1][x] / maxDensity < level,
              densityGrid[y][x-1] / maxDensity < level,
              densityGrid[y][x+1] / maxDensity < level,
            ];

            if (neighbors.contains(true)) {
              final center = Offset(
                x * size.width / gridWidth + size.width / gridWidth / 2,
                y * size.height / gridHeight + size.height / gridHeight / 2,
              );
              
              canvas.drawCircle(center, 4, contourPaint);
            }
          }
        }
      }
    }
  }

  void _drawPoints(Canvas canvas, Size size) {
    final pointPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    for (var pos in positions) {
      final x = pos.dx / 105 * size.width;
      final y = pos.dy / 68 * size.height;
      canvas.drawCircle(Offset(x, y), 1.5, pointPaint);
    }
  }

  Color _getHeatColor(double intensity) {
    final colors = [
      const Color(0x00000000), // Transparent
      const Color(0xFF0066FF), // Blue
      const Color(0xFF00FF66), // Green
      const Color(0xFFFFFF00), // Yellow
      const Color(0xFFFF6600), // Orange
      const Color(0xFFFF0000), // Red
    ];

    final scaledIntensity = intensity.clamp(0.0, 1.0) * (colors.length - 1);
    final index = scaledIntensity.floor();
    final fraction = scaledIntensity - index;

    if (index >= colors.length - 1) return colors.last;

    return Color.lerp(colors[index], colors[index + 1], fraction) ?? colors[index];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension RandomExtension on Random {
  double nextGaussian() {
    final u1 = nextDouble();
    final u2 = nextDouble();
    return sqrt(-2 * log(u1)) * cos(2 * pi * u2);
  }
}