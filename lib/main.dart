import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// --- FIXED ASYNC STARTUP INITIALIZATION ---
void main() async {
  // 1. Lock down native framework communication layer hooks
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Prevent active canvas distortion by pinning orientation bounds
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // 3. Force engine process thread block to hold until storage data metrics are loaded
  await UserData.load();

  runApp(
    const AppRestartScope(
      child: TileExplorerApp(),
    ),
  );
}

class TileExplorerApp extends StatelessWidget {
  const TileExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tile Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE1F5FE),
        primarySwatch: Colors.blue,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// --- GLOBAL STATE MANAGER ---
class UserData {
  static int coins = 250;
  static int highestUnlockedLevel = 1;
  static const int totalLevels = 50;
  static const String _installKey = 'app_installed_v1';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    bool isReturningUser = prefs.getBool(_installKey) ?? false;

    if (!isReturningUser) {
      coins = 250;
      highestUnlockedLevel = 1;
      await prefs.setBool(_installKey, true);
      await prefs.setInt('coins', coins);
      await prefs.setInt('highestUnlockedLevel', highestUnlockedLevel);
    } else {
      coins = prefs.getInt('coins') ?? 250;
      highestUnlockedLevel = prefs.getInt('highestUnlockedLevel') ?? 1;
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('highestUnlockedLevel', highestUnlockedLevel);
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    coins = 250;
    highestUnlockedLevel = 1;
    await prefs.setInt('coins', coins);
    await prefs.setInt('highestUnlockedLevel', highestUnlockedLevel);
  }
}

// --- SOUND MANAGER ---
class SoundManager {
  static void playTap() => SystemSound.play(SystemSoundType.click);
  static void playMatch() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }
  static void playWin() => HapticFeedback.vibrate();
  static void playLose() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.heavyImpact());
  }
}

// --- VFX MODELS ---
class ConfettiParticle {
  double x, y, vx, vy, size, opacity;
  Color color;
  ConfettiParticle({required this.x, required this.y, required this.vx, required this.vy, required this.color, required this.size, this.opacity = 1.0});
}

class FloatingText {
  final String text;
  double yOffset = 0.0;
  double opacity = 1.0;
  FloatingText({required this.text});
}

// --- LEVEL THEME DATA ---
class LevelTheme {
  final String name;
  final List<Color> gradient;
  final List<String> icons;
  final Color tileColor;
  final Color tileLockedColor;
  final BorderRadius tileBorderRadius;

  const LevelTheme({
    required this.name,
    required this.gradient,
    required this.icons,
    required this.tileColor,
    required this.tileLockedColor,
    required this.tileBorderRadius,
  });
}

// 20 unique level themes reused dynamically across all 50 levels via modulo wraps
final List<LevelTheme> levelThemes = [
  // Levels 1-4: Fruits (rounded square tiles)
  LevelTheme(
    name: 'Fruit Garden',
    gradient: [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)],
    icons: ['🍉', '🍌', '🍇', '🍓', '🍎'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFF8BBD0),
    tileBorderRadius: BorderRadius.circular(12),
  ),
  LevelTheme(
    name: 'Tropical Fruits',
    gradient: [const Color(0xFFFDAF75), const Color(0xFFFFF3CC)],
    icons: ['🍑', '🍒', '🥭', '🍍', '🥝', '🍋'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFFFE0B2),
    tileBorderRadius: BorderRadius.circular(12),
  ),
  LevelTheme(
    name: 'Veggie Patch',
    gradient: [const Color(0xFF84FAB0), const Color(0xFF8FD3F4)],
    icons: ['🥕', '🌽', '🥦', '🍆', '🧅', '🥬', '🫑'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFC8E6C9),
    tileBorderRadius: BorderRadius.circular(12),
  ),
  LevelTheme(
    name: 'Sweet Mix',
    gradient: [const Color(0xFFA18CD1), const Color(0xFFFBC2EB)],
    icons: ['🍰', '🍩', '🍪', '🧁', '🍫', '🍬', '🍭', '🧇'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFE1BEE7),
    tileBorderRadius: BorderRadius.circular(12),
  ),

  // Levels 5-8: Birds (medium rounded corner accents)
  LevelTheme(
    name: 'Bird Paradise',
    gradient: [const Color(0xFF43C6AC), const Color(0xFFF8FFAE)],
    icons: ['🐦', '🦜', '🦚', '🦉', '🐧'],
    tileColor: const Color(0xFFE8FFF5),
    tileLockedColor: const Color(0xFFB2DFDB),
    tileBorderRadius: BorderRadius.circular(6),
  ),
  LevelTheme(
    name: 'Tropical Birds',
    gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    icons: ['🦅', '🦆', '🦢', '🦩', '🕊️', '🦤'],
    tileColor: const Color(0xFFEFFFF5),
    tileLockedColor: const Color(0xFFA5D6A7),
    tileBorderRadius: BorderRadius.circular(6),
  ),
  LevelTheme(
    name: 'Night Birds',
    gradient: [const Color(0xFF1D3557), const Color(0xFF457B9D)],
    icons: ['🦇', '🦉', '🐦‍⬛', '🦅', '🦜', '🕊️', '🦚'],
    tileColor: const Color(0xFFE8F4FF),
    tileLockedColor: const Color(0xFFB0BEC5),
    tileBorderRadius: BorderRadius.circular(6),
  ),
  LevelTheme(
    name: 'Rainbow Birds',
    gradient: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
    icons: ['🦜', '🦩', '🦢', '🦚', '🦤', '🦅', '🐦', '🦆'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFFFF9C4),
    tileBorderRadius: BorderRadius.circular(6),
  ),

  // Levels 9-12: Animals (hexagonal feel - circular shape boundaries)
  LevelTheme(
    name: 'Safari Animals',
    gradient: [const Color(0xFFD4A373), const Color(0xFFFEFAE0)],
    icons: ['🦁', '🐘', '🦒', '🦓', '🐆'],
    tileColor: const Color(0xFFFFF8EE),
    tileLockedColor: const Color(0xFFD7CCC8),
    tileBorderRadius: BorderRadius.circular(26),
  ),
  LevelTheme(
    name: 'Forest Friends',
    gradient: [const Color(0xFF40916C), const Color(0xFFD8F3DC)],
    icons: ['🐺', '🦊', '🐻', '🦝', '🐗', '🦌'],
    tileColor: const Color(0xFFF0FFF4),
    tileLockedColor: const Color(0xFFC8E6C9),
    tileBorderRadius: BorderRadius.circular(26),
  ),
  LevelTheme(
    name: 'Jungle Pals',
    gradient: [const Color(0xFF004D40), const Color(0xFF80CBC4)],
    icons: ['🐒', '🦍', '🐊', '🐢', '🦎', '🐍', '🦜'],
    tileColor: const Color(0xFFE8FFF5),
    tileLockedColor: const Color(0xFFB2DFDB),
    tileBorderRadius: BorderRadius.circular(26),
  ),
  LevelTheme(
    name: 'Pet World',
    gradient: [const Color(0xFF6A0572), const Color(0xFFDDA0DD)],
    icons: ['🐶', '🐱', '🐰', '🐹', '🐸', '🐭', '🐼', '🐨'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFE1BEE7),
    tileBorderRadius: BorderRadius.circular(26),
  ),

  // Levels 13-16: Ocean (wave/asymmetric pill shaped borders)
  LevelTheme(
    name: 'Ocean Deep',
    gradient: [const Color(0xFF0077B6), const Color(0xFF90E0EF)],
    icons: ['🐠', '🐙', '🦈', '🐳', '🦀'],
    tileColor: const Color(0xFFE8F8FF),
    tileLockedColor: const Color(0xFFBBDEFB),
    tileBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(4), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
  ),
  LevelTheme(
    name: 'Reef Life',
    gradient: [const Color(0xFF48CAE4), const Color(0xFFCAF0F8)],
    icons: ['🐡', '🦑', '🦞', '🦐', '🐚', '🪸'],
    tileColor: const Color(0xFFF0FAFF),
    tileLockedColor: const Color(0xFFB2EBF2),
    tileBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(4), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
  ),
  LevelTheme(
    name: 'Deep Sea',
    gradient: [const Color(0xFF023E8A), const Color(0xFF0096C7)],
    icons: ['🐋', '🦭', '🐬', '🐟', '🦈', '🐙', '🪼'],
    tileColor: const Color(0xFFE0F4FF),
    tileLockedColor: const Color(0xFFC5CAE9),
    tileBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(4), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
  ),
  LevelTheme(
    name: 'Lagoon Mix',
    gradient: [const Color(0xFF00B4D8), const Color(0xFFADE8F4)],
    icons: ['🐠', '🦀', '🐡', '🦑', '🐙', '🦞', '🐚', '🪸'],
    tileColor: Colors.white,
    tileLockedColor: const Color(0xFFB3E5FC),
    tileBorderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(4), bottomLeft: Radius.circular(4), bottomRight: Radius.circular(20)),
  ),

  // Levels 17-20: Space (star/sharp flat geometric vectors)
  LevelTheme(
    name: 'Galaxy',
    gradient: [const Color(0xFF0D0D2B), const Color(0xFF1A1A5E)],
    icons: ['🚀', '🌙', '⭐', '🪐', '☄️'],
    tileColor: const Color(0xFF1E1E4A),
    tileLockedColor: const Color(0xFF12122E),
    tileBorderRadius: BorderRadius.zero,
  ),
  LevelTheme(
    name: 'Cosmos',
    gradient: [const Color(0xFF1A1A2E), const Color(0xFF16213E)],
    icons: ['👽', '🛸', '🌌', '💫', '🌠', '🔭'],
    tileColor: const Color(0xFF1E1E4A),
    tileLockedColor: const Color(0xFF12122E),
    tileBorderRadius: BorderRadius.zero,
  ),
  LevelTheme(
    name: 'Nebula',
    gradient: [const Color(0xFF2D1B69), const Color(0xFF11998E)],
    icons: ['🌟', '💥', '🌈', '🔮', '🧿', '💎', '⚡'],
    tileColor: const Color(0xFF2A1F5E),
    tileLockedColor: const Color(0xFF1A1040),
    tileBorderRadius: BorderRadius.zero,
  ),
  LevelTheme(
    name: 'Final Frontier',
    gradient: [const Color(0xFF000000), const Color(0xFF3D0066)],
    icons: ['🚀', '👽', '🛸', '🌙', '⭐', '🪐', '☄️', '🌌'],
    tileColor: const Color(0xFF1A0033),
    tileLockedColor: const Color(0xFF0D0020),
    tileBorderRadius: BorderRadius.zero,
  ),
];

// --- MAIN MENU SCREEN ---
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await UserData.load();
    if (mounted) setState(() => _loaded = true);
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("⚠️ Reset Progress?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This will lock all levels and reset your coins to 250. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await UserData.resetProgress();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reset to Level 1! 🔄"), backgroundColor: Colors.redAccent),
                );
              }
            },
            child: const Text("Reset", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ INTEGRATED NEW ROW: Dynamic Interactive Toolbar Bar With Settings Cog
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Settings button
                    GestureDetector(
                      onTap: () {
                        SoundManager.playTap();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {}));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
                      ),
                    ),
                    // Coin display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.white, size: 22),
                          const SizedBox(width: 6),
                          Text('${UserData.coins}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white.withValues(alpha: 0.95),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
                  child: Column(
                    children: [
                      Text("TILE EXPLORER", textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.blueAccent, letterSpacing: 2)),
                      SizedBox(height: 4),
                      Text("TRIPLE MATCH PUZZLE",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1), letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    _categoryChip('🍎 Fruits', '1-4'),
                    _categoryChip('🐦 Birds', '5-8'),
                    _categoryChip('🦁 Animals', '9-12'),
                    _categoryChip('🐠 Ocean', '13-16'),
                    _categoryChip('🚀 Space', '17-20'),
                    _categoryChip('🐉 Mythic', '21-25'),
                    _categoryChip('🧸 Toys', '26-30'),
                    _categoryChip('🍔 Foods', '31-35'),
                    _categoryChip('🗺️ Travel', '36-40'),
                    _categoryChip('🌤️ Sky', '41-45'),
                    _categoryChip('👾 Cyber', '46-50'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: UserData.totalLevels,
                      itemBuilder: (context, index) {
                        int lvlNum = index + 1;
                        bool isUnlocked = lvlNum <= UserData.highestUnlockedLevel;

                        // Safely wrap index using modulo to prevent out of bounds
                        LevelTheme theme = levelThemes[index % levelThemes.length];

                        return GestureDetector(
                          onTap: () {
                            if (isUnlocked) {
                              SoundManager.playTap();
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) => TileMatchScreen(selectedLevel: lvlNum),
                              )).then((_) => setState(() {}));
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: isUnlocked
                                  ? LinearGradient(colors: theme.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)
                                  : null,
                              color: isUnlocked ? null : Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isUnlocked ? [BoxShadow(color: theme.gradient[0].withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isUnlocked
                                    ? Text(theme.icons[0], style: const TextStyle(fontSize: 16))
                                    : const Icon(Icons.lock, color: Colors.white54, size: 16),
                                Text(
                                  "$lvlNum",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked ? Colors.white : Colors.white38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  elevation: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 72, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: () {
                  SoundManager.playTap();
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => TileMatchScreen(selectedLevel: UserData.highestUnlockedLevel),
                  )).then((_) => setState(() {}));
                },
                child: const Text("PLAY NOW", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white.withValues(alpha: 0.85)),
                onPressed: () { SoundManager.playTap(); _showResetDialog(); },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("RESET PROGRESS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String label, String levels) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
        Text(levels, style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }
}

// --- MATCH TILE ---
class MatchTile {
  final int id;
  final String icon;
  double x, y;
  final int layer;
  MatchTile({required this.id, required this.icon, required this.x, required this.y, required this.layer});
}

// --- GAME SCREEN ---
class TileMatchScreen extends StatefulWidget {
  final int selectedLevel;
  const TileMatchScreen({super.key, required this.selectedLevel});
  @override
  State<TileMatchScreen> createState() => _TileMatchScreenState();
}

class _TileMatchScreenState extends State<TileMatchScreen> with TickerProviderStateMixin {
  final int maxDockSize = 7;
  List<MatchTile> activeBoardTiles = [];
  List<String> dock = [];
  List<MatchTile> actionHistory = [];
  late int currentLevel;
  int score = 0;
  bool isGameOver = false;
  bool hasWon = false;
  int undoCount = 3, hintCount = 3, shuffleCount = 3;
  List<ConfettiParticle> particles = [];
  List<FloatingText> alertTexts = [];
  late AnimationController _vfxController;

  @override
  void initState() {
    super.initState();
    currentLevel = widget.selectedLevel;
    _vfxController = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(_updateVfx)..repeat();
    loadLevel(currentLevel);
  }

  @override
  void dispose() { _vfxController.dispose(); super.dispose(); }

  void _updateVfx() {
    if (!mounted) return;
    setState(() {
      for (var p in particles) { p.x += p.vx; p.y += p.vy; p.vy += 0.2; p.opacity -= 0.02; }
      particles.removeWhere((p) => p.opacity <= 0);
      for (var t in alertTexts) { t.yOffset -= 1.8; t.opacity -= 0.015; }
      alertTexts.removeWhere((t) => t.opacity <= 0);
    });
  }

  void _triggerExplosion() {
    final random = Random();
    final colors = [Colors.amber, Colors.orange, Colors.yellow, Colors.pink, Colors.cyan, Colors.lightGreenAccent];
    alertTexts.add(FloatingText(text: "+60 Coins! 🎉"));
    for (int i = 0; i < 35; i++) {
      double angle = random.nextDouble() * 2 * pi;
      double speed = random.nextDouble() * 7 + 4;
      particles.add(ConfettiParticle(
        x: 200.0 + random.nextInt(40), y: 580.0,
        vx: cos(angle) * speed, vy: sin(angle) * speed - 3,
        color: colors[random.nextInt(colors.length)], size: random.nextDouble() * 6 + 4,
      ));
    }
  }

  Map<String, int> _getLevelConfig(int level) {
    switch (level) {
      case 1:  return {'rows0':4,'cols0':4,'rows1':2,'cols1':4,'rows2':0,'cols2':0,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 2:  return {'rows0':5,'cols0':4,'rows1':2,'cols1':5,'rows2':0,'cols2':0,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 3:  return {'rows0':4,'cols0':5,'rows1':3,'cols1':4,'rows2':1,'cols2':4,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 4:  return {'rows0':5,'cols0':4,'rows1':4,'cols1':4,'rows2':2,'cols2':3,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 5:  return {'rows0':5,'cols0':5,'rows1':4,'cols1':4,'rows2':1,'cols2':7,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 6:  return {'rows0':6,'cols0':5,'rows1':4,'cols1':4,'rows2':2,'cols2':4,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 7:  return {'rows0':6,'cols0':5,'rows1':4,'cols1':5,'rows2':2,'cols2':4,'rows3':1,'cols3':2,'rows4':0,'cols4':0};
      case 8:  return {'rows0':6,'cols0':5,'rows1':5,'cols1':5,'rows2':2,'cols2':3,'rows3':1,'cols3':2,'rows4':0,'cols4':0};
      case 9:  return {'rows0':6,'cols0':5,'rows1':5,'cols1':5,'rows2':3,'cols2':3,'rows3':1,'cols3':2,'rows4':0,'cols4':0};
      case 10: return {'rows0':6,'cols0':5,'rows1':5,'cols1':5,'rows2':3,'cols2':3,'rows3':2,'cols3':2,'rows4':1,'cols4':1};
      case 11: return {'rows0':6,'cols0':6,'rows1':5,'cols1':5,'rows2':3,'cols2':4,'rows3':2,'cols3':2,'rows4':1,'cols4':1};
      case 12: return {'rows0':7,'cols0':5,'rows1':5,'cols1':5,'rows2':4,'cols2':4,'rows3':2,'cols3':3,'rows4':1,'cols4':2};
      case 13: return {'rows0':7,'cols0':6,'rows1':5,'cols1':5,'rows2':4,'cols2':4,'rows3':2,'cols3':3,'rows4':1,'cols4':2};
      case 14: return {'rows0':7,'cols0':6,'rows1':6,'cols1':5,'rows2':4,'cols2':4,'rows3':3,'cols3':3,'rows4':1,'cols4':2};
      case 15: return {'rows0':8,'cols0':6,'rows1':6,'cols1':5,'rows2':4,'cols2':4,'rows3':3,'cols3':3,'rows4':2,'cols4':2};
      case 16: return {'rows0':8,'cols0':6,'rows1':6,'cols1':6,'rows2':5,'cols2':4,'rows3':3,'cols3':3,'rows4':2,'cols4':2};
      case 17: return {'rows0':8,'cols0':6,'rows1':7,'cols1':5,'rows2':5,'cols2':5,'rows3':3,'cols3':4,'rows4':2,'cols4':3};
      case 18: return {'rows0':8,'cols0':7,'rows1':7,'cols1':5,'rows2':5,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':3};
      case 19: return {'rows0':9,'cols0':6,'rows1':7,'cols1':6,'rows2':5,'cols2':5,'rows3':4,'cols3':4,'rows4':3,'cols4':3};
      case 20: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':3,'cols4':3};

      case 21: return {'rows0':8,'cols0':6,'rows1':6,'cols1':6,'rows2':5,'cols2':5,'rows3':4,'cols3':3,'rows4':2,'cols4':0};
      case 22: return {'rows0':9,'cols0':6,'rows1':7,'cols1':6,'rows2':6,'cols2':5,'rows3':3,'cols3':4,'rows4':0,'cols4':0};
      case 23: return {'rows0':8,'cols0':7,'rows1':8,'cols1':6,'rows2':5,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':2};
      case 24: return {'rows0':9,'cols0':7,'rows1':7,'cols1':6,'rows2':6,'cols2':6,'rows3':5,'cols3':4,'rows4':3,'cols4':2};
      case 25: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':7,'cols2':5,'rows3':5,'cols3':5,'rows4':4,'cols4':3};
      case 26: return {'rows0':7,'cols0':5,'rows1':5,'cols1':5,'rows2':3,'cols2':3,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 27: return {'rows0':8,'cols0':5,'rows1':6,'cols1':5,'rows2':4,'cols2':4,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 28: return {'rows0':8,'cols0':6,'rows1':6,'cols1':5,'rows2':4,'cols2':4,'rows3':2,'cols3':2,'rows4':0,'cols4':0};
      case 29: return {'rows0':7,'cols0':7,'rows1':6,'cols1':6,'rows2':5,'cols2':5,'rows3':3,'cols3':3,'rows4':0,'cols4':0};
      case 30: return {'rows0':8,'cols0':7,'rows1':7,'cols1':6,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':1};
      case 31: return {'rows0':8,'cols0':6,'rows1':6,'cols1':5,'rows2':5,'cols2':4,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 32: return {'rows0':9,'cols0':6,'rows1':7,'cols1':5,'rows2':5,'cols2':5,'rows3':2,'cols3':2,'rows4':0,'cols4':0};
      case 33: return {'rows0':8,'cols0':7,'rows1':7,'cols1':6,'rows2':5,'cols2':5,'rows3':4,'cols3':3,'rows4':1,'cols4':1};
      case 34: return {'rows0':9,'cols0':6,'rows1':8,'cols1':6,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':2};
      case 35: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':6,'cols2':6,'rows3':5,'cols3':4,'rows4':3,'cols4':3};
      case 36: return {'rows0':8,'cols0':6,'rows1':7,'cols1':5,'rows2':4,'cols2':4,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
      case 37: return {'rows0':8,'cols0':7,'rows1':6,'cols1':6,'rows2':5,'cols2':5,'rows3':3,'cols3':2,'rows4':0,'cols4':0};
      case 38: return {'rows0':9,'cols0':6,'rows1':7,'cols1':6,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':1};
      case 39: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':5,'cols2':5,'rows3':5,'cols3':4,'rows4':3,'cols4':2};
      case 40: return {'rows0':9,'cols0':7,'rows1':8,'cols1':7,'rows2':7,'cols2':6,'rows3':5,'cols3':5,'rows4':4,'cols4':3};
      case 41: return {'rows0':8,'cols0':6,'rows1':6,'cols1':5,'rows2':4,'cols2':4,'rows3':2,'cols3':2,'rows4':0,'cols4':0};
      case 42: return {'rows0':9,'cols0':6,'rows1':7,'cols1':6,'rows2':5,'cols2':5,'rows3':3,'cols3':3,'rows4':1,'cols4':1};
      case 43: return {'rows0':8,'cols0':7,'rows1':7,'cols1':7,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':2};
      case 44: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':6,'cols2':6,'rows3':5,'cols3':5,'rows4':3,'cols4':3};
      case 45: return {'rows0':9,'cols0':7,'rows1':8,'cols1':7,'rows2':7,'cols2':6,'rows3':6,'cols3':5,'rows4':4,'cols4':4};
      case 46: return {'rows0':8,'cols0':6,'rows1':7,'cols1':5,'rows2':5,'cols2':4,'rows3':3,'cols3':2,'rows4':0,'cols4':0};
      case 47: return {'rows0':9,'cols0':6,'rows1':7,'cols1':6,'rows2':6,'cols2':5,'rows3':4,'cols3':4,'rows4':2,'cols4':1};
      case 48: return {'rows0':9,'cols0':7,'rows1':8,'cols1':6,'rows2':6,'cols2':5,'rows3':5,'cols3':4,'rows4':3,'cols4':2};
      case 49: return {'rows0':9,'cols0':7,'rows1':8,'cols1':7,'rows2':7,'cols2':6,'rows3':5,'cols3':5,'rows4':4,'cols4':3};
      case 50: return {'rows0':9,'cols0':7,'rows1':9,'cols1':7,'rows2':8,'cols2':6,'rows3':6,'cols3':6,'rows4':5,'cols4':5};

      default: return {'rows0':4,'cols0':4,'rows1':2,'cols1':4,'rows2':0,'cols2':0,'rows3':0,'cols3':0,'rows4':0,'cols4':0};
    }
  }

  void loadLevel(int level) {
    dock.clear(); actionHistory.clear(); particles.clear(); alertTexts.clear();
    isGameOver = false; hasWon = false; score = 0;
    undoCount = 3; hintCount = 3; shuffleCount = 3;

    final cfg = _getLevelConfig(level);
    int r0=cfg['rows0']!, c0=cfg['cols0']!, r1=cfg['rows1']!, c1=cfg['cols1']!,
        r2=cfg['rows2']!, c2=cfg['cols2']!, r3=cfg['rows3']!, c3=cfg['cols3']!,
        r4=cfg['rows4']!, c4=cfg['cols4']!;

    int total = r0*c0 + r1*c1 + r2*c2 + r3*c3 + r4*c4;
    while (total % 3 != 0) total--;

    LevelTheme theme = levelThemes[(level - 1) % levelThemes.length];
    List<String> icons = theme.icons;

    List<String> items = [];
    int iconIdx = 0;
    while (items.length < total) {
      String icon = icons[iconIdx % icons.length];
      items.add(icon); items.add(icon); items.add(icon);
      iconIdx++;
    }
    while (items.length > total) items.removeLast();
    items.shuffle();

    List<MatchTile> buffer = [];
    int ptr = 0;
    const double tileW = 0.17;
    const double tileH = 0.095;

    void fillGrid(int rows, int cols, double sx, double sy, int layer, double spX, double spY) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (ptr < items.length) {
            buffer.add(MatchTile(id: ptr, icon: items[ptr], x: sx+(c*spX), y: sy+(r*spY), layer: layer));
            ptr++;
          }
        }
      }
    }

    fillGrid(r0, c0, 0.04, 0.03, 0, tileW*0.88, tileH);
    if (r1>0) fillGrid(r1, c1, 0.10, 0.08, 1, tileW, tileH);
    if (r2>0) fillGrid(r2, c2, 0.16, 0.13, 2, tileW, tileH);
    if (r3>0) fillGrid(r3, c3, 0.22, 0.18, 3, tileW, tileH);
    if (r4>0) fillGrid(r4, c4, 0.28, 0.23, 4, tileW, tileH);

    setState(() => activeBoardTiles = buffer);
  }

  bool _isCovered(MatchTile target) {
    for (var other in activeBoardTiles) {
      if (other.layer > target.layer &&
          (other.x - target.x).abs() < 0.14 &&
          (other.y - target.y).abs() < 0.09) return true;
    }
    return false;
  }

  void _handleTileTap(MatchTile tile) {
    if (isGameOver || hasWon || _isCovered(tile)) return;
    SoundManager.playTap();
    HapticFeedback.lightImpact();

    setState(() {
      activeBoardTiles.remove(tile);
      actionHistory.add(tile);
      dock.add(tile.icon);

      int count = dock.where((i) => i == tile.icon).length;
      if (count == 3) {
        dock.removeWhere((i) => i == tile.icon);
        actionHistory.removeWhere((t) => t.icon == tile.icon);
        score += 60; UserData.coins += 15;
        UserData.save();
        _triggerExplosion();
        SoundManager.playMatch();
        HapticFeedback.mediumImpact();
      }

      if (dock.length >= maxDockSize) { isGameOver = true; SoundManager.playLose(); return; }

      if (activeBoardTiles.isEmpty) {
        if (dock.isEmpty) {
          hasWon = true; SoundManager.playWin();
          UserData.coins += 100;
          if (currentLevel == UserData.highestUnlockedLevel && UserData.highestUnlockedLevel < UserData.totalLevels) {
            UserData.highestUnlockedLevel++;
          }
          UserData.save();
        } else {
          isGameOver = true; SoundManager.playLose();
          _showSnack("Remaining tiles can't match! ❌", Colors.redAccent);
        }
        return;
      }

      if (_isDeadlocked()) {
        isGameOver = true; SoundManager.playLose();
        _showSnack("No More Matches! Shuffle to break deadlock! 🔄", Colors.orange);
      }
    });
  }

  bool _isDeadlocked() {
    List<String> combined = [...dock, ...activeBoardTiles.map((t) => t.icon)];
    for (String icon in {...combined}) {
      if (combined.where((i) => i == icon).length >= 3) return false;
    }
    return true;
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  void _doUndo() {
    if (undoCount <= 0 || actionHistory.isEmpty || isGameOver || hasWon) return;
    SoundManager.playTap();
    setState(() {
      undoCount--;
      MatchTile last = actionHistory.removeLast();
      int idx = dock.lastIndexOf(last.icon);
      if (idx != -1) dock.removeAt(idx);
      activeBoardTiles.add(last);
    });
  }

  void _doHint() {
    if (hintCount <= 0 || isGameOver || hasWon) return;
    SoundManager.playTap();
    MatchTile? hint;
    for (var icon in dock) {
      var m = activeBoardTiles.where((t) => t.icon == icon && !_isCovered(t));
      if (m.isNotEmpty) { hint = m.first; break; }
    }
    if (hint == null) {
      for (var t in activeBoardTiles) {
        if (!_isCovered(t) && activeBoardTiles.where((o) => o.icon == t.icon).length >= 3) { hint = t; break; }
      }
    }
    setState(() => hintCount--);
    _showSnack(hint != null ? "Look for the ${hint.icon}! 👆" : "No matches! Try Shuffle! 🔄",
        hint != null ? Colors.indigo : Colors.orange);
  }

  void _doShuffle() {
    if (shuffleCount <= 0 || activeBoardTiles.isEmpty || isGameOver || hasWon) return;
    SoundManager.playTap();
    setState(() {
      shuffleCount--;
      List<String> icons = activeBoardTiles.map((t) => t.icon).toList()..shuffle();
      for (int i = 0; i < activeBoardTiles.length; i++) {
        activeBoardTiles[i] = MatchTile(id: activeBoardTiles[i].id, icon: icons[i],
            x: activeBoardTiles[i].x, y: activeBoardTiles[i].y, layer: activeBoardTiles[i].layer);
      }
      isGameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    LevelTheme theme = levelThemes[(currentLevel - 1) % levelThemes.length];
    bool isDark = currentLevel >= 17;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: theme.gradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // --- TOP NAV BAR HEADER ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.home_rounded, size: 30, color: isDark ? Colors.white : Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              children: [
                                Text('Level $currentLevel',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                                Text(theme.name,
                                    style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.refresh_rounded, size: 26, color: isDark ? Colors.white70 : Colors.black54),
                              tooltip: 'Total App Refresh',
                              onPressed: () async {
                                SoundManager.playTap();

                                // 1. Force state variables to synchronize to storage blocks securely
                                await UserData.save();

                                // 2. Re-read the database parameters safely so no coin balances/levels get lost
                                await UserData.load();

                                // 3. Trigger the total root canvas framework re-render!
                                if (mounted) {
                                  AppRestartScope.restartApp(context);
                                }
                              },
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${UserData.coins}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Score: $score',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white60 : Colors.black54)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Stack(
                          children: activeBoardTiles.map((tile) {
                            bool covered = _isCovered(tile);
                            double left = (tile.x * constraints.maxWidth).clamp(0.0, constraints.maxWidth - 50);
                            double top = (tile.y * constraints.maxHeight).clamp(0.0, constraints.maxHeight - 52);
                            return Positioned(
                              left: left, top: top,
                              child: GestureDetector(
                                onTap: () => _handleTileTap(tile),
                                child: AnimatedScale(
                                  scale: covered ? 0.92 : 1.0,
                                  duration: const Duration(milliseconds: 150),
                                  child: Container(
                                    width: 48, height: 50,
                                    decoration: BoxDecoration(
                                      color: covered ? theme.tileLockedColor : theme.tileColor,
                                      borderRadius: theme.tileBorderRadius,
                                      border: Border.all(
                                        color: covered
                                            ? (isDark ? Colors.white12 : Colors.grey.shade300)
                                            : (isDark ? Colors.white24 : Colors.grey.shade200),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: covered ? 0.05 : 0.2),
                                          offset: Offset(0, covered ? 1 : 3 + tile.layer * 1.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Opacity(
                                        opacity: covered ? 0.35 : 1.0,
                                        child: Text(tile.icon, style: const TextStyle(fontSize: 24)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ),
                  ),
                  // --- FIXED HIGH-CONTRAST DOCK UI BAR ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                    ),
                    child: Row(
                      children: List.generate(maxDockSize, (index) {
                        bool occupied = index < dock.length;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: occupied
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: occupied
                                    ? Colors.transparent
                                    : Colors.white.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
                              boxShadow: occupied ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ] : null,
                            ),
                            child: Center(
                              child: Text(
                                occupied ? dock[index] : "",
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _powerupButton(Icons.reply_rounded, "Undo ($undoCount)", _doUndo, isDark),
                        _powerupButton(Icons.auto_awesome_rounded, "Hint ($hintCount)", _doHint, isDark),
                        _powerupButton(Icons.shuffle_rounded, "Shuffle ($shuffleCount)", _doShuffle, isDark),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, top: 2),
                    child: _buildActionButton(),
                  ),
                ],
              ),
              IgnorePointer(
                child: CustomPaint(size: Size.infinite, painter: ParticleCanvasPainter(particles: particles)),
              ),
              ...alertTexts.map((txt) => Positioned(
                left: 80, top: 500 + txt.yOffset,
                child: Opacity(
                  opacity: txt.opacity.clamp(0.0, 1.0),
                  child: Text(txt.text, style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, color: Colors.amber,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                  )),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _powerupButton(IconData icon, String label, VoidCallback onTap, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, size: 32), color: isDark ? Colors.white : Colors.indigo.shade900, onPressed: onTap),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
      ],
    );
  }

  Widget _buildActionButton() {
    if (isGameOver) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        onPressed: () => setState(() => loadLevel(currentLevel)),
        child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      );
    }
    if (hasWon) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        onPressed: () {
          if (currentLevel < UserData.totalLevels) {
            setState(() { currentLevel++; loadLevel(currentLevel); });
          } else {
            Navigator.pop(context);
          }
        },
        child: Text(currentLevel < UserData.totalLevels ? "NEXT LEVEL ▶" : "BACK TO MENU",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      );
    }
    return const SizedBox(height: 40);
  }
}

class ParticleCanvasPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  const ParticleCanvasPainter({required this.particles});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      if (p.opacity <= 0) continue;
      paint.color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- TOTAL APPLICATION REFRESH WRAPPER ---
class AppRestartScope extends StatefulWidget {
  final Widget child;
  const AppRestartScope({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_AppRestartScopeState>()?.restart();
  }

  @override
  State<AppRestartScope> createState() => _AppRestartScopeState();
}

class _AppRestartScopeState extends State<AppRestartScope> {
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}

// --- SETTINGS SCREEN ---
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isRefreshing = false;

  Future<void> _doFullRefresh() async {
    setState(() => _isRefreshing = true);
    // Save current progress first so nothing is lost
    await UserData.save();
    // Reload data fresh from storage
    await UserData.load();
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Game refreshed successfully!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      // Restart the whole app tree
      AppRestartScope.restartApp(context);
    }
  }

  Future<void> _doClearCache() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🧹 Clear Cache?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This clears temporary data and refreshes the app. Your progress and coins are NOT lost."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Clear & Refresh", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) await _doFullRefresh();
  }

  Future<void> _doForceUpdate() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("🔄 Force Restart", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("This will restart the app completely. Use this if you downloaded a new update and the game feels stuck."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await UserData.save();
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) AppRestartScope.restartApp(context);
            },
            child: const Text("Restart Now", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF00ACC1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text("Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PERFORMANCE SECTION ---
                      _sectionLabel("⚡ Performance & Updates"),
                      const SizedBox(height: 10),

                      // Refresh Game
                      _settingsTile(
                        icon: Icons.refresh_rounded,
                        iconColor: Colors.green,
                        title: "Refresh Game",
                        subtitle: "Fix lag, stutters, or slow loading",
                        trailing: _isRefreshing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                        onTap: _isRefreshing ? null : _doFullRefresh,
                      ),
                      const SizedBox(height: 10),

                      // Clear Cache
                      _settingsTile(
                        icon: Icons.cleaning_services_rounded,
                        iconColor: Colors.blue,
                        title: "Clear Cache",
                        subtitle: "Remove temp data, keeps your progress",
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                        onTap: _doClearCache,
                      ),
                      const SizedBox(height: 10),

                      // Force Restart for new update
                      _settingsTile(
                        icon: Icons.system_update_rounded,
                        iconColor: Colors.orange,
                        title: "Apply New Update",
                        subtitle: "Restart app after downloading an update",
                        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
                        onTap: _doForceUpdate,
                      ),

                      const SizedBox(height: 28),
                      // --- ACCOUNT SECTION ---
                      _sectionLabel("🎮 Game Data"),
                      const SizedBox(height: 10),

                      // Coins display
                      _settingsTile(
                        icon: Icons.monetization_on_rounded,
                        iconColor: Colors.amber,
                        title: "Your Coins",
                        subtitle: "Current balance",
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('${UserData.coins}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        onTap: null,
                      ),
                      const SizedBox(height: 10),

                      // Level display
                      _settingsTile(
                        icon: Icons.emoji_events_rounded,
                        iconColor: Colors.purple,
                        title: "Highest Level",
                        subtitle: "Your current progress",
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Level ${UserData.highestUnlockedLevel}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        onTap: null,
                      ),

                      const Spacer(),

                      // App version
                      Center(
                        child: Text(
                          "Tile Explorer v1.0.0",
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1));
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55))),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}