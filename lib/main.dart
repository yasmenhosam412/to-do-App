import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final TextEditingController _txtController = TextEditingController();
  final TextEditingController _dController = TextEditingController();
  final TextEditingController _DesController = TextEditingController();
  final List<Map<String, String>> _items = [];
  String category = 'Other Task';
  String statusFilter = 'All Tasks';
  int? _editIndex;
  bool ShowListViewOnly = false;

  @override
  void initState() {
    super.initState();
    _loadSavedShared();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
              title: const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber, Colors.cyan, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    ShowListViewOnly = !ShowListViewOnly;
                    _loadSavedShared();
                  });
                },
                icon: Image.asset(
                  'assets/onee.gif',
                  width: 24,
                  height: 24,
                ),
              )),
          body: ShowListViewOnly
              ? ListView.builder(
                  itemCount: _items
                      .where((item) =>
                          statusFilter == 'All Tasks' ||
                          item['status'] == statusFilter)
                      .length,
                  itemBuilder: (context, index) {
                    final filteredItems = _items
                        .where((item) =>
                            statusFilter == 'All Tasks' ||
                            item['status'] == statusFilter)
                        .toList();
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            leading: Checkbox(
                              value: filteredItems[index]['checked'] == 'true',
                              onChanged: (bool? value) {
                                setState(() {
                                  filteredItems[index]['checked'] =
                                      value.toString();
                                  filteredItems[index]['status'] = value!
                                      ? 'completed Tasks'
                                      : 'incompleted Tasks';
                                  _savetoSharedPref();
                                });
                              },
                            ),
                            title: Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _editIndex = filteredItems
                                          .indexOf(filteredItems[index]);
                                      _txtController.text =
                                          filteredItems[index]['title']!;
                                      _dController.text =
                                          filteredItems[index]['subtitle']!;
                                      _DesController.text =
                                          filteredItems[index]['desc']!;
                                      ShowListViewOnly = false;
                                    });
                                  },
                                  icon: Image.asset(
                                    'assets/pin.gif',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Task : ${filteredItems[index]['title']}' ??
                                        'No Task',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              children: [
                                Text(
                                    ' Description : ${filteredItems[index]['desc']}',
                                    style: TextStyle(color: Colors.indigo)),
                                Text(
                                    'Duration : ${filteredItems[index]['subtitle']}',
                                    style: TextStyle(color: Colors.red)),
                                Text(
                                    'Category : ${filteredItems[index]['category']}',
                                    style: TextStyle(color: Colors.green)),
                                Text(
                                    'Status : ${filteredItems[index]['status']}',
                                    style: TextStyle(color: Colors.teal)),
                                Text('Date : ${filteredItems[index]['date']}',
                                    style: TextStyle(color: Colors.purple)),
                              ],
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text(
                                          'Are you sure you want to delete this task?'),
                                      content: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _items.remove(
                                                    filteredItems[index]);
                                                _savetoSharedPref();
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Yes'),
                                          ),
                                          SizedBox(width: 5),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('No'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                              child: Image.asset(
                                'assets/tra.gif',
                                width: 24.0,
                                height: 24.0,
                              ),
                            ),
                          ),
                        ));
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          height: 75,
                          child: TextField(
                            maxLines: 3,
                            minLines: 1,
                            controller: _txtController,
                            decoration: InputDecoration(
                              labelText: 'Task Title',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'Enter task title here',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                            ),
                          )),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: TextField(
                            maxLines: 5,
                            minLines: 1,
                            controller: _DesController,
                            decoration: InputDecoration(
                              labelText: 'Task Description',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'Enter task description here',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                            ),
                          )),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          height: 75,
                          child: TextField(
                            maxLines: 2,
                            minLines: 1,
                            controller: _dController,
                            decoration: InputDecoration(
                              labelText: 'Task Duartion',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              hintText: 'Enter task duration here',
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20.0),
                            ),
                          )),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: Row(
                        children: [
                          TextButton.icon(
                              icon: Icon(Icons.category, color: Colors.black),
                              label: Text(':'),
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg: 'Please Choose Category Of Your Task',
                                    backgroundColor: Colors.black);
                              }),
                          SizedBox(width: 5),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  category = 'Home Task';
                                  Fluttertoast.showToast(
                                      msg: 'Home Category',
                                      backgroundColor: Colors.black);

                                  _savetoSharedPref();
                                });
                              },
                              icon: Image.asset(
                                'assets/home.gif',
                                width: 24,
                                height: 24,
                              )),
                          SizedBox(width: 5),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  category = 'Work Task';

                                  _savetoSharedPref();
                                  Fluttertoast.showToast(
                                      msg: 'Work Category',
                                      backgroundColor: Colors.black);
                                });
                              },
                              icon: Image.asset(
                                'assets/two.gif',
                                height: 24,
                                width: 24,
                              )),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                category = 'Health Task';
                                Fluttertoast.showToast(
                                    msg: 'Health Category',
                                    backgroundColor: Colors.black);

                                _savetoSharedPref();
                              });
                            },
                            icon: Image.asset(
                              'assets/heart.gif',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          SizedBox(width: 5),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  category = 'Personal Task';

                                  _savetoSharedPref();
                                  Fluttertoast.showToast(
                                      msg: 'Personal Category',
                                      backgroundColor: Colors.black);
                                });
                              },
                              icon: Image.asset('assets/person.gif',
                                  height: 24, width: 24)),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (_txtController.text.isNotEmpty) {
                              if (_editIndex != null) {
                                _items[_editIndex!] = {
                                  'title': _txtController.text,
                                  'subtitle': _dController.text,
                                  'checked': 'false',
                                  'category': category,
                                  'status': 'incompleted Tasks',
                                  'date': DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                  'desc': _DesController.text,
                                };
                                _editIndex = null;
                              } else {
                                _items.add({
                                  'title': _txtController.text,
                                  'subtitle': _dController.text,
                                  'checked': 'false',
                                  'category': category,
                                  'status': 'incompleted Tasks',
                                  'date': DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                  'desc': _DesController.text,
                                });
                              }
                              _savetoSharedPref();
                              _txtController.clear();
                              _dController.clear();
                              _DesController.clear();
                              ShowListViewOnly = true;
                            }
                          });
                        },
                        child: Text(_editIndex == null ? 'Add' : 'Update'),
                      ),
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                statusFilter = 'All Tasks';
                                ShowListViewOnly = true;

                                Fluttertoast.showToast(
                                    msg: 'The All Tasks',
                                    backgroundColor: Colors.black);
                              });
                            },
                            child: Text('All Tasks'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                statusFilter = 'completed Tasks';
                                ShowListViewOnly = true;
                                Fluttertoast.showToast(
                                    msg: 'completed Tasks',
                                    backgroundColor: Colors.black);
                              });
                            },
                            child: Text('Completed'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                statusFilter = 'incompleted Tasks';
                                ShowListViewOnly = true;
                                Fluttertoast.showToast(
                                    msg: 'incomplete Tasks',
                                    backgroundColor: Colors.black);
                              });
                            },
                            child: Text('Incomplete'),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
        ));
  }

  Future<void> _savetoSharedPref() async {
    final SharedPreferences shared = await SharedPreferences.getInstance();
    List<String> itemList = _items
        .map((item) =>
            '${item['title']},${item['subtitle']},${item['checked']},${item['category']},${item['status']},${item['date']},${item['desc']}')
        .toList();
    await shared.setStringList('items', itemList);
  }

  Future<void> _loadSavedShared() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    List<String>? itemList = sharedPreferences.getStringList('items');
    if (itemList != null && itemList.isNotEmpty) {
      setState(() {
        _items.clear();
        for (String item in itemList) {
          List<String> itemDetails = item.split(',');
          _items.add({
            'title': itemDetails[0],
            'subtitle': itemDetails[1],
            'checked': itemDetails[2],
            'category': itemDetails[3],
            'status': itemDetails[4],
            'date': itemDetails[5],
            'desc': itemDetails[6],
          });
        }
      });
    }
  }
}
