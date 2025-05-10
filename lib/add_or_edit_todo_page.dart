import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_provider.dart';
import 'todo.dart';

class AddOrEditTodoPage extends StatefulWidget {
  final String? selectedTodoKey;
  final VoidCallback? onRefresh; // 新增：回调函数用于刷新主页面

  const AddOrEditTodoPage({super.key, this.selectedTodoKey, this.onRefresh});

  @override
  State<AddOrEditTodoPage> createState() => _AddOrEditTodoPageState();
}

class _AddOrEditTodoPageState extends State<AddOrEditTodoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedTodoKey != null) {
      // 编辑模式：初始化表单数据
      _loadTodoDetails();
    }
  }

  Future<void> _loadTodoDetails() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final todo = await databaseProvider.getEntity('todos', widget.selectedTodoKey!, Todo.fromJson);
    if (todo != null) {
      _titleController.text = todo.title;
      _descrController.text = todo.descr;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descrController.dispose();
    super.dispose();
  }

  Future<void> _submitForm(DatabaseProvider databaseProvider) async {
    if (_titleController.text.isNotEmpty && _descrController.text.isNotEmpty) {
      final todo = Todo(
        id: widget.selectedTodoKey ?? DateTime.now().toString(),
        title: _titleController.text,
        descr: _descrController.text,
      );
      await databaseProvider.put('todos', todo.id, todo);
      Navigator.pop(context); // 返回主页面
      widget.onRefresh?.call(); // 调用回调函数刷新主页面
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedTodoKey != null ? '编辑待办' : '添加待办'), // 根据模式动态设置标题
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '标题',
                helperText: '请输入待办事项的标题'
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descrController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '描述',
                  helperText: '请输入待办事项的描述'
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
            ),
            ElevatedButton(
              onPressed: () async {
                await _submitForm(databaseProvider);
              },
              child: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }
}