import 'package:flutter/material.dart';
import 'package:no_to_do_app/model/noto_item.dart';
import 'package:no_to_do_app/util/database_client.dart';
import 'package:no_to_do_app/util/date_formatter.dart';

class NotoDoScreen extends StatefulWidget {
  @override
  _NotoDoScreenState createState() => _NotoDoScreenState();
}

class _NotoDoScreenState extends State<NotoDoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var db = DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmit(String text) async {
    _textEditingController.clear();
    NoDoItem noDoItem = NoDoItem(text, dateFormated());
    int savedItemId = await db.saveItem(noDoItem);

    NoDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });

    print("Item saved id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      floatingActionButton: FloatingActionButton(
        tooltip: "Add item",
        backgroundColor: Colors.redAccent,
        child: ListTile(
          title: Icon(Icons.add),
        ),
        onPressed: _showFormDialog,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              reverse: false,
              itemCount: _itemList.length,
              itemBuilder: (_, int index) {
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: _itemList[index],
                    onLongPress: () => _updateItem(_itemList[index], index),
                    trailing: Listener(
                      key: Key(_itemList[index].itemName),
                      child: Icon(
                        Icons.remove_circle,
                        color: Colors.redAccent,
                      ),
                      onPointerDown: (pointEvent) =>
                          _deleteNoDo(_itemList[index].id, index),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg: Don\'t buy stuff",
                icon: Icon(Icons.note_add),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmit(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      NoDoItem noDoItem = NoDoItem.fromMap(item);
      setState(() {
        _itemList.add(NoDoItem.map(item));
      });
      print("Db items : ${noDoItem.itemName}");
    });
  }

  _deleteNoDo(int id, int index) async {
    debugPrint("deleted item");
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }

  _updateItem(NoDoItem item, int index) {
    var alert = AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "eg Don\'t buy stuff",
                  icon: Icon(Icons.update)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () async {
            NoDoItem newItemUpdated = NoDoItem.fromMap({
              "itemName": _textEditingController.text,
              "dateCreated": dateFormated(),
              "id": item.id
            });
            _handleSubmitUpdate(index, item);
            await db.updateItem(newItemUpdated);
            setState(() {
              _readNoDoList(); 
            });
            Navigator.pop(context);
          },
          child: Text("Update"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  void _handleSubmitUpdate(int index, NoDoItem item) {

    setState(() {
      _itemList.removeWhere((element) => _itemList[index].itemName == item.itemName);    });
  }
}
