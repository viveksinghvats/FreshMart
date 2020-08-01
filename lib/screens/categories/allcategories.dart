import 'package:flutter/material.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:getflutter/getflutter.dart';
import 'package:multilocationGroceryApp/screens/categories/subcategories.dart';
import 'package:multilocationGroceryApp/screens/drawer/drawer.dart';
import 'package:multilocationGroceryApp/screens/tab/searchCategory.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/service/constants.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';

import 'package:multilocationGroceryApp/service/product-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

SentryError sentryError = new SentryError();

class AllCategories extends StatefulWidget {
  final Map localizedValues;
  final String locale;
  final bool getTokenValue;
  AllCategories(
      {Key key, this.locale, this.localizedValues, this.getTokenValue});

  @override
  _AllCategoriesState createState() => _AllCategoriesState();
}

class _AllCategoriesState extends State<AllCategories>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  TabController tabController;
  bool isLoadingProductsList = false, isLoadingcategoryList = false;
  List categoryList, productsList;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String currency;
  bool getTokenValue = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    getCategoryList();
    getTokenValueMethod();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  getTokenValueMethod() async {
    await Common.getCurrency().then((value) {
      currency = value;
    });
    await Common.getToken().then((onValue) {
      try {
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
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            getTokenValue = false;
          });
        }
        sentryError.reportError(error, stackTrace);
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

  getCategoryList() async {
    if (mounted) {
      setState(() {
        isLoadingcategoryList = true;
      });
    }
    await ProductService.getCategoryList().then((onValue) {
      try {
        _refreshController.refreshCompleted();
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              categoryList = onValue['response_data'];
              isLoadingcategoryList = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              categoryList = [];
              isLoadingcategoryList = false;
            });
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            categoryList = [];
            isLoadingcategoryList = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          categoryList = [];
          isLoadingcategoryList = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      appBar: GFAppBar(
        title: Text(MyLocalizations.of(context).allCategories,
            style: textbarlowSemiBoldBlack()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black, size: 15.0),
        leading: BackButton(),
        actions: [
          InkWell(
            onTap: () {
              var result = Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchCategory(
                      locale: widget.locale,
                      localizedValues: widget.localizedValues,
                      productsList: productsList,
                      currency: currency,
                      token: getTokenValue),
                ),
              );
              result.then((value) {
                if (mounted) {
                  setState(() {
                    isLoadingProductsList = true;
                  });
                }
                getTokenValueMethod();
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15, left: 15),
              child: Icon(
                Icons.search,
                size: 24,
              ),
            ),
          ),
        ],
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
          getCategoryList();
        },
        child: isLoadingcategoryList
            ? SquareLoader()
            : Container(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount:
                      categoryList.length == null ? 0 : categoryList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width / 420,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SubCategories(
                                locale: widget.locale,
                                localizedValues: widget.localizedValues,
                                catId: categoryList[index]['_id'],
                                catTitle:
                                    '${categoryList[index]['title'][0].toUpperCase()}${categoryList[index]['title'].substring(1)}',
                                token: widget.getTokenValue),
                          ),
                        );
                      },
                      child: Container(
                        width: 96,
                        padding: EdgeInsets.only(right: 16),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: 85,
                              height: 85,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.20)),
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: Image.network(
                                  categoryList[index]['filePath'] == null
                                      ? categoryList[index]['imageUrl']
                                      : Constants.IMAGE_URL_PATH +
                                          "tr:dpr-auto,tr:w-500" +
                                          categoryList[index]['filePath'],
                                  scale: 5,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text(
                              categoryList[index]['title'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textBarlowRegularrdarkdull(),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
