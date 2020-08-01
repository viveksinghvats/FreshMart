import 'package:flutter/material.dart';
import 'package:multilocationGroceryApp/screens/authe/login.dart';
import 'package:multilocationGroceryApp/screens/categories/allcategories.dart';
import 'package:multilocationGroceryApp/screens/drawer/aboutus.dart';
import 'package:multilocationGroceryApp/screens/drawer/newChatPage.dart';
import 'package:multilocationGroceryApp/screens/home/home.dart';
import 'package:multilocationGroceryApp/screens/orders/orders.dart';
import 'package:multilocationGroceryApp/screens/product/all_products.dart';
import 'package:multilocationGroceryApp/service/auth-service.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/service/constants.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import '../../main.dart';
import '../../style/style.dart';
import 'package:getflutter/getflutter.dart';

SentryError sentryError = new SentryError();

class DrawerPage extends StatefulWidget {
  DrawerPage({Key key, this.locale, this.localizedValues}) : super(key: key);

  final Map localizedValues;
  final String locale;
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  bool getTokenValue = true, isLogoGetLoading = false;
  String currency = "", logo;
  List languages, languagesCodes;

  @override
  void initState() {
    getLogo();
    getToken();
    super.initState();
  }

  getToken() async {
    await Common.getAllLanguageNames().then((value) {
      languages = value;
    });
    await Common.getAllLanguageCodes().then((value) {
      languagesCodes = value;
    });
    await Common.getCurrency().then((value) {
      currency = value;
    });
    await Common.getToken().then((onValue) {
      if (onValue != null) {
        if (mounted) {
          setState(() {
            getTokenValue = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            getTokenValue = false;
          });
        }
      }
    });
  }

  getLogo() {
    if (mounted) {
      setState(() {
        isLogoGetLoading = true;
      });
    }
    LoginService.aboutUs().then((onValue) {
      try {
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              isLogoGetLoading = false;
              if (onValue['response_data'][0]['userApp']['filePath'] == null) {
                logo = onValue['response_data'][0]['userApp']['imageUrl'];
              } else {
                logo = Constants.IMAGE_URL_PATH +
                    "tr:dpr-auto,tr:w-500" +
                    onValue['response_data'][0]['userApp']['filePath'];
              }
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

  selectLanguagesMethod() async {
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              height: 180,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.all(
                  new Radius.circular(24.0),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ListView(
                children: <Widget>[
                  ListView.builder(
                      padding: EdgeInsets.only(bottom: 25),
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          languages.length == null ? 0 : languages.length,
                      itemBuilder: (BuildContext context, int i) {
                        return GFButton(
                          onPressed: () async {
                            await Common.setSelectedLanguage(languagesCodes[i]);
                            main();
                          },
                          type: GFButtonType.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                languages[i],
                                style: hintSfboldBig(),
                              ),
                              Container()
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Drawer(
      child: Stack(
        children: <Widget>[
          Container(
            color: Color(0xFF000000),
            child: ListView(
              children: <Widget>[
                SizedBox(height: 40),
                Container(
                  margin: EdgeInsets.all(10),
                  child: Center(
                    child: Image.asset(
                      'lib/assets/logo/logo.png', color: Colors.white,
                    ),
                  ),
                ),
//                isLogoGetLoading
//                    ? Container(height: 100)
//                    : logo == null
//                        ? Row(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//                              Text(
//                                Constants.APP_NAME.split(' ').join('\n'),
//                                textAlign: TextAlign.center,
//                                overflow: TextOverflow.ellipsis,
//                                style: textbarlowBoldWhitebig(),
//                              ),
//                            ],
//                          )
//                        : Container(
//                            margin: EdgeInsets.all(10),
//                            child: Center(
//                              child: Image.network(
//                                logo,
//                                height: 80,
//                              ),
//                            ),
//                          ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: _buildMenuTileList('lib/assets/icons/Home.png',
                      MyLocalizations.of(context).home, 0,
                      route: Home(
                        locale: widget.locale,
                        localizedValues: widget.localizedValues,
                        currentIndex: 0,
                      )),
                ),
                _buildMenuTileList('lib/assets/icons/products.png',
                    MyLocalizations.of(context).allProducts, 0,
                    route: AllProducts(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
                      currency: currency,
                    )),
                _buildMenuTileList('lib/assets/icons/categories.png',
                    MyLocalizations.of(context).allCategories, 0,
                    route: AllCategories(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
//                      currency: currency,
                    getTokenValue: getTokenValue,
                    )),
                getTokenValue
                    ? _buildMenuTileList('lib/assets/icons/fav.png',
                        MyLocalizations.of(context).savedItems, 0,
                        route: Home(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                          currentIndex: 1,
                        ))
                    : Container(),
                getTokenValue
                    ? _buildMenuTileList(
                        'lib/assets/images/profileIcon.png',
                        '${MyLocalizations.of(context).profile} & ${MyLocalizations.of(context).address}',
                        0,
                        route: Home(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                          currentIndex: 3,
                        ))
                    : Container(),
                getTokenValue
                    ? _buildMenuTileList(
                        'lib/assets/icons/history.png',
                        MyLocalizations.of(context).orderHistory,
                        0,
                        route: Orders(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                        ),
                      )
                    : Container(),
//                getTokenValue
//                    ? _buildMenuTileList('lib/assets/icons/location.png',
//                        MyLocalizations.of(context).address, 0,
//                        route: Address(
//                          locale: widget.locale,
//                          localizedValues: widget.localizedValues,
//                        ))
//                    : Container(),

                getTokenValue
                    ? _buildMenuTileList('lib/assets/icons/chat.png',
                        MyLocalizations.of(context).chat, 0,
                        route: NewChatAndHistoryPage(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                        ))
                    : Container(),
                _buildMenuTileList('lib/assets/icons/about.png',
                    MyLocalizations.of(context).aboutUs, 0,
                    route: AboutUs(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
                    )),
                getTokenValue
                    ? Container(
                        margin: EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            selectLanguagesMethod();
                          },
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: ListTile(
                                    leading: Image.asset(
                                      'lib/assets/icons/language.png',
                                      width: 35,
                                      height: 35,
                                      color: Colors.white,
                                    ),
                                    selected: true,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    MyLocalizations.of(context).selectLanguage,
                                    style: textBarlowregwhitelg(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 20.0),
                getTokenValue
                    ? _buildMenuTileList1('lib/assets/icons/lg.png',
                        MyLocalizations.of(context).logout, 0, route: null)
                    : _buildMenuTileList1('lib/assets/icons/lg.png',
                        MyLocalizations.of(context).login, 0,
                        route: Login(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                        )),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  logout() async {
    await Common.setSelectedLanguage(null);
    await Common.setToken(null);
    await Common.setUserID(null);
    main();
  }

  Widget _buildMenuTileList(String icon, String name, int count,
      {Widget route, bool check}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (route != null) {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => route));
          }
        },
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ListTile(
                  leading: Image.asset(
                    icon,
                    width: 35,
                    height: 35,
                    color: Colors.white,
                  ),
                  selected: true,
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  name,
                  style: textBarlowregwhitelg(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTileList1(String icon, String name, int count,
      {Widget route, bool check}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          if (route != null) {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => route));
          } else {
            logout();
          }
        },
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: ListTile(
                leading: Image.asset(icon,
                    width: 35,
                    height: 35,
                    color: !getTokenValue ? Colors.green : Color(0xFFF44242)),
              ),
            ),
            Expanded(
              flex: 5,
              child: Text(
                name,
                style: !getTokenValue
                    ? textBarlowregredGreen()
                    : textBarlowregredlg(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
