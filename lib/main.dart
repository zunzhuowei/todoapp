import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database_provider.dart';
import 'todo.dart';
import 'add_or_edit_todo_page.dart'; // 更新：引入新文件名

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseProvider databaseProvider = DatabaseProvider();
  await databaseProvider.init();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DatabaseProvider>(create: (_) => databaseProvider),
        ],
        child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MyHomePage()
        ),
      )
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 新增：存储待办事项的数据
  List<MapEntry<String, Todo>> _todos = [];
  int _selectedIndex = 0;

  // 新增：加载数据的方法
  Future<void> _loadTodos() async {
    final databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    final todosMap = await databaseProvider.getAllEntity('todos', Todo.fromJson);
    setState(() {
      _todos = todosMap.entries.toList();
    });
  }

  // 新增：定义刷新方法
  void _refreshTodos() {
    _loadTodos(); // 调用加载数据方法刷新数据
  }

  @override
  void initState() {
    super.initState();
    _loadTodos(); // 初始化时加载数据
  }

  void onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddOrEditTodoPage(onRefresh: _refreshTodos),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                // 按照创建时间倒序排序
                _todos.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));
                // 分离已完成和未完成的任务
                final uncompletedTodos = _todos.where((element) => !element.value.completed).toList();
                final completedTodos = _todos.where((element) => element.value.completed).toList();
                // 合并任务列表
                final sortedTodos = [...uncompletedTodos, ...completedTodos];
                final todo = sortedTodos[index].value;

                return Stack(
                  children: [
                    InkWell(
                      onTap: () => onTap(index),
                      child: Container(
                        margin: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey),
                          borderRadius: BorderRadius.circular(8.0),
                          color: Colors.blueGrey[100],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueGrey[_selectedIndex == index ? 200 : 100]!,
                              Colors.blueGrey[_selectedIndex == index ? 200 : 50]!,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ListTile(
                          /// 标题
                          title: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Checkbox(
                                value: todo.completed,
                                activeColor: Colors.green,
                                shape: const CircleBorder(),
                                onChanged: (value) async {
                                  await databaseProvider.put('todos', todo.id, todo..completed = value!);
                                  _refreshTodos(); // 刷新数据
                                },
                              ),
                              Expanded(
                                child: SelectableText(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: todo.completed ? TextDecoration.lineThrough : null,
                                    color: todo.completed ? Colors.grey : Colors.black,
                                    decorationThickness: 2.0,
                                    decorationColor: Colors.blueGrey,
                                  ),
                                  onTap: () => onTap(index),
                                ),
                              ),
                            ],
                          ),
                          /// 描述
                          subtitle: todo.completed || todo.descr.isEmpty ? null : SelectableText(
                            todo.descr,
                            maxLines: 3,
                            onTap: () => onTap(index),
                          ),
                        ),
                      ),
                    ),
                    /// 操作按钮
                    if(_selectedIndex == index)
                      _buildOprations(todo),
                    Positioned(
                      top: 8.0,
                      right: 10.0,
                      child: Text( // 新增：显示创建时间
                        '创建于 ${todo.createdAt.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey[50],
    );
  }

  /// 构建操作按钮
  Widget _buildOprations(Todo todo) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);
    return Positioned(
      bottom: 8.0,
      right: 8.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddOrEditTodoPage(
                        selectedTodoKey: todo.id,
                        onRefresh: _refreshTodos,
                      ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red,),
            onPressed: () async {
              await databaseProvider.delete('todos', todo.id);
              _refreshTodos(); // 刷新数据
            },
          ),
        ],
      ),
    );
  }

}
