import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multilocationGroceryApp/screens/chat/chatHistory.dart';
import 'package:multilocationGroceryApp/screens/chat/chatListPage.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';

import 'drawer.dart';

SentryError sentryError = new SentryError();

class NewChatAndHistoryPage extends StatefulWidget {
  final Map localizedValues;
  final String locale;
  NewChatAndHistoryPage({Key key, this.locale, this.localizedValues});

  @override
  _NewChatAndHistoryPageState createState() => _NewChatAndHistoryPageState();
}

class _NewChatAndHistoryPageState extends State<NewChatAndHistoryPage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _drawerKey,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat, color: Colors.black)),
              Tab(icon: Icon(Icons.history, color: Colors.black)),
            ],
          ),
          backgroundColor: primary,
          centerTitle: true,
          title: Text(
            MyLocalizations.of(context).chat,
            style: textbarlowSemiBoldBlack(),
          ),
          leading: BackButton(),
        ),
        drawer: Drawer(
          child: DrawerPage(
            locale: widget.locale,
            localizedValues: widget.localizedValues,
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ChatListPage(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
            ChatHistoryListPage(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _drawerKey.currentState.openDrawer(),
          child: const Icon(Icons.menu, color: Colors.white,),
        ),
      ),
    );
  }
}
