import 'package:flutter/material.dart';
void main()=>runApp(MaterialApp(debugShowCheckedModeBanner:false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor:Color(0xFF0A192F)), home: SuperStore()));

List<Map<String,dynamic>> allProducts=[
  {"id":1,"name":"ايفون 15","price":3500,"cat":"الكترونيات","emoji":"📱","desc":"جديد بالكرتون","stock":10,"rate":4.8},
  {"id":2,"name":"تيشيرت رجالي","price":79,"cat":"ملابس","emoji":"👕","desc":"قطن 100%","stock":50,"rate":4.5},
  {"id":3,"name":"سماعة بلوتوث","price":149,"cat":"الكترونيات","emoji":"🎧","desc":"عزل ضوضاء","stock":20,"rate":4.7},
  {"id":4,"name":"حذاء رياضي","price":199,"cat":"احذية","emoji":"👟","desc":"مريح للجري","stock":15,"rate":4.6},
  {"id":5,"name":"ساعة ذكية","price":299,"cat":"الكترونيات","emoji":"⌚","desc":"تتبع صحة","stock":8,"rate":4.9},
  {"id":6,"name":"شنطة","price":120,"cat":"اكسسوارات","emoji":"👜","desc":"جلد فاخر","stock":12,"rate":4.4},
];

class SuperStore extends StatefulWidget{ @override State<SuperStore> createState()=>_SS(); }
class _SS extends State<SuperStore>{
  int nav=0;
  List<Map<String,dynamic>> cart=[];
  List<Map<String,dynamic>> fav=[];
  List<Map<String,dynamic>> orders=[];
  String search=""; String cat="الكل";

  void addCart(Map<String,dynamic> p){
    var idx=cart.indexWhere((e)=>e["id"]==p["id"]);
    if(idx>=0) setState(()=> cart[idx]["qty"]+=1);
    else setState(()=> cart.add({...p,"qty":1}));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("تمت الإضافة: ${p["name"]}"), backgroundColor:Color(0xFF1E90FF), duration: Duration(milliseconds:600)));
  }

  @override Widget build(BuildContext c){
    List<Map<String,dynamic>> filtered = allProducts.where((p){
      bool s = p["name"].toString().contains(search) || p["desc"].toString().contains(search);
      bool cc = cat=="الكل" || p["cat"]==cat;
      return (search.isEmpty || s) && cc;
    }).toList();

    var pages=[
      HomeStore(products:filtered, onAdd:addCart, onFav:(p){setState(()=> fav.contains(p)?fav.remove(p):fav.add(p));}, fav:fav, searchChanged:(v)=>setState(()=>search=v), catChanged:(v)=>setState(()=>cat=v), currentCat:cat),
      FavPage(fav:fav, onAdd:addCart),
      CartFull(cart:cart, onOrder:(total){ setState(()=> orders.add({"items":List.from(cart),"total":total,"date":DateTime.now().toString().substring(0,16)})); cart.clear(); setState(()=>nav=3); }),
      OrdersPage(orders:orders),
      AdminPage(onAdd:(p){setState(()=> allProducts.insert(0,p));}, onDelete:(id){setState(()=> allProducts.removeWhere((e)=>e["id"]==id));}, products:allProducts, orders:orders),
    ];

    return Scaffold(
      appBar: AppBar(backgroundColor:Color(0xFF0A192F), title: Text(nav==0?"متجر كل شي - ${filtered.length}":nav==1?"المفضلة ${fav.length}":nav==2?"السلة ${cart.length}":nav==3?"طلباتي ${orders.length}":"لوحة الأدمن - أنت تنشر", style:TextStyle(color:Color(0xFF1E90FF), fontSize:14, fontWeight:FontWeight.bold)), centerTitle:true, actions: nav==2 && cart.isNotEmpty ? [IconButton(icon:Icon(Icons.delete), onPressed:()=>setState(()=>cart.clear()))] : null),
      body: pages[nav],
      bottomNavigationBar: BottomNavigationBar(backgroundColor:Color(0xFF0E2342), selectedItemColor:Color(0xFF1E90FF), unselectedItemColor:Colors.white38, currentIndex:nav, onTap:(i)=>setState(()=>nav=i), type: BottomNavigationBarType.fixed, items:[
        BottomNavigationBarItem(icon:Icon(Icons.store), label:"الرئيسية"),
        BottomNavigationBarItem(icon:Icon(Icons.favorite), label:"المفضلة"),
        BottomNavigationBarItem(icon:Stack(children:[Icon(Icons.shopping_cart), if(cart.isNotEmpty) Positioned(right:0, child: Container(padding:EdgeInsets.all(2), decoration:BoxDecoration(color:Colors.red, shape:BoxShape.circle), child: Text("${cart.length}", style:TextStyle(fontSize:8))))]), label:"السلة"),
        BottomNavigationBarItem(icon:Icon(Icons.receipt), label:"طلباتي"),
        BottomNavigationBarItem(icon:Icon(Icons.admin_panel_settings), label:"أنشر"),
      ]),
    );
  }
}

class HomeStore extends StatelessWidget{
  final List<Map<String,dynamic>> products; final List fav; final Function(Map<String,dynamic>) onAdd; final Function(Map<String,dynamic>) onFav; final Function(String) searchChanged; final Function(String) catChanged; final String currentCat;
  HomeStore({required this.products, required this.onAdd, required this.onFav, required this.fav, required this.searchChanged, required this.catChanged, required this.currentCat});
  @override Widget build(BuildContext c){
    var cats=["الكل","الكترونيات","ملابس","احذية","اكسسوارات"];
    return Column(children:[
      Padding(padding: EdgeInsets.all(10), child: TextField(onChanged: searchChanged, decoration: InputDecoration(hintText:"ابحث عن أي شي...", prefixIcon: Icon(Icons.search, color:Color(0xFF1E90FF)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled:true, fillColor: Color(0xFF0E2342)))),
      SizedBox(height:6, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cats.length, itemBuilder: (_,i)=> InkWell(onTap: ()=> catChanged(cats[i]), child: Container(margin: EdgeInsets.symmetric(horizontal:4), padding: EdgeInsets.symmetric(horizontal:12, vertical:6), decoration: BoxDecoration(color: currentCat==cats[i]?Color(0xFF1E90FF):Color(0xFF0E2342), borderRadius: BorderRadius.circular(20)), child: Text(cats[i], style: TextStyle(fontSize:11)))))),
      Expanded(child: products.isEmpty ? Center(child: Text("لا يوجد منتجات", style: TextStyle(color: Colors.white38))) : GridView.builder(padding: EdgeInsets.all(10), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.68, crossAxisSpacing:10, mainAxisSpacing:10), itemCount: products.length, itemBuilder: (_,i){
        var p=products[i]; bool isFav=fav.contains(p);
        return InkWell(onTap: ()=> Navigator.push(c, MaterialPageRoute(builder: (_)=> DetailsPage(p:p, onAdd:onAdd))), child: Container(decoration: BoxDecoration(color: Color(0xFF0E2342), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
          Stack(children:[
            Container(height:110, width:double.infinity, decoration: BoxDecoration(color: Color(0xFF0A192F), borderRadius: BorderRadius.vertical(top: Radius.circular(14))), child: Center(child: Text(p["emoji"], style: TextStyle(fontSize:50)))),
            Positioned(top:6, right:6, child: InkWell(onTap: ()=> onFav(p), child: Container(padding: EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle), child: Icon(isFav?Icons.favorite:Icons.favorite_border, color: isFav?Colors.red:Colors.white, size:16)))),
            if(p["stock"]<5) Positioned(top:6, left:6, child: Container(padding: EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)), child: Text("باقي ${p["stock"]}", style: TextStyle(fontSize:8)))),
          ]),
          Padding(padding: EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
            Text(p["cat"], style: TextStyle(color: Color(0xFF1E90FF), fontSize:8)),
            Text(p["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize:12), maxLines:1),
            Row(children:[Icon(Icons