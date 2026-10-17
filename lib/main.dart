import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(debugShowCheckedModeBanner:false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Color(0xFF0A192F)), home: StoreApp()));

// بيانات المتجر - كل الناس تشوفها
List<Map<String,dynamic>> products = [
  {"name":"سماعة LAN Connect","price":99,"img":"🎧","desc":"صوت نقي يعمل بدون انترنت"},
  {"name":"راوتر محمول","price":199,"img":"📶","desc":"انشئ شبكة LAN في أي مكان"},
];

class StoreApp extends StatefulWidget{ @override State<StoreApp> createState()=>_StoreS(); }
class _StoreS extends State<StoreApp>{
  int nav=0;
  List<Map<String,dynamic>> cart=[];
  
  @override Widget build(BuildContext c){
    var pages=[HomePage(products:products, onAdd:(p){setState(()=> cart.add(p)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("تمت الإضافة للسلة")));} ), CartPage(cart:cart), PublishPage(onPublish:(p){setState(()=> products.insert(0,p));}), ProfilePage()];
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFF0A192F), title: Text(nav==0?"متجري - ${products.length} منتج":nav==1?"السلة (${cart.length})":nav==2?"لوحة النشر - أنت الأدمن":"حسابي", style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold)), centerTitle:true),
      body: pages[nav],
      bottomNavigationBar: BottomNavigationBar(backgroundColor: Color(0xFF0E2342), selectedItemColor: Color(0xFF1E90FF), unselectedItemColor: Colors.white38, currentIndex: nav, onTap: (i)=> setState(()=> nav=i), items:[
        BottomNavigationBarItem(icon: Icon(Icons.store), label:"الرئيسية"),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label:"السلة"),
        BottomNavigationBarItem(icon: Icon(Icons.add_box), label:"أنشر"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label:"حسابي"),
      ]),
    );
  }
}

// 1- الرئيسية - كل الناس تشوف
class HomePage extends StatelessWidget{
  final List<Map<String,dynamic>> products; final Function(Map<String,dynamic>) onAdd;
  HomePage({required this.products, required this.onAdd});
  @override Widget build(BuildContext c){
    return GridView.builder(padding: EdgeInsets.all(12), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.75, crossAxisSpacing:10, mainAxisSpacing:10), itemCount: products.length, itemBuilder: (_,i){
      var p=products[i];
      return Container(decoration: BoxDecoration(color: Color(0xFF0E2342), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Expanded(child: Container(width:double.infinity, decoration: BoxDecoration(color: Color(0xFF0A192F), borderRadius: BorderRadius.vertical(top: Radius.circular(14))), child: Center(child: Text(p["img"], style: TextStyle(fontSize:50))))),
        Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Text(p["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), maxLines:1),
          Text(p["desc"], style: TextStyle(color: Colors.white38, fontSize:10), maxLines:1),
          SizedBox(height:4),
          Row(children:[Text("${p["price"]} ر.س", style: TextStyle(color: Color(0xFF1E90FF), fontWeight: FontWeight.bold)), Spacer(), InkWell(onTap: ()=> onAdd(p), child: Container(padding: EdgeInsets.symmetric(horizontal:8, vertical:4), decoration: BoxDecoration(color: Color(0xFF1E90FF), borderRadius: BorderRadius.circular(8)), child: Text("أضف", style: TextStyle(fontSize:10))))])
        ]))
      ]));
    });
  }
}

// 2- السلة
class CartPage extends StatelessWidget{
  final List<Map<String,dynamic>> cart;
  CartPage({required this.cart});
  @override Widget build(BuildContext c){
    double total=0; for(var p in cart) total+=p["price"];
    if(cart.isEmpty) return Center(child: Column