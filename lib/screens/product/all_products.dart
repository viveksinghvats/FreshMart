import 'package:flutter/material.dart';
import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:multilocationGroceryApp/model/counterModel.dart';
import 'package:multilocationGroceryApp/screens/drawer/drawer.dart';
import 'package:multilocationGroceryApp/screens/home/home.dart';
import 'package:multilocationGroceryApp/screens/product/product-details.dart';
import 'package:multilocationGroceryApp/screens/tab/searchitem.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/product-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/cardOverlay.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';
import 'package:multilocationGroceryApp/widgets/subCategoryProductCart.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

SentryError sentryError = new SentryError();

class AllProducts extends StatefulWidget {
  final Map localizedValues;
  final String locale, currency;
  final bool token;
  final List productsList;

  AllProducts(
      {Key key,
        this.locale,
        this.localizedValues,
        this.productsList,
        this.currency,
        this.token});
  @override
  _AllProductsState createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  List productsList = [], subCategryByProduct, subCategryList;
  String currency;
  bool getTokenValue = false,
      isLoadingProductsList = false,
      isSelected = true,
      isSelectedIndexZero = false;
  RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  ScrollController controller;
  ScrollController _scrollController = ScrollController();
  int index = 0, totalIndex = 1;
  bool productListApiCall = false,
      isNewProductsLoading = false,
      isLoadingSubCatProductsList = false,
      lastApiCall = true;
  var cartData;
  String isSelectetedId;
  @override
  void initState() {
    getTokenValueMethod();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  getTokenValueMethod() async {
    if (mounted) {
      setState(() {
        isLoadingProductsList = true;
      });
    } await Common.getCurrency().then((value) {
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

      getProductListMethod(index);
    }).catchError((error) {
      if (mounted) {
        setState(() {
          getTokenValue = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  getProductListMethod(productIndex) async {
    setState(() {
      isNewProductsLoading = true;
    });

    await ProductService.getProductListAll(productIndex).then((onValue) {
      try {
        _refreshController.refreshCompleted();
        if (onValue['response_code'] == 200) {
          if (mounted) {
            setState(() {
              productsList.addAll(onValue['response_data']['products']);
              index = productsList.length;
              totalIndex = onValue['response_data']["total"];
              if (lastApiCall == true) {
                if (index < totalIndex) {
                  getProductListMethod(index);
                } else {
                  if (index == totalIndex) {
                    if (mounted) {
                      lastApiCall = false;
                      getProductListMethod(index);
                    }
                  }
                }
              }
              isLoadingProductsList = false;
              isNewProductsLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              productsList = [];
              isLoadingProductsList = false;
              isNewProductsLoading = false;
            });
          }
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            productsList = [];
            isLoadingProductsList = false;
            isNewProductsLoading = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          productsList = [];
          isLoadingProductsList = false;
          isNewProductsLoading = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  getProductToSubCategory(catId) async {
    if (mounted) {
      setState(() {
        isLoadingSubCatProductsList = true;
      });
    }
    await ProductService.getProductToSubCategoryList(catId).then((onValue) {
      try {
        if (onValue['response_code'] == 200) {
          if (mounted)
            setState(() {
              subCategryByProduct = onValue['response_data'];
              isLoadingSubCatProductsList = false;
            });
        } else {
          if (mounted)
            setState(() {
              subCategryByProduct = [];
              isLoadingSubCatProductsList = false;
            });
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            isLoadingSubCatProductsList = false;
          });
        }
        sentryError.reportError(error, stackTrace);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isLoadingSubCatProductsList = false;
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
          MyLocalizations.of(context).products,
          style: textbarlowSemiBoldBlack(),
        ),
        centerTitle: true,
        leading: BackButton(),
        actions: <Widget>[
          InkWell(
            onTap: () {
              var result = Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchItem(
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
          productsList = [];
          index = productsList.length;
          getTokenValueMethod();
        },
        child: isLoadingProductsList
            ? SquareLoader()

            : Padding(
          padding:
          EdgeInsets.only(left: 15, right: 15, top: 15),
          child: GridView.builder(
            padding: EdgeInsets.only(bottom: 25),
            physics: ScrollPhysics(),
            shrinkWrap: true,
            itemCount: productsList.length == null
                ? 0
                : productsList.length,
            gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                MediaQuery.of(context).size.width /560,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16),
            itemBuilder: (BuildContext context, int i) {
              if (productsList[i]['averageRating'] == null) {
                productsList[i]['averageRating'] = 0;
              }

              return productsList[i]['outOfStock'] != null ||
                  productsList[i]['outOfStock'] != false
                  ? InkWell(
                onTap: () {
                  var result = Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetails(
                            locale: widget.locale,
                            localizedValues:
                            widget.localizedValues,
                            productID: productsList[i]
                            ['_id'],
                          ),
                    ),
                  );
                  result.then((value) {
                    if (mounted) {
                      setState(() {
                        isLoadingProductsList = true;
                      });
                    }
                    index = 0;
                    totalIndex = 1;
                    productsList = [];
                    getTokenValueMethod();
                  });
                },
                child: Stack(
                  children: <Widget>[
                    SubCategoryProductCard(
                        image: productsList[i]['filePath'] == null
                            ? productsList[i]
                        ['imageUrl']
                            : productsList[i]
                        ['filePath'],
                        isPath: productsList[i]['filePath'] == null
                            ? false
                            : true,
                        title: productsList[i]['title'],
                        currency: currency,
                        category: productsList[i]
                        ['category'],
                        price: productsList[i]
                        ['variant'][0]['price'],
                        mrp: productsList[i]
                        ['variant'][0]['MRP'],
                        dealPercentage: productsList[i]
                        ['isDealAvailable']
                            ? double.parse(productsList[i]
                        ['delaPercent']
                            .toStringAsFixed(1))
                            : null,
                        variantStock: productsList[i]
                        ['variant'][0]
                        ['productstock'],
                        unit: productsList[i]['variant']
                        [0]['unit'],
                        rating: productsList[i]['averageRating'].toStringAsFixed(1),
                        buttonName: "Add",
                        cartAdded: productsList[i]['cartAdded'] ?? false,
                        cartId: productsList[i]['cartId'],
                        productQuantity: productsList[i]['cartAddedQuantity'] ?? 0,
                        token: widget.token,
                        productList: productsList[i],
                        variantList: productsList[i]['variant'],
                        subCategoryId: productsList[i]['subcategory']),
                    productsList[i]
                    ['isDealAvailable'] ==
                        true
                        ? Positioned(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: 61,
                            height: 18,
                            decoration: BoxDecoration(
                                color:
                                Color(0xFFFFAF72),
                                borderRadius:
                                BorderRadius.only(
                                    topLeft: Radius
                                        .circular(
                                        10),
                                    bottomRight: Radius
                                        .circular(
                                        10))),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets
                                .all(2.0),
                            child: Text(
                              " " +
                                  productsList[i][
                                  'delaPercent']
                                      .toString() +
                                  "% " +
                                  MyLocalizations.of(
                                      context)
                                      .off,
                              style:
                              hintSfboldwhitemed(),
                              textAlign: TextAlign
                                  .center,
                            ),
                          )
                        ],
                      ),
                    )
                        : Container()
                  ],
                ),
              )
                  : Stack(
                children: <Widget>[
                  SubCategoryProductCard(
                      image: productsList[i]['filePath'] == null
                          ? productsList[i]['imageUrl']
                          : productsList[i]['filePath'],
                      isPath:
                      productsList[i]['filePath'] == null
                          ? false
                          : true,
                      title: productsList[i]['title'],
                      currency: currency,
                      category: productsList[i]
                      ['category'],
                      price: productsList[i]['variant']
                      [0]['price'],
                      mrp: productsList[i]
                      ['variant'][0]['MRP'],
                      dealPercentage: productsList[i]
                      ['isDealAvailable']
                          ? double.parse(productsList[i]
                      ['delaPercent']
                          .toStringAsFixed(1))
                          : null,
                      unit: productsList[i]['variant']
                      [0]['unit'],
                      rating: productsList[i]
                      ['averageRating']
                          .toStringAsFixed(1),
                      buttonName: MyLocalizations.of(context).add,
                      cartAdded: productsList[i]['cartAdded'] ?? false,
                      cartId: productsList[i]['cartId'],
                      productQuantity: productsList[i]['cartAddedQuantity'] ?? 0,
                      token: widget.token,
                      productList: productsList[i],
                      variantList: productsList[i]['variant'],
                      subCategoryId: productsList[i]['subcategory']),
                  CardOverlay()
                ],
              );
            },
          ),
        ),
      ),

      bottomNavigationBar: cartData == null
          ? Container(
        height: 10.0,
      )
          : InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => Home(
                locale: widget.locale,
                localizedValues: widget.localizedValues,
                currentIndex: 2,
              ),
            ),
          );
        },
        child: Container(
          height: 55.0,
          decoration: BoxDecoration(color: primary, boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.29), blurRadius: 5)
          ]),
          padding: EdgeInsets.only(right: 20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    height: 55,
                    width: MediaQuery.of(context).size.width * 0.35,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 7),
                        new Text(
                          '(${cartData['cart'].length})  ' +
                              MyLocalizations.of(context).items,
                          style: textBarlowRegularWhite(),
                        ),
                        new Text(
                          "$currency${cartData['subTotal'].toStringAsFixed(2)}",
                          style: textbarlowBoldWhite(),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      new Text(
                        MyLocalizations.of(context).goToCart,
                        style: textBarlowRegularBlack(),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        IconData(
                          0xe911,
                          fontFamily: 'icomoon',
                        ),
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ],
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