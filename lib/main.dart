import 'package:flutter/material.dart';

void main() => runApp(const MyShopApp());

class MyShopApp extends StatelessWidget {
  const MyShopApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(fontFamily: 'Cairo', scaffoldBackgroundColor: const Color(0xFFF9FAFB)),
      home: const ShopPage(),
    );
  }
}

class Product {
  final String title;
  final int price;
  final int oldPrice;
  final String emoji;
  final String cat;
  Product(this.title, this.price, this.oldPrice, this.emoji, this.cat);
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  List<Product> allProducts = [
    Product("ساعة ذكية فاخرة - Smart Watch", 199, 350, "⌚", "إلكترونيات"),
    Product("سماعة بلوتوث عازلة للضوضاء", 149, 250, "🎧", "إلكترونيات"),
    Product("حذاء رياضي نايك", 289, 400, "👟", "أزياء"),
    Product("حقيبة ظهر للسفر", 129, 200, "🎒", "أزياء"),
    Product("عطر عود فاخر 100مل", 249, 350, "🌸", "عطور"),
    Product("كوب قهوة حافظ للحرارة", 59, 90, "☕", "منزل"),
  ];

  List<Product> cart = [];
  String activeCat = "الكل";
  String search = "";

  List<Product> get filtered {
    return allProducts.where((p) {
      bool catOk = activeCat == "الكل" || p.cat == activeCat;
      bool searchOk = p.title.contains(search);
      return catOk && searchOk;
    }).toList();
  }

  int get total => cart.fold(0, (sum, item) => sum + item.price);

  void addToCart(Product p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تمت الإضافة للسلة ✅"), duration: Duration(milliseconds: 800)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Row(
            children: [
              Text("متجري", style: TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900, fontSize: 24)),
              Text(".كوم", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
            ],
          ),
          actions: [
            Stack(
              children: [
                IconButton(icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black), onPressed: () => openCart()),
                if (cart.isNotEmpty)
                  Positioned(
                    left: 5, top: 5,
                    child: CircleAvatar(radius: 9, backgroundColor: const Color(0xFFFF6B00),
                    child: Text("${cart.length}", style: const TextStyle(fontSize: 10, color: Colors.white))),
                  ),
              ],
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            // بنر العرض
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B00), Color(0xFFFF9A3D)]), borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("عروض اليوم\nخصم حتى 50%", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: (){setState(()=>activeCat="الكل");}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF6B00), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("تسوق الآن"))
                  ]),
                  const Text("🛍️", style: TextStyle(fontSize: 60)),
                ],
              ),
            ),
            // بحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => search = v),
                decoration: InputDecoration(hintText: "ابحث عن منتج...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)),
              ),
            ),
            // أقسام
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: ["الكل", "إلكترونيات", "أزياء", "عطور", "منزل"].map((c) {
                  bool isActive = activeCat == c;
                  return GestureDetector(
                    onTap: () => setState(() => activeCat = c),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(color: isActive? Colors.black : Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade200)),
                      child: Text(c, style: TextStyle(color: isActive? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
            ),
            // منتجات
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  var p = filtered[i];
                  return Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                    child: Column(
                      children: [
                        Expanded(child: Container(margin: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 50))))),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("${p.oldPrice} ر.س", style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                                const SizedBox(width: 4),
                                Text("${p.price} ر.س", style: const TextStyle(color: Color(0xFFFF6B00), fontWeight: FontWeight.w900)),
                              ]),
                              const SizedBox(height: 6),
                              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => addToCart(p), style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 8)), child: const Text("+ أضف للسلة", style: TextStyle(fontSize: 12)))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("سلة التسوق", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ]),
              Expanded(
                child: cart.isEmpty? const Center(child: Text("السلة فارغة 🛒")) :
                ListView.builder(
                  itemCount: cart.length,
                  itemBuilder: (c, i) => ListTile(
                    leading: Text(cart[i].emoji, style: const TextStyle(fontSize: 30)),
                    title: Text(cart[i].title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text("${cart[i].price} ر.س", style: const TextStyle(color: Color(0xFFFF6B00))),
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: (){
                      setModal(() => cart.removeAt(i));
                      setState((){});
                    }),
                  ),
                ),
              ),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("الإجمالي:", style: TextStyle(fontWeight: FontWeight.bold)), Text("$total ر.س", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFFFF6B00)))]),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){
                if(cart.isEmpty) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("تم إرسال الطلب - الإجمالي $total ر.س - سنتواصل عبر واتساب 📲")));
                setState(() => cart.clear());
              }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00), foregroundColor: Colors.white, padding: const EdgeInsets.all(14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text("إتمام الطلب عبر واتساب 📲", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
            ],
          ),
        ),
      ),
    );
  }
}