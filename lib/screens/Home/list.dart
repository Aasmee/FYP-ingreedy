import 'package:flutter/material.dart';
import 'package:ingreedy_app/widgets/addpop.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key, this.title});

  final String? title;

  @override
  ListPageState createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  // Controllers for the popup
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitController = TextEditingController();

  void _showPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopupBox(
          onClose: () => Navigator.of(context).pop(),
          nameController: nameController,
          quantityController: quantityController,
          unitController: unitController,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set scaffold background to white
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shopping List',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          InkWell(
            onTap: _showPopup,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 0.5),
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add to list',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    super.dispose();
  }
}
