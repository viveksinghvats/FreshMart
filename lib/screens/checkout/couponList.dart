import 'dart:async';

import 'package:getflutter/components/appbar/gf_appbar.dart';
import 'package:getflutter/components/loader/gf_loader.dart';
import 'package:getflutter/types/gf_loader_type.dart';
import 'package:multilocationGroceryApp/service/coupon-service.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:async_loader/async_loader.dart';

class CouponsList extends StatefulWidget {
  final locale;
  final Map localizedValues, cartItem;

  CouponsList({Key key, this.locale, this.localizedValues, this.cartItem})
      : super(key: key);

  @override
  _CouponsListState createState() => _CouponsListState();
}

class _CouponsListState extends State<CouponsList> {
  final GlobalKey<AsyncLoaderState> _asyncLoaderState =
      GlobalKey<AsyncLoaderState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isApplyCoupon = false;
  String couponId;
  Future<dynamic> getCouponsByLocationId() async {
    return await CouponService.couponList();
  }

  applyCoupon(couponCode) async {
    if (mounted) {
      setState(() {
        isApplyCoupon = true;
      });
    }
    await CouponService.applyCouponsCode(widget.cartItem['_id'], couponCode)
        .then((dataResponse) {
      try {
        if (mounted) {
          setState(() {
            isApplyCoupon = false;
          });
        }
        if (dataResponse['response_code'] == 200) {
          if (mounted) {
            setState(() {
              Navigator.of(context).pop();
            });
          }
        } else {
          showSnackbar(dataResponse['response_data']['message']);
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            isApplyCoupon = false;
          });
        }
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          isApplyCoupon = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GFAppBar(
        title: Text(
          MyLocalizations.of(context).couponList ?? "coupon list",
          style: textbarlowSemiBoldBlack(),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black, size: 1.0),
      ),
      body: AsyncLoader(
        key: _asyncLoaderState,
        initState: () async => await getCouponsByLocationId(),
        renderLoad: () => Center(child: SquareLoader()),
        renderError: ([error]) {
          return Center(
            child: Image.asset('lib/assets/images/no-orders.png'),
          );
        },
        renderSuccess: ({data}) {
          if (data["response_data"] is List) {
            return ListView.builder(
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: data["response_data"].length,
                itemBuilder: (BuildContext context, int index) {
                  return couponCard(
                    data["response_data"][index],
                  );
                });
          } else {
            return Center(
              child: Image.asset('lib/assets/images/no-orders.png'),
            );
          }
        },
      ),
    );
  }

  Widget couponCard(Map data) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCardHeader(data),
            buildCuisineHolder(data),
            buildCardBottom(context, data),
          ],
        ),
      ),
    );
  }

  Widget buildCardHeader(Map coupon) {
    return Row(
      children: [
        Expanded(
          child: Text(
            coupon['couponCode'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              height: 1.0,
            ),
          ),
          flex: 6,
        ),
      ],
    );
  }

  Widget buildCuisineHolder(Map coupon) {
    return Text(
      coupon['description'],
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.left,
      style: TextStyle(
        fontSize: 11.0,
        height: 1.4,
      ),
    );
  }

  Widget buildCardBottom(BuildContext context, Map coupon) {
    return Column(
      children: <Widget>[
        Divider(),
        Row(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: Row(
                children: <Widget>[
                  coupon['couponType'] == "FLAT"
                      ? Text(
                          coupon['couponType'] +
                              " " +
                              coupon['offerValue'].toString() +
                              " " +
                              MyLocalizations.of(context).off,
                          style: TextStyle(color: Colors.green))
                      : Text(
                          coupon['offerValue'].toString() +
                              '% ' +
                              MyLocalizations.of(context).off,
                          style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  couponId = coupon['_id'];
                  applyCoupon(coupon['couponCode']);
                },
                child: isApplyCoupon && couponId == coupon['_id']
                    ? GFLoader(
                        type: GFLoaderType.ios,
                        size: 15,
                      )
                    : Text(MyLocalizations.of(context).apply,
                        style: TextStyle(color: Colors.amber)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 3000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}
