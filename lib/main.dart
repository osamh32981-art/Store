import 'package:flutter/material.dart';
void main()=>runApp(MaterialApp(debugShowCheckedModeBanner:false, theme: ThemeData.dark().copyWith(scaffoldBackgroundColor:Color(0xFF0A192F)), home: Store()));

List<Map> prods=[
  {"n":"ايفون 15","p":3500,"e":"📱"},
  {"n":"تيشيرت","p":79,"e":"👕"},
  {"n":"سماعة","p":149,"e":"🎧"},
];

class Store extends StatefulWidget{ @override State<Store> createState()=>_S(); }
class _S extends State<Store>{
  List<Map> cart=[];
  @override Widget build(BuildContext c){
    return Scaffold(
      appBar: AppBar(backgroundColor:Color(0xFF0A192F), title:Text("متجر كل شي - ${prods.length} منتج", style:TextStyle(color:Color(0xFF1E90FF), fontWeight:FontWeight.bold)), centerTitle:true),
      body: Column(children:[
        Container(color:Color(0xFF0E2342), padding:EdgeInsets.all(8), child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text("السلة: ${cart.length}", style:TextStyle(color:Colors.white70, fontSize:12)), Text("أنت الأدمن", style:TextStyle(color:Color(0xFF1E90FF), fontSize:11))])) ,
        Expanded(child: GridView.builder(padding:EdgeInsets.all(10), gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2, childAspectRatio:0.8, crossAxisSpacing:10, mainAxisSpacing:10), itemCount:prods.length, itemBuilder:(_,i){
          var pr=prods[i];
          return Container(decoration:BoxDecoration(color:Color(0xFF0E2342), borderRadius:BorderRadius.circular(12)), child:Column(children:[
            Expanded(child:Container(width:double.infinity, decoration:BoxDecoration(color:Color(0xFF0A192F), borderRadius:BorderRadius.vertical(top:Radius.circular(12))), child:Center(child:Text(pr["e"], style:TextStyle(fontSize:40))))),
            Padding(padding:EdgeInsets.all(8), child:Column(children:[
              Text(pr["n"], style:TextStyle(fontWeight:FontWeight.bold, fontSize:12)),
              Text("${pr["p"]} ر.س", style:TextStyle(color:Color(0xFF1E90FF), fontSize:11)),
              SizedBox(height:4),
              SizedBox(width:double.infinity, child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF1E90FF), padding:EdgeInsets.all(4)), onPressed:(){setState(()=>cart.add(pr)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("تمت الإضافة")));}, child:Text("أضف للسلة", style:TextStyle(fontSize:10)))),
            ]))
          ]));
        })),
        Container(padding:EdgeInsets.all(10), decoration:BoxDecoration(color:Color(0xFF0E2342)), child:Row(children:[
          Expanded(child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF0E2342), side:BorderSide(color:Color(0xFF1E90FF))), onPressed:()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>AddPage(onAdd:(m){setState(()=>prods.insert(0,m));}))), child:Text("أنشر منتج جديد - أنت الأدمن", style:TextStyle(color:Color(0xFF1E90FF), fontSize:11)))) ,
          SizedBox(width:8),
          ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF1E90FF)), onPressed:()=>Navigator.push(c, MaterialPageRoute(builder:(_)=>CartPage(cart:cart))), child:Text("السلة (${cart.length})")),
        ]))
      ]),
    );
  }
}

class AddPage extends StatefulWidget{ final Function(Map) onAdd; AddPage({required this.onAdd}); @override State<AddPage> createState()=>_A(); }
class _A extends State<AddPage>{
  final n=TextEditingController(); final p=TextEditingController(); String e="📦";
  @override Widget build(BuildContext c){
    return Scaffold(appBar:AppBar(backgroundColor:Color(0xFF0A192F), title:Text("أنشر منتج - كل الناس تشوفه")), body:ListView(padding:EdgeInsets.all(16), children:[
      Row(children:["📦","📱","👕","👟","🎧","💻"].map((x)=>InkWell(onTap:()=>setState(()=>e=x), child:Container(margin:EdgeInsets.only(right:6), padding:EdgeInsets.all(10), decoration:BoxDecoration(color:e==x?Color(0xFF1E90FF):Color(0xFF0E2342), borderRadius:BorderRadius.circular(8)), child:Text(x, style:TextStyle(fontSize:20))))).toList()),
      SizedBox(height:12),
      TextField(controller:n, decoration:InputDecoration(labelText:"اسم المنتج", border:OutlineInputBorder(borderRadius:BorderRadius.circular(10)), filled:true, fillColor:Color(0xFF0E2342))),
      SizedBox(height:10),
      TextField(controller:p, keyboardType:TextInputType.number, decoration:InputDecoration(labelText:"السعر", border:OutlineInputBorder(borderRadius:BorderRadius.circular(10)), filled:true, fillColor:Color(0xFF0E2342))),
      SizedBox(height:12),
      SizedBox(height:50, child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor:Color(0xFF1E90FF)), onPressed:(){
        if(n.text.isEmpty||p.text.isEmpty) return;
        widget.onAdd({"n":n.text,"p":double.tryParse(p.text)??0,"e":e});
        Navigator.pop(c);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text("✅ تم النشر - كل الناس تشوفه"), backgroundColor:Colors.green));
      }, child:Text("نشر الآن"))),
    ]));
  }
}

class CartPage extends StatelessWidget{
  final List<Map> cart; CartPage({required this.cart});
  @override Widget build(BuildContext c){
    double t=0; for(var x in cart) t+=x["p"];
    return Scaffold(appBar:AppBar(backgroundColor:Color(0xFF0A192F), title:Text("السلة")), body:Column(children:[
      Expanded(child:ListView.builder(padding:EdgeInsets.all(10), itemCount:cart.length, itemBuilder:(_,i){var pr=cart[i]; return Container(margin:EdgeInsets.only(bottom:6), padding:EdgeInsets.all(10), decoration:BoxDecoration(color:Color(0xFF0E2342), borderRadius:BorderRadius.circular(8)), child:Row(children:[Text(pr["e"]), SizedBox(width:10), Text(pr["n"]), Spacer(), Text("${pr["p"]} ر.س", style:TextStyle(color:Color(0xFF1E90FF)))]));})),
      Container(padding:EdgeInsets.all(12), color:Color(0xFF0E2342), child:Row(main