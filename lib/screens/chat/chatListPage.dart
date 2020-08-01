import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multilocationGroceryApp/screens/chat/chatpage.dart';
import 'package:multilocationGroceryApp/service/auth-service.dart';
import 'package:multilocationGroceryApp/service/constants.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

SentryError sentryError = new SentryError();

class ChatListPage extends StatefulWidget {
  final Map localizedValues;
  final String locale;
  ChatListPage({Key key, this.locale, this.localizedValues});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage>
    with TickerProviderStateMixin {
  List locationList = List();
  bool isListLoading = false;
  String id;
  Map userData;
  var socket = io.io(Constants.socketUrl, <String, dynamic>{
    'transports': ['websocket']
  });
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    if (mounted) {
      setState(() {
        isListLoading = true;
      });
    }
    await LoginService.getUserInfo().then((onValue) {
      try {
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              id = onValue['response_data']['userInfo']['_id'];
              userData = onValue['response_data']['userInfo'];
              socketInt();
            });
          }
        }
      } catch (error, stackTrace) {
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      sentryError.reportError(error, null);
    });
  }

  socketInt() {
    socket.on('connect', (data) {
      print("connected.....");
    });
    socket.emit('user-chat-list', {"id": id});

    socket.on('disconnect', (_) {
      print('disconnect');
    });

    socket.on('chat-list-user$id', (data) {
      if (data.length > 0) {
        if (mounted) {
          setState(() {
            if (mounted) {
              setState(() {
                locationList = data;
                isListLoading = false;
              });
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            if (mounted) {
              setState(() {
                locationList = [];
                isListLoading = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: isListLoading
          ? SquareLoader()
          : locationList.length == 0
              ? Center(
                  child: Image.asset('lib/assets/images/no-orders.png'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    new Expanded(
                      child: new ListView.builder(
                        itemCount: locationList.length,
                        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  var result = Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => Chat(
                                        locale: widget.locale,
                                        localizedValues: widget.localizedValues,
                                        locationId: locationList[index],
                                        userDetail: userData,
                                      ),
                                    ),
                                  );
                                  result.then((value) {
                                    getUserData();
                                  });
                                },
                                child: new Container(
                                  color: Colors.transparent,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: new Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Container(
                                        margin:
                                            const EdgeInsets.only(right: 18.0),
                                        child: new CircleAvatar(
                                          child: new Text(
                                              '${locationList[index]['locationName'][0]}'),
                                          backgroundColor: primary,
                                        ),
                                      ),
                                      new Expanded(
                                        child: new Container(
                                          margin:
                                              const EdgeInsets.only(top: 6.0),
                                          child: new Text(
                                            locationList[index]['locationName'],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider()
                            ],
                          );
                        },
                      ),
                    )
                  ],
                ),
    );
  }
}
