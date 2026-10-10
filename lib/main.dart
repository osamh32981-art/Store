import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(StoreApp(prefs: prefs));
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.color,
    required this.description,
    this.rating = 4.8,
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final Color color;
  final String description;
  final double rating;
}

const products = <Product>[
  Product(
    id: 1,
    name: 'حقيبة يومية عملية',
    category: 'إكسسوارات',
    price: 189,
    color: Color(0xFFB8D8D8),
    description: 'حقيبة أنيقة بخامات متينة ومساحة مناسبة للاستخدام اليومي.',
  ),
  Product(
    id: 2,
    name: 'سماعات لاسلكية',
    category: 'إلكترونيات',
    price: 249,
    color: Color(0xFFD9C2FF),
    description: 'صوت واضح وتصميم مريح مع بطارية تدوم طوال اليوم.',
  ),
  Product(
    id: 3,
    name: 'كوب حراري أنيق',
    category: 'المنزل',
    price: 79,
    color: Color(0xFFFFD7A8),
    description: 'يحافظ على حرارة مشروبك بتصميم بسيط مناسب للمكتب والسفر.',
  ),
  Product(
    id: 4,
    name: 'حذاء رياضي خفيف',
    category: 'أزياء',
    price: 329,
    color: Color(0xFFAED4FF),
    description: 'راحة وخفة للحركة اليومية والتمارين الخفيفة.',
  ),
  Product(
    id: 5,
    name: 'مصباح مكتب ذكي',
    category: 'المنزل',
    price: 159,
    color: Color(0xFFFFB6C1),
    description: 'إضاءة عملية بثلاثة مستويات لتجربة عمل أكثر راحة.',
  ),
  Product(
    id: 6,
    name: 'ساعة كلاسيكية',
    category: 'إكسسوارات',
    price: 299,
    color: Color(0xFFD2E5B5),
    description: 'تصميم كلاسيكي يضيف لمسة راقية إلى إطلالتك.',
  ),
];

class StoreApp extends StatefulWidget {
  const StoreApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<StoreApp> createState() => _StoreAppState();
}

class _StoreAppState extends State<StoreApp> {
  bool dark = false;
  final cart = <int, int>{};
  final favorites = <int>{};

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Store',
        theme: StoreTheme.light,
        darkTheme: StoreTheme.dark,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: StoreHome(
          cart: cart,
          favorites: favorites,
          onChanged: () => setState(() {}),
          onTheme: () => setState(() => dark = !dark),
        ),
      );
}

class StoreHome extends StatefulWidget {
  const StoreHome({
    super.key,
    required this.cart,
    required this.favorites,
    required this.onChanged,
    required this.onTheme,
  });

  final Map<int, int> cart;
  final Set<int> favorites;
  final VoidCallback onChanged;
  final VoidCallback onTheme;

  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  int tab = 0;
  String query = '';
  String category = 'الكل';

  final categories = const [
    'الكل',
    'إلكترونيات',
    'أزياء',
    'المنزل',
    'إكسسوارات',
  ];

  List<Product> get filtered => products
      .where((p) =>
          (category == 'الكل' || p.category == category) &&
          (query.isEmpty ||
              p.name.contains(query) ||
              p.category.contains(query)))
      .toList();

  int get cartCount => widget.cart.values.fold(0, (a, b) => a + b);

  double get total => widget.cart.entries.fold(
        0,
        (sum, e) =>
            sum +
            products.firstWhere((p) => p.id == e.key).price * e.value,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'سوقك',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
          ),
          actions: [
            IconButton(
              onPressed: widget.onTheme,
              icon: const Icon(Icons.brightness_6_outlined),
            ),
            Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  onPressed: () => _openCart(),
                  icon: const Icon(Icons.shopping_bag_outlined),
                ),
                if (cartCount > 0)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: StoreTheme.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: IndexedStack(
          index: tab,
          children: [_home(), _favorites(), _cartPage(), _profile()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (v) => setState(() => tab = v),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'المفضلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'السلة',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'حسابي',
            ),
          ],
        ),
      );

  Widget _home() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _banner(),
          const SizedBox(height: 18),
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'ابحث عن منتج أو قسم',
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: category == c,
                        onSelected: (_) => setState(() => category = c),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'اختيارات مميزة',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                '${filtered.length} منتجات',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .70,
            ),
            itemBuilder: (_, i) => _productCard(filtered[i]),
          ),
        ],
      );

  Widget _banner() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: StoreTheme.ink,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اكتشف ما يناسبك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'منتجات مختارة لتجعل يومك أسهل وأجمل',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() => category = 'الكل'),
                    style: FilledButton.styleFrom(
                      backgroundColor: StoreTheme.orange,
                    ),
                    child: const Text('تصفح المنتجات'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.shopping_bag_outlined,
              color: StoreTheme.orange,
              size: 70,
            ),
          ],
        ),
      );

  Widget _productCard(Product p) => GestureDetector(
        onTap: () => _details(p),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: p.color,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 62,
                            color: Colors.black38,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: () {
                              if (widget.favorites.contains(p.id)) {
                                widget.favorites.remove(p.id);
                              } else {
                                widget.favorites.add(p.id);
                              }
                              widget.onChanged();
                            },
                            icon: Icon(
                              widget.favorites.contains(p.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.favorites.contains(p.id)
                                  ? Colors.red
                                  : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  p.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${p.price.toStringAsFixed(0)} ر.س',
                      style: const TextStyle(
                        color: StoreTheme.orange,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.cart[p.id] = (widget.cart[p.id] ?? 0) + 1;
                        widget.onChanged();
                      },
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: StoreTheme.ink,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _favorites() {
    final items =
        products.where((p) => widget.favorites.contains(p.id)).toList();
    if (items.isEmpty) {
      return const Center(child: Text('لم تضف منتجات إلى المفضلة بعد'));
    }
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'المفضلة',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .70,
          ),
          itemBuilder: (_, i) => _productCard(items[i]),
        ),
      ],
    );
  }

  Widget _cartPage() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
        children: [
          Text(
            'سلة التسوق',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          if (widget.cart.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('السلة فارغة')),
            )
          else
            ...widget.cart.entries.map((entry) {
              final p = products.firstWhere((x) => x.id == entry.key);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.color,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.black54,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${p.price.toStringAsFixed(0)} ر.س'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (entry.value <= 1) {
                            widget.cart.remove(p.id);
                          } else {
                            widget.cart[p.id] = entry.value - 1;
                          }
                          widget.onChanged();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('${entry.value}'),
                      IconButton(
                        onPressed: () {
                          widget.cart[p.id] = entry.value + 1;
                          widget.onChanged();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (widget.cart.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${total.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            fontSize: 20,
                            color: StoreTheme.orange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _checkout,
                        child: const Text('إتمام الطلب'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _profile() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'حسابي',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person_outline)),
                  title: Text('زائر المتجر'),
                  subtitle: Text('سجل دخولك لمتابعة طلباتك'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.local_shipping_outlined),
                  title: Text('تتبع الطلبات'),
                ),
                ListTile(
                  leading: Icon(Icons.support_agent_outlined),
                  title: Text('مركز المساعدة'),
                ),
              ],
            ),
          ),
        ],
      );

  void _openCart() => setState(() => tab = 2);

  Future<void> _details(Product p) async => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: p.color,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 84,
                    color: Colors.black38,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                p.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                p.description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${p.price.toStringAsFixed(0)} ر.س',
                    style: const TextStyle(
                      fontSize: 21,
                      color: StoreTheme.orange,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      widget.cart[p.id] = (widget.cart[p.id] ?? 0) + 1;
                      widget.onChanged();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('أضف للسلة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void _checkout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الطلب'),
        content: Text(
          'إجمالي الطلب ${total.toStringAsFixed(0)} ر.س. هذه نسخة تجريبية محلية.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              widget.cart.clear();
              widget.onChanged();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء الطلب التجريبي')),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}