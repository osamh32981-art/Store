import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const SouqApp());

const Map<String, IconData> kCategories = {
  'سيارات': Icons.directions_car,
  'عقارات': Icons.home_work,
  'جوالات': Icons.smartphone,
  'إلكترونيات': Icons.laptop_mac,
  'أثاث': Icons.chair,
  'وظائف': Icons.work,
  'خدمات': Icons.handyman,
  'تطبيقات': Icons.apps,
  'أخرى': Icons.category,
};

class Ad {
  final String id, title, category, city, desc, phone;
  final double price;
  final int time;
  final bool mine;

  Ad({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.desc,
    required this.phone,
    required this.price,
    required this.time,
    this.mine = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'city': city,
        'desc': desc,
        'phone': phone,
        'price': price,
        'time': time,
        'mine': mine,
      };

  factory Ad.fromJson(Map<String, dynamic> j) => Ad(
        id: j['id'],
        title: j['title'],
        category: j['category'],
        city: j['city'],
        desc: j['desc'],
        phone: j['phone'],
        price: (j['price'] as num).toDouble(),
        time: j['time'],
        mine: j['mine'] ?? false,
      );

  Color get color =>
      Colors.primaries[title.hashCode.abs() % Colors.primaries.length];
}

String priceText(double p) => p == 0 ? 'مجاناً' : '${p.toStringAsFixed(0)} ر.س';

String ago(int t) {
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(t));
  if (d.inMinutes < 1) return 'الآن';
  if (d.inMinutes < 60) return 'قبل ${d.inMinutes} دقيقة';
  if (d.inHours < 24) return 'قبل ${d.inHours} ساعة';
  return 'قبل ${d.inDays} يوم';
}

class SouqApp extends StatelessWidget {
  const SouqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوق',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A75)),
        scaffoldBackgroundColor: const Color(0xFFF5F7F8),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Ad> ads = [];
  Set<String> favs = {};
  int tab = 0;
  String? cat;
  String q = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('ads');
    if (raw != null) {
      ads = (jsonDecode(raw) as List)
          .map((e) => Ad.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      final now = DateTime.now().millisecondsSinceEpoch;
      ads = [
        Ad(id: '1', title: 'تويوتا كامري 2020 نظيفة', category: 'سيارات', city: 'الرياض', desc: 'سيارة بحالة ممتازة، ماشية 60 ألف كم، صيانة دورية بالوكالة.', phone: '0500000001', price: 68000, time: now - 3600000),
        Ad(id: '2', title: 'آيفون 14 برو للبيع', category: 'جوالات', city: 'جدة', desc: 'مستعمل شهرين، مع كل ملحقاته والكرتون.', phone: '0500000002', price: 3200, time: now - 7200000),
        Ad(id: '3', title: 'تطبيق توصيل جاهز للبيع', category: 'تطبيقات', city: 'الدمام', desc: 'تطبيق Flutter كامل مع لوحة تحكم وكود المصدر.', phone: '0500000003', price: 5000, time: now - 86400000),
        Ad(id: '4', title: 'كنب 7 مقاعد', category: 'أثاث', city: 'مكة', desc: 'كنب مودرن بحالة الجديد، السبب السفر.', phone: '0500000004', price: 900, time: now - 172800000),
      ];
    }
    favs = (p.getStringList('favs') ?? []).toSet();
    setState(() => loading = false);
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('ads', jsonEncode(ads.map((e) => e.toJson()).toList()));
    await p.setStringList('favs', favs.toList());
  }

  void _toggleFav(Ad a) {
    setState(() => favs.contains(a.id) ? favs.remove(a.id) : favs.add(a.id));
    _save();
  }

  Future<void> _add() async {
    final ad = await Navigator.push<Ad>(
        context, MaterialPageRoute(builder: (_) => const AddPage()));
    if (ad != null) {
      setState(() => ads.insert(0, ad));
      _save();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('تم نشر إعلانك')));
      }
    }
  }

  Future<void> _open(Ad a) async {
    final r = await Navigator.push<String>(
        context,
        MaterialPageRoute(
            builder: (_) => DetailsPage(ad: a, fav: favs.contains(a.id))));
    if (r == 'delete') {
      setState(() {
        ads.removeWhere((e) => e.id == a.id);
        favs.remove(a.id);
      });
      _save();
    } else if (r == 'fav') {
      _toggleFav(a);
    }
  }

  List<Ad> get shown {
    var l = ads.where((a) {
      if (tab == 1 && !favs.contains(a.id)) return false;
      if (tab == 2 && !a.mine) return false;
      if (tab == 0 && cat != null && a.category != cat) return false;
      if (q.isNotEmpty && !(a.title.contains(q) || a.desc.contains(q))) {
        return false;
      }
      return true;
    }).toList();
    l.sort((a, b) => b.time.compareTo(a.time));
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final list = shown;
    return Scaffold(
      appBar: AppBar(
        title: const Text('سوق', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('أضف إعلان'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person), label: 'إعلاناتي'),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: cs.primary,
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: TextField(
                    onChanged: (v) => setState(() => q = v),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن أي شيء...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (tab == 0)
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: const Text('الكل'),
                            selected: cat == null,
                            onSelected: (_) => setState(() => cat = null),
                          ),
                        ),
                        ...kCategories.entries.map((e) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                avatar: Icon(e.value, size: 18),
                                label: Text(e.key),
                                selected: cat == e.key,
                                onSelected: (_) => setState(() => cat = e.key),
                              ),
                            )),
                      ],
                    ),
                  ),
                Expanded(
                  child: list.isEmpty
                      ? const Center(
                          child: Text('لا توجد إعلانات',
                              style: TextStyle(color: Colors.grey, fontSize: 16)))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 90),
                          itemCount: list.length,
                          itemBuilder: (_, i) => _AdCard(
                            ad: list[i],
                            fav: favs.contains(list[i].id),
                            onTap: () => _open(list[i]),
                            onFav: () => _toggleFav(list[i]),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final Ad ad;
  final bool fav;
  final VoidCallback onTap, onFav;

  const _AdCard({
    required this.ad,
    required this.fav,
    required this.onTap,
    required this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [ad.color.shade300, ad.color.shade700],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Icon(kCategories[ad.category] ?? Icons.category,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      Text(ad.city,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      Text(ago(ad.time),
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    const SizedBox(height: 4),
                    Text(priceText(ad.price),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFav,
                icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                    color: fav ? Colors.red : Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsPage extends StatefulWidget {
  final Ad ad;
  final bool fav;
  const DetailsPage({super.key, required this.ad, required this.fav});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late bool fav = widget.fav;

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الإعلان'),
        actions: [
          IconButton(
            icon: Icon(fav ? Icons.favorite : Icons.favorite_border,
                color: fav ? Colors.red : null),
            onPressed: () {
              setState(() => fav = !fav);
              Navigator.pop(context, 'fav');
            },
          ),
          if (ad.mine)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف الإعلان؟'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('حذف')),
                    ],
                  ),
                );
                if (ok == true && context.mounted) Navigator.pop(context, 'delete');
              },
            ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ad.color.shade300, ad.color.shade800],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Icon(kCategories[ad.category] ?? Icons.category,
                color: Colors.white, size: 90),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ad.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(priceText(ad.price),
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cs.primary)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  Chip(
                      avatar: Icon(kCategories[ad.category], size: 16),
                      label: Text(ad.category)),
                  Chip(
                      avatar: const Icon(Icons.location_on, size: 16),
                      label: Text(ad.city)),
                  Chip(
                      avatar: const Icon(Icons.access_time, size: 16),
                      label: Text(ago(ad.time))),
                ]),
                const Divider(height: 28),
                const Text('الوصف',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(ad.desc, style: const TextStyle(height: 1.6, fontSize: 15)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50)),
                  icon: const Icon(Icons.phone),
                  label: Text('نسخ رقم المعلن: ${ad.phone}'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ad.phone));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ الرقم')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _form = GlobalKey<FormState>();
  final title = TextEditingController();
  final price = TextEditingController();
  final city = TextEditingController();
  final desc = TextEditingController();
  final phone = TextEditingController();
  String category = kCategories.keys.first;

  @override
  void dispose() {
    title.dispose();
    price.dispose();
    city.dispose();
    desc.dispose();
    phone.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    Navigator.pop(
      context,
      Ad(
        id: now.toString(),
        title: title.text.trim(),
        category: category,
        city: city.text.trim(),
        desc: desc.text.trim(),
        phone: phone.text.trim(),
        price: double.tryParse(price.text.trim()) ?? 0,
        time: now,
        mine: true,
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      );

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعلان جديد')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: title,
                validator: _req,
                decoration: _dec('عنوان الإعلان', Icons.title)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: _dec('القسم', Icons.category),
              items: kCategories.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: _dec('السعر (اتركه فارغاً للمجاني)', Icons.payments)),
            const SizedBox(height: 12),
            TextFormField(
                controller: city,
                validator: _req,
                decoration: _dec('المدينة', Icons.location_city)),
            const SizedBox(height: 12),
            TextFormField(
                controller: phone,
                validator: _req,
                keyboardType: TextInputType.phone,
                decoration: _dec('رقم التواصل', Icons.phone)),
            const SizedBox(height: 12),
            TextFormField(
                controller: desc,
                validator: _req,
                maxLines: 5,
                decoration: _dec('الوصف', Icons.description)),
            const SizedBox(height: 20),
            FilledButton.icon(
              style:
                  FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('نشر الإعلان'),
            ),
          ],
        ),
      ),
    );
  }
}name: my_app
description: A Flutter app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true