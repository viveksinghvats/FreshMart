import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getflutter/getflutter.dart';
import 'package:multilocationGroceryApp/screens/drawer/drawer.dart';
import 'package:multilocationGroceryApp/screens/home/locationPage.dart';
import 'package:multilocationGroceryApp/screens/tab/mycart.dart';
import 'package:multilocationGroceryApp/screens/tab/profile.dart';
import 'package:multilocationGroceryApp/screens/tab/saveditems.dart';
import 'package:multilocationGroceryApp/screens/tab/searchitem.dart';
import 'package:multilocationGroceryApp/screens/tab/store.dart';
import 'package:multilocationGroceryApp/service/auth-service.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/product-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';

SentryError sentryError = new SentryError();

class Home extends StatefulWidget {
  final int currentIndex;
  final Map localizedValues;
  final String locale;
  Home({
    Key key,
    this.currentIndex,
    this.locale,
    this.localizedValues,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  TabController tabController;
  bool currencyLoading = false,
      isCurrentLoactionLoading = false,
      getTokenValue = false;
  int currentIndex = 0;
  List searchProductList;
  String currency = "";
  var locationData;
  void initState() {
    if (widget.currentIndex != null) {
      if (mounted) {
        setState(() {
          currentIndex = widget.currentIndex;
        });
      }
    }
    getToken();
    getResult();
    getGlobalSettingsData();
    tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  getGlobalSettingsData() async {
    if (mounted) {
      setState(() {
        currencyLoading = true;
      });
    }
    LoginService.getGlobalSettings().then((onValue) async {
      try {
        if (mounted) {
          setState(() {
            currencyLoading = false;
          });
        }
        if (onValue['response_code'] == 200) {
          if (onValue['response_data']['currencyCode'] == null) {
            await Common.setCurrency('\$');
            await Common.getCurrency().then((value) {
              currency = value;
            });
          } else {
            currency = onValue['response_data']['currencyCode'];
            await Common.setCurrency(currency);
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            currencyLoading = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          currencyLoading = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  getToken() async {
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
    }).catchError((error) {
      if (mounted) {
        setState(() {
          getTokenValue = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  getProductListMethod() async {
    await ProductService.getProductListAll(1).then((onValue) {
      try {
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              searchProductList = onValue['response_data']['products'];
            });
          }
        } else {
          if (mounted) {
            setState(() {
              searchProductList = [];
            });
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            searchProductList = [];
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          searchProductList = [];
        });
      }
      sentryError.reportError(error, null);
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  deliveryAddress() {
    return InkWell(
      onTap: () async {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => Locations(
              locale: widget.locale,
              localizedValues: widget.localizedValues,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  MyLocalizations.of(context).location,
                  style: textBarlowRegularrBlacksm(),
                ),
                Text(
                  locationData == null
                      ? ""
                      : locationData['locationName'] ?? "",
                  overflow: TextOverflow.ellipsis,
                  style: textAddressLocation(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  getResult() async {
    await Common.getLocation().then((locationDataValue) async {
      locationData = locationDataValue;
    });
  }

  _onTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      Store(
        locale: widget.locale,
        localizedValues: widget.localizedValues,
      ),
      SavedItems(
        locale: widget.locale,
        localizedValues: widget.localizedValues,
      ),
      MyCart(
        locale: widget.locale,
        localizedValues: widget.localizedValues,
      ),
      Profile(
        locale: widget.locale,
        localizedValues: widget.localizedValues,
      ),
    ];
    return Scaffold(
      key: _drawerKey,
      backgroundColor: Colors.white,
      appBar: currentIndex == 0
          ? GFAppBar(
              backgroundColor: bg,
              elevation: 0,
              title: deliveryAddress(),
              iconTheme: IconThemeData(color: Colors.black),
              actions: <Widget>[
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchItem(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                          productsList: searchProductList,
                          currency: currency,
                          token: getTokenValue,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 15, left: 15),
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                ),
              ],
            )
          : null,
      drawer: Drawer(
        child: DrawerPage(
          locale: widget.locale,
          localizedValues: widget.localizedValues,
        ),
      ),
      body: currencyLoading ? SquareLoader() : _screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.black,
        unselectedItemColor: greyc,
        type: BottomNavigationBarType.fixed,
        fixedColor: primary,
        onTap: _onTapped,
        items: [
          BottomNavigationBarItem(
            title: Text(MyLocalizations.of(context).store),
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                IconData(
                  0xe90f,
                  fontFamily: 'icomoon',
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(MyLocalizations.of(context).savedItems),
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                IconData(
                  0xe90d,
                  fontFamily: 'icomoon',
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(MyLocalizations.of(context).myCart),
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                IconData(
                  0xe911,
                  fontFamily: 'icomoon',
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            title: Text(MyLocalizations.of(context).profile),
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Icon(
                IconData(
                  0xe912,
                  fontFamily: 'icomoon',
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _drawerKey.currentState.openDrawer(),
        child: const Icon(
          Icons.menu,
          color: Colors.white,
        ),
      ),
    );
  }
}
