import 'package:flutter/material.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:multilocationGroceryApp/model/counterModel.dart';
import 'package:multilocationGroceryApp/screens/categories/subcategories.dart';
import 'package:multilocationGroceryApp/screens/drawer/drawer.dart';
import 'package:multilocationGroceryApp/screens/product/product-details.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/product-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/dealsCard.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

SentryError sentryError = new SentryError();

class AllDealsList extends StatefulWidget {
  final Map localizedValues;
  final bool token;
  final List productsList;
  final String dealType, title, locale, currency;

  AllDealsList(
      {Key key,
      this.locale,
      this.localizedValues,
      this.productsList,
      this.currency,
      this.dealType,
      this.title,
      this.token});
  @override
  _AllDealsListState createState() => _AllDealsListState();
}

class _AllDealsListState extends State<AllDealsList> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List dealsList;
  String currency;
  bool getTokenValue = false, isAllDealsLoadingList = false;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  ScrollController controller;
  var cartData;
  @override
  void initState() {
    currency = widget.currency;
    getTokenValue = widget.token;
    if (widget.dealType == "TopDeals") {
      getAllTopDealsListMethod();
    } else {
      getAllTodayDealsListMethod();
    }
    super.initState();
  }

  getAllTopDealsListMethod() async {
    if (mounted) {
      setState(() {
        isAllDealsLoadingList = true;
      });
    }
    await ProductService.getTopDealsListAll().then((onValue) {
      try {
        _refreshController.refreshCompleted();
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              dealsList = onValue['response_data'];
              isAllDealsLoadingList = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              dealsList = [];
              isAllDealsLoadingList = false;
            });
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            dealsList = [];
            isAllDealsLoadingList = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          dealsList = [];
          isAllDealsLoadingList = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  getAllTodayDealsListMethod() async {
    if (mounted) {
      setState(() {
        isAllDealsLoadingList = true;
      });
    }
    await ProductService.getTodayDealsListAll().then((onValue) {
      try {
        _refreshController.refreshCompleted();
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              dealsList = onValue['response_data'];
              isAllDealsLoadingList = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              dealsList = [];
              isAllDealsLoadingList = false;
            });
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            dealsList = [];
            isAllDealsLoadingList = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          dealsList = [];
          isAllDealsLoadingList = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (getTokenValue) {
      CounterModel().getCartDataMethod().then((res) {
        if (mounted) {
          setState(() {
            cartData = res;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          cartData = null;
        });
      }
    }
    return Scaffold(
      key: _drawerKey,
      backgroundColor: bg,
      appBar: GFAppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          widget.title,
          style: textbarlowSemiBoldBlack(),
        ),
        centerTitle: true,
        leading: BackButton(),
      ),
      drawer: Drawer(
        child: DrawerPage(
          locale: widget.locale,
          localizedValues: widget.localizedValues,
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        controller: _refreshController,
        onRefresh: () {
          if (widget.dealType == "TopDeals") {
            getAllTopDealsListMethod();
          } else {
            getAllTodayDealsListMethod();
          }
        },
        child: isAllDealsLoadingList
            ? SquareLoader()
            : Container(
                margin:
                    EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 16),
                child: ListView(
                  children: <Widget>[
                    GridView.builder(
                      padding: EdgeInsets.only(bottom: 25),
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount:
                          dealsList.length == null ? 0 : dealsList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              MediaQuery.of(context).size.width / 720,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16),
                      itemBuilder: (BuildContext context, int i) {
                        return InkWell(
                          onTap: () {
                            if (dealsList[i]['delalType'] == 'Category') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubCategories(
                                      locale: widget.locale,
                                      localizedValues: widget.localizedValues,
                                      catId: dealsList[i]['category'],
                                      catTitle:
                                          '${dealsList[i]['name'][0].toUpperCase()}${dealsList[i]['name'].substring(1)}',
                                      token: getTokenValue),
                                ),
                              );
                            } else {
                              var result = Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetails(
                                    locale: widget.locale,
                                    localizedValues: widget.localizedValues,
                                    productID: dealsList[i]['product'],
                                  ),
                                ),
                              );
                              result.then((value) {
                                if (widget.dealType == "TopDeals") {
                                  getAllTopDealsListMethod();
                                } else {
                                  getAllTodayDealsListMethod();
                                }
                              });
                            }
                          },
                          child: DealsCard(
                            image: dealsList[i]['filePath'] ??
                                dealsList[i]['imageUrl'],
                            isPath:
                                dealsList[i]['filePath'] == null ? false : true,
                            title: dealsList[i]['name'],
                            price: dealsList[i]['delaPercent'].toString() +
                                "% " +
                                MyLocalizations.of(context).off,
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _drawerKey.currentState.openDrawer(),
        child: const Icon(Icons.menu, color: Colors.white,),
      ),
    );
  }
}
