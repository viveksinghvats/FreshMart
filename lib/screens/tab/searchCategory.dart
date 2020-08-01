import 'package:flutter/material.dart';
import 'package:multilocationGroceryApp/model/counterModel.dart';
import 'package:multilocationGroceryApp/screens/categories/subcategories.dart';
import 'package:multilocationGroceryApp/screens/home/home.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/service/constants.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/service/product-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';

SentryError sentryError = new SentryError();

class SearchCategory extends StatefulWidget {
  final List productsList;
  final String currency, locale;
  final bool token;
  final Map localizedValues;
  SearchCategory(
      {Key key,
      this.productsList,
      this.currency,
      this.locale,
      this.token,
      this.localizedValues})
      : super(key: key);
  @override
  _SearchCategoryState createState() => _SearchCategoryState();
}

class _SearchCategoryState extends State<SearchCategory> {
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();
  bool isSearching = false,
      isFirstTime = true,
      getTokenValue = false,
      isTokenGetLoading = false;
  List searchresult = new List();
  String cartId, searchTerm;
  var cartData;
  String currency;

  @override
  void initState() {
    getCurrency();
    super.initState();
  }

  getCurrency() async {
    if (mounted) {
      setState(() {
        isTokenGetLoading = true;
      });
    }
    await Common.getCurrency().then((value) {
      currency = value;
    });
    await Common.getToken().then((onValue) {
      if (onValue != null) {
        if (mounted) {
          setState(() {
            getTokenValue = true;
            isTokenGetLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            getTokenValue = false;
            isTokenGetLoading = false;
          });
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          getTokenValue = false;
          isTokenGetLoading = false;
        });
      }
      sentryError.reportError(error, null);
    });
  }

  void _searchForProducts(String query) async {
    searchTerm = query;
    if (query.length > 2) {
      if (mounted) {
        setState(() {
          isFirstTime = false;
          isSearching = true;
        });
      }
      ProductService.getSearchCategoryList(query).then((onValue) {
        print('se cat $onValue');
        try {
          if (onValue != null && onValue['response_data'] is List) {
            if (mounted) {
              setState(() {
                searchresult = onValue['response_data'];
              });
            }
          } else {
            if (mounted) {
              setState(() {
                searchresult = [];
              });
            }
          }
          if (mounted) {
            setState(() {
              isSearching = false;
            });
          }
        } catch (error, stackTrace) {
          searchresult = [];
          if (mounted) {
            setState(() {
              isSearching = false;
            });
          }
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((error) {
        searchresult = [];
        if (mounted) {
          setState(() {
            isSearching = false;
          });
        }
        sentryError.reportError(error, null);
      });
    } else {
      searchresult = [];
      if (mounted) {
        setState(() {
          isFirstTime = true;
          isSearching = false;
        });
      }
    }
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
    return new Scaffold(
      key: globalKey,
      body: isTokenGetLoading
          ? SquareLoader()
          : ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15.0, left: 15.0, right: 15.0, top: 50.0),
                  child: Container(
                    child: new TextField(
                      controller: _controller,
                      style: new TextStyle(
                        color: Colors.black,
                      ),
                      decoration: new InputDecoration(
                        prefixIcon: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child:
                              new Icon(Icons.arrow_back, color: Colors.black),
                        ),
                        hintText:
                            MyLocalizations.of(context).whatareyoubuyingtoday,
                        fillColor: Color(0xFFF0F0F0),
                        filled: true,
                        focusColor: Colors.black,
                        contentPadding: EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                          top: 10.0,
                          bottom: 10.0,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.teal, width: 0.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amberAccent),
                        ),
                      ),
                      onSubmitted: (String term) {
                        searchTerm = term;
                        _searchForProducts(term);
                      },
                      onChanged: _searchForProducts,
                    ),
                  ),
                ),
                isFirstTime
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Text(
                              MyLocalizations.of(context).typeToSearch,
                              textAlign: TextAlign.center,
                              style: hintSfMediumprimary(),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          Icon(
                            Icons.search,
                            size: 50.0,
                            color: primary,
                          ),
                        ],
                      )
                    : searchresult.length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 18.0,
                                    bottom: 18.0,
                                    left: 20.0,
                                    right: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                        searchresult.length.toString() +
                                            " " +
                                            MyLocalizations.of(context)
                                                .itemsFounds,
                                        style: textBarlowMediumBlack()),
                                  ],
                                ),
                              ),
                              GridView.builder(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 16),
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: searchresult.length == null
                                    ? 0
                                    : searchresult.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio:
                                            MediaQuery.of(context).size.width /
                                                520,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16),
                                itemBuilder: (BuildContext context, int index) {
                                  if (searchresult[index]['averageRating'] ==
                                      null) {
                                    searchresult[index]['averageRating'] = 0;
                                  }
                                  return InkWell(
                                    onTap: () {
                                      var result = Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              SubCategories(
                                                  locale: widget.locale,
                                                  localizedValues:
                                                      widget.localizedValues,
                                                  catId: searchresult[index]
                                                      ['_id'],
                                                  catTitle:
                                                      '${searchresult[index]['title'][0].toUpperCase()}${searchresult[index]['title'].substring(1)}',
                                                  token: getTokenValue),
                                        ),
                                      );
                                      result.then((value) {
                                        searchresult = [];
                                        _searchForProducts(searchTerm);
                                      });
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
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
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  border: Border.all(
                                                      color: Colors.black
                                                          .withOpacity(0.20)),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  child: Image.network(
                                                    searchresult[index]
                                                                ['filePath'] ==
                                                            null
                                                        ? searchresult[index]
                                                            ['imageUrl']
                                                        : Constants
                                                                .IMAGE_URL_PATH +
                                                            "tr:dpr-auto,tr:w-500" +
                                                            searchresult[index]
                                                                ['filePath'],
                                                    scale: 5,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                searchresult[index]['title'],
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    textBarlowRegularrdarkdull(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : isSearching
                            ? Center(
                                child: SquareLoader(),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 100.0),
                                    child: Text(
                                      MyLocalizations.of(context)
                                          .noResultsFound,
                                      textAlign: TextAlign.center,
                                      style: hintSfMediumprimary(),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: 50.0,
                                    color: primary,
                                  ),
                                ],
                              )
              ],
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
    );
  }
}
