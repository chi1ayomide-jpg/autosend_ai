import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/native_channel.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ScheduledTask> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await StorageService.loadTasks();
    setState(() {
      _allTasks = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload, color: GlassTheme.primaryNeon),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("CSV Import: Selected sample_contacts.csv")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: GlassTheme.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: GlassTheme.primaryNeon,
          labelColor: GlassTheme.primaryNeon,
          unselectedLabelColor: GlassTheme.textSecondary,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Completed"),
            Tab(text: "Failed"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Pro Usage Banner
          GlassContainer(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            color: GlassTheme.accentBlue.withOpacity(0.15),
            borderColor: GlassTheme.accentBlue.withOpacity(0.4),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Free Tier Usage",
                        style: TextStyle(
                          color: GlassTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Total Usage: 1/10 tasks scheduled",
                        style: TextStyle(color: GlassTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassTheme.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Go Pro", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(TaskStatus.pending),
                _buildTaskList(TaskStatus.completed),
                _buildTaskList(TaskStatus.failed),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GlassTheme.primaryNeon,
        foregroundColor: Colors.black,
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(TaskStatus status) {
    final filtered = _allTasks.where((t) => t.status == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          "No ${status.name} tasks found",
          style: const TextStyle(color: GlassTheme.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final task = filtered[index];
        final timeStr = DateFormat('MMM dd, HH:mm').format(task.scheduledTime);

        return GlassContainer(
          margin: const EdgeInsets.only(bottom: 12),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GlassTheme.primaryEmerald.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat, color: GlassTheme.primaryNeon, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GlassTheme.glassFillLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GlassTheme.glassBorder),
                    ),
                    child: Text(
                      timeStr,
                      style: const TextStyle(
                        color: GlassTheme.primaryNeon,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GlassTheme.primaryEmerald.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.sync, color: GlassTheme.primaryNeon, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          task.recurrence.name.toUpperCase(),
                          style: const TextStyle(
                            color: GlassTheme.primaryNeon,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "• ${task.recipientName}",
                style: const TextStyle(
                  color: GlassTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "• ${task.message}",
                style: const TextStyle(color: GlassTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: GlassTheme.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Schedule New Task",
                style: TextStyle(
                  color: GlassTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Recipient Name / Group",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number (with Country Code e.g. +234...)",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Message Content",
                  labelStyle: const TextStyle(color: GlassTheme.textSecondary),
                  filled: true,
                  fillColor: GlassTheme.glassFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || messageController.text.isEmpty) return;

                    final newTask = ScheduledTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      recipientName: nameController.text,
                      recipientPhone: phoneController.text.isNotEmpty ? phoneController.text : "+2348000000000",
                      message: messageController.text,
                      scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
                      status: TaskStatus.pending,
                    );

                    _allTasks.add(newTask);
                    await StorageService.saveTasks(_allTasks);

                    // Register exact alarm in Android native system
                    await NativeChannel.scheduleTask(
                      taskId: newTask.id,
                      scheduledTime: newTask.scheduledTime,
                      phone: newTask.recipientPhone,
                      message: newTask.message,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    _loadTasks();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GlassTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save & Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
