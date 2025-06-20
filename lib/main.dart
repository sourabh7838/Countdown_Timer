import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class CountdownApp extends StatefulWidget {
  const CountdownApp({super.key});

  @override
  CountdownAppState createState() => CountdownAppState();
}

class CountdownAppState extends State<CountdownApp> {
  Timer? _timer;
  int _currentSeconds = 25 * 60; // 25 minutes default
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.pomodoro;
  int _pomodoroCount = 0;

  // Settings
  int _pomodoroDuration = 25;
  int _shortBreakDuration = 5;
  int _longBreakDuration = 15;
  int _longBreakInterval = 4;
  bool _autoStartBreaks = false;
  bool _autoStartPomodoros = false;
  bool _darkMode = false;
  String _alarmSound = 'Kitchen';

  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  Task? _currentTask;

  // Update the color constants with modern colors
  final Color _pomodoroColor = const Color(0xFF2D2F3E); // Modern dark blue-grey for focus
  final Color _shortBreakColor = const Color(0xFF3D5A80); // Soft blue for short break
  final Color _longBreakColor = const Color(0xFF486B8F); // Deep blue for long break

  // Add gradient colors for each mode
  List<Color> _getGradientColors() {
    switch (_currentMode) {
      case TimerMode.pomodoro:
        return [
          const Color(0xFF2D2F3E),
          const Color(0xFF393B4B),
        ];
      case TimerMode.shortBreak:
        return [
          const Color(0xFF3D5A80),
          const Color(0xFF4B6B94),
        ];
      case TimerMode.longBreak:
        return [
          const Color(0xFF486B8F),
          const Color(0xFF577CA3),
        ];
    }
  }

  // Add this method to get the current background color
  Color _getCurrentBackgroundColor() {
    switch (_currentMode) {
      case TimerMode.pomodoro:
        return _pomodoroColor;
      case TimerMode.shortBreak:
        return _shortBreakColor;
      case TimerMode.longBreak:
        return _longBreakColor;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      switch (_currentMode) {
        case TimerMode.pomodoro:
          _currentSeconds = _pomodoroDuration * 60;
          break;
        case TimerMode.shortBreak:
          _currentSeconds = _shortBreakDuration * 60;
          break;
        case TimerMode.longBreak:
          _currentSeconds = _longBreakDuration * 60;
          break;
      }
    });
  }

  void _toggleTimer() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
        _isRunning = false;
      } else {
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _handleTimerComplete();
        }
      });
    });
  }

  void _handleTimerComplete() {
    if (_currentMode == TimerMode.pomodoro) {
      if (_currentTask != null) {
        setState(() {
          _currentTask!.completedPomodoros++;
        });
      }
      _pomodoroCount++;
      if (_pomodoroCount % _longBreakInterval == 0) {
        _switchMode(TimerMode.longBreak);
      } else {
        _switchMode(TimerMode.shortBreak);
      }
      if (_autoStartBreaks) {
        _startTimer();
      }
    } else {
      _switchMode(TimerMode.pomodoro);
      if (_autoStartPomodoros) {
        _startTimer();
      }
    }
  }

  void _switchMode(TimerMode mode) {
    setState(() {
      _currentMode = mode;
      switch (mode) {
        case TimerMode.pomodoro:
          _currentSeconds = _pomodoroDuration * 60;
          break;
        case TimerMode.shortBreak:
          _currentSeconds = _shortBreakDuration * 60;
          break;
        case TimerMode.longBreak:
          _currentSeconds = _longBreakDuration * 60;
          break;
      }
      _timer?.cancel();
      _isRunning = false;
    });
  }

  String get _timerDisplay {
    int minutes = _currentSeconds ~/ 60;
    int seconds = _currentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _currentColor {
    switch (_currentMode) {
      case TimerMode.pomodoro:
        return const Color(0xFF468B97);
      case TimerMode.shortBreak:
        return const Color(0xFF468B97);
      case TimerMode.longBreak:
        return const Color(0xFF468B97);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 360;
        final isMediumScreen = screenWidth < 600;
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: _getCurrentBackgroundColor(),
          ),
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: gradientColors[0],
              elevation: 0,
              title: Row(
                children: [
                  const Icon(Icons.timer, size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    'Countdown Timer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.bar_chart),
                  onPressed: _showReportDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showSettingsDialog,
                ),
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                  stops: const [0.3, 1.0],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height - 
                        MediaQuery.of(context).padding.top - 
                        MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: _buildModernTimer(isSmallScreen),
                        ),
                        // Tasks Section
                        Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tasks',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 20 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white70,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    color: const Color(0xFF2A2A2A),
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: 'clear_finished',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white70,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Clear finished tasks',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuDivider(),
                                      PopupMenuItem<String>(
                                        value: 'clear_all',
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.clear_all,
                                              color: Colors.white70,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Clear all tasks',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.9),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onSelected: (String value) {
                                      switch (value) {
                                        case 'clear_finished':
                                          _clearFinishedTasks();
                                          break;
                                        case 'clear_all':
                                          _clearAllTasks();
                                          break;
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white24, thickness: 1),
                              // Task List
                              if (_tasks.isNotEmpty) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: _buildTaskList(),
                                ),
                                const SizedBox(height: 20),
                                // Task Statistics
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.timer_outlined, color: Colors.white70),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Pomos: ${_getCompletedPomodoros()}/${_getTotalPomodoros()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.flag_outlined, color: Colors.white70),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Finish At: ${_getFinishTime()}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // Add Task Button
                              InkWell(
                                onTap: _addTask,
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Add Task',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTimer(bool isSmallScreen) {
    final minutes = (_currentSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_currentSeconds % 60).toString().padLeft(2, '0');

    return LayoutBuilder(
      builder: (context, constraints) {
        final timerFontSize = isSmallScreen ? 80.0 : 120.0;
        final verticalPadding = isSmallScreen ? 20.0 : 40.0;
        
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer Display
              Padding(
                padding: EdgeInsets.symmetric(vertical: verticalPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$minutes:$seconds',
                      style: TextStyle(
                        fontSize: timerFontSize,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mode Selector
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildModeButton(TimerMode.pomodoro, 'Pomodoro'),
                            _buildModeButton(TimerMode.shortBreak, 'Short Break'),
                            _buildModeButton(TimerMode.longBreak, 'Long Break'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _timer?.cancel();
                          _isRunning = false;
                          switch (_currentMode) {
                            case TimerMode.pomodoro:
                              _currentSeconds = _pomodoroDuration * 60;
                              break;
                            case TimerMode.shortBreak:
                              _currentSeconds = _shortBreakDuration * 60;
                              break;
                            case TimerMode.longBreak:
                              _currentSeconds = _longBreakDuration * 60;
                              break;
                          }
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      iconSize: isSmallScreen ? 24 : 32,
                      color: Colors.white.withOpacity(0.7),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      ),
                    ),
                  ),
                  // Start/Pause Button
                  ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _getCurrentBackgroundColor(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 32 : 48,
                        vertical: isSmallScreen ? 12 : 16
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isRunning ? 'PAUSE' : 'START',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 20,
                        fontWeight: FontWeight.w600,
                        color: _getCurrentBackgroundColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeButton(TimerMode mode, String label) {
    final isSelected = _currentMode == mode;
    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(isSelected ? 1 : 0.7),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    // Create temporary variables to hold settings
    int tempPomodoroMinutes = _pomodoroDuration;
    int tempShortBreakMinutes = _shortBreakDuration;
    int tempLongBreakMinutes = _longBreakDuration;
    int tempLongBreakInterval = _longBreakInterval;
    bool tempAutoStartBreaks = _autoStartBreaks;
    bool tempAutoStartPomodoros = _autoStartPomodoros;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Timer Section
                  const Text(
                    'TIMER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Pomodoro Duration
                  _buildTimeSettingField(
                    'Pomodoro',
                    tempPomodoroMinutes,
                    (value) => setDialogState(() => tempPomodoroMinutes = value),
                  ),
                  const SizedBox(height: 16),

                  // Short Break Duration
                  _buildTimeSettingField(
                    'Short Break',
                    tempShortBreakMinutes,
                    (value) => setDialogState(() => tempShortBreakMinutes = value),
                  ),
                  const SizedBox(height: 16),

                  // Long Break Duration
                  _buildTimeSettingField(
                    'Long Break',
                    tempLongBreakMinutes,
                    (value) => setDialogState(() => tempLongBreakMinutes = value),
                  ),
                  const SizedBox(height: 24),

                  // Auto Start Section
                  const Text(
                    'AUTO START',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Auto Start Breaks Switch
                  _buildSwitchSetting(
                    'Auto Start Breaks',
                    tempAutoStartBreaks,
                    (value) => setDialogState(() => tempAutoStartBreaks = value),
                  ),
                  const SizedBox(height: 12),

                  // Auto Start Pomodoros Switch
                  _buildSwitchSetting(
                    'Auto Start Pomodoros',
                    tempAutoStartPomodoros,
                    (value) => setDialogState(() => tempAutoStartPomodoros = value),
                  ),
                  const SizedBox(height: 24),

                  // Intervals Section
                  const Text(
                    'INTERVALS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Long Break Interval
                  _buildTimeSettingField(
                    'Long Break Interval',
                    tempLongBreakInterval,
                    (value) => setDialogState(() => tempLongBreakInterval = value),
                    isInterval: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _pomodoroDuration = tempPomodoroMinutes;
                  _shortBreakDuration = tempShortBreakMinutes;
                  _longBreakDuration = tempLongBreakMinutes;
                  _longBreakInterval = tempLongBreakInterval;
                  _autoStartBreaks = tempAutoStartBreaks;
                  _autoStartPomodoros = tempAutoStartPomodoros;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        ),
      ),
    );
  }

  // Helper method to build time setting fields
  Widget _buildTimeSettingField(
    String label,
    int value,
    Function(int) onChanged, {
    bool isInterval = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
            Container(
              width: isSmallScreen ? 80 : 100,
              height: isSmallScreen ? 40 : 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, color: Colors.white70, size: isSmallScreen ? 16 : 20),
                    onPressed: () {
                      if ((isInterval && value > 1) || (!isInterval && value > 1)) {
                        onChanged(value - 1);
                      }
                    },
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.white70, size: isSmallScreen ? 16 : 20),
                    onPressed: () {
                      if ((isInterval && value < 10) || (!isInterval && value < 60)) {
                        onChanged(value + 1);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build switch settings
  Widget _buildSwitchSetting(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2196F3),
          activeTrackColor: const Color(0xFF2196F3).withOpacity(0.5),
          inactiveThumbColor: Colors.white70,
          inactiveTrackColor: Colors.white24,
        ),
      ],
    );
  }

  void _addTask() {
    _taskController.clear();
    int tempEstimatedPomodoros = 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                Navigator.pop(context);
                _taskController.clear();
              },
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Name',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taskController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              const Text(
                'Estimated Pomodoros',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            if (tempEstimatedPomodoros > 1) {
                              setState(() {
                                tempEstimatedPomodoros--;
                              });
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            tempEstimatedPomodoros.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              tempEstimatedPomodoros++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white70,
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                setState(() {
                  _tasks.add(Task(
                    title: _taskController.text,
                    estimatedPomodoros: tempEstimatedPomodoros,
                  ));
                  _taskController.clear();
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Add Task',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      if (_currentTask == _tasks[index]) {
        _currentTask = null;
      }
      _tasks.removeAt(index);
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _selectTask(Task task) {
    setState(() {
      _currentTask = task;
    });
  }

  void _editTask(int index) {
    final task = _tasks[index];
    _taskController.text = task.title;
    int tempEstimatedPomodoros = task.estimatedPomodoros;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Edit Task',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                Navigator.pop(context);
                _taskController.clear();
              },
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name Section
              const Text(
                'Task Name',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _taskController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 24),
              
              // Pomodoro Estimation Section
              const Text(
                'Estimated Pomodoros',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            if (tempEstimatedPomodoros > 1) {
                              setState(() {
                                tempEstimatedPomodoros--;
                              });
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            tempEstimatedPomodoros.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              tempEstimatedPomodoros++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.white70,
                  ),
                ],
              ),
              
              // Task Progress Section
              if (task.completedPomodoros > 0) ...[
                const SizedBox(height: 24),
                const Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed Pomodoros',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        task.completedPomodoros.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _taskController.clear();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                setState(() {
                  task.title = _taskController.text;
                  task.estimatedPomodoros = tempEstimatedPomodoros;
                });
                Navigator.pop(context);
                _taskController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  String _getFinishTime() {
    int totalMinutesLeft = 0;
    for (var task in _tasks) {
      if (!task.isCompleted) {
        totalMinutesLeft += (task.estimatedPomodoros - task.completedPomodoros) * _pomodoroDuration;
      }
    }
    
    if (totalMinutesLeft == 0) return "No tasks remaining";
    
    final now = DateTime.now();
    final finishTime = now.add(Duration(minutes: totalMinutesLeft));
    final hours = finishTime.hour.toString().padLeft(2, '0');
    final minutes = finishTime.minute.toString().padLeft(2, '0');
    
    return "$hours:$minutes (${(totalMinutesLeft / 60).toStringAsFixed(1)}h)";
  }

  int _getTotalPomodoros() {
    return _tasks.fold(0, (sum, task) => sum + task.estimatedPomodoros);
  }

  int _getCompletedPomodoros() {
    return _tasks.fold(0, (sum, task) => sum + task.completedPomodoros);
  }

  void _clearFinishedTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Clear Finished Tasks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all completed tasks?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks.removeWhere((task) => task.isCompleted);
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Clear',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  void _clearAllTasks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'Clear All Tasks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to remove all tasks? This action cannot be undone.',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _tasks.clear();
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  void _showReportDialog() {
    final int totalTasks = _tasks.length;
    final int completedTasks = _tasks.where((task) => task.isCompleted).length;
    final int totalPomodoros = _tasks.fold(0, (sum, task) => sum + task.estimatedPomodoros);
    final int completedPomodoros = _tasks.fold(0, (sum, task) => sum + task.completedPomodoros);
    final double completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    final double pomodoroProgress = totalPomodoros > 0 ? (completedPomodoros / totalPomodoros) * 100 : 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Task Progress Section
                _buildReportSection(
                  'Task Progress',
                  Icons.task_alt,
                  [
                    _buildStatRow('Total Tasks', totalTasks.toString()),
                    _buildStatRow('Completed Tasks', completedTasks.toString()),
                    _buildProgressBar('Completion Rate', completionRate),
                  ],
                ),
                const SizedBox(height: 24),

                // Pomodoro Progress Section
                _buildReportSection(
                  'Pomodoro Progress',
                  Icons.timer,
                  [
                    _buildStatRow('Total Pomodoros', totalPomodoros.toString()),
                    _buildStatRow('Completed Pomodoros', completedPomodoros.toString()),
                    _buildProgressBar('Progress', pomodoroProgress),
                  ],
                ),

                if (_tasks.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  // Task Details Section
                  _buildReportSection(
                    'Task Details',
                    Icons.list_alt,
                    _tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                            color: task.isCompleted ? Colors.green : Colors.white54,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          Text(
                            '${task.completedPomodoros}/${task.estimatedPomodoros}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Close',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  Widget _buildReportSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return Dismissible(
                key: Key(task.title),
                background: Container(
                  color: Colors.red.withOpacity(0.8),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                },
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 16,
                    vertical: isSmallScreen ? 4 : 8,
                  ),
                  leading: Container(
                    width: isSmallScreen ? 32 : 40,
                    height: isSmallScreen ? 32 : 40,
                    decoration: BoxDecoration(
                      color: task.isCompleted 
                          ? Colors.green.withOpacity(0.2) 
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: task.isCompleted ? Colors.green : Colors.white,
                        size: isSmallScreen ? 16 : 20,
                      ),
                      onPressed: () => _toggleTaskCompletion(index),
                    ),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  subtitle: Text(
                    'Pomodoros: ${task.completedPomodoros}/${task.estimatedPomodoros}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

enum TimerMode {
  pomodoro,
  shortBreak,
  longBreak,
}

class Task {
  String title;
  bool isCompleted;
  int estimatedPomodoros;
  int completedPomodoros;

  Task({
    required this.title,
    this.isCompleted = false,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2F3E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2D2F3E),
              Color(0xFF393B4B),
            ],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Logo and Title Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.timer_outlined,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Focus Time',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Boost your productivity with our\nmodern Pomodoro timer',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Features Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      icon: Icons.timer,
                      title: 'Smart Timer',
                      description: 'Customizable Pomodoro intervals',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      icon: Icons.task_alt,
                      title: 'Task Management',
                      description: 'Track your tasks and progress',
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureItem(
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      description: 'Monitor your productivity',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CountdownApp(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B6B94),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Developed by: Sourabh Chauhan',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 