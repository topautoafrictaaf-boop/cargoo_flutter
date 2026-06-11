import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const CargooApp());
}

class CargooApp extends StatelessWidget {
  const CargooApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cargoo',
      theme: ThemeData(
        primaryColor: const Color(0xFF1B3A5C),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _menuVisible = false;
  bool _notifDropdownVisible = false;
  int _unreadNotifications = 3;
  int _cartCount = 2;

  final String _firstName = 'Katherine';
  final String _email = 'katherine@example.com';

  final List<Map<String, String>> _drawerMenuItems = [
    {'label': 'Mon compte', 'emoji': '👤'},
    {'label': 'Mes véhicules', 'emoji': '🚗'},
    {'label': 'Mes pièces auto', 'emoji': '🧩'},
    {'label': 'Mes commandes', 'emoji': '🧾'},
    {'label': 'Dépannage', 'emoji': '🚨'},
    {'label': 'SAV / Assistance', 'emoji': '🛠️'},
    {'label': 'Appel Service Commercial', 'emoji': '📞'},
  ];

  final List<Map<String, String>> _categories = [
    {'name': 'Pneus', 'emoji': '🔧'},
    {'name': 'Pièces intérieur', 'emoji': '🛞'},
    {'name': 'Filtres et huile', 'emoji': '⚙️'},
    {'name': 'Freinage', 'emoji': '🔩'},
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Commande confirmée',
      'message': 'Votre commande #12345 a été confirmée',
      'time': 'Il y a 2 min',
      'isRead': false,
    },
    {
      'title': 'Livraison en cours',
      'message': 'Votre colis est en cours de livraison',
      'time': 'Il y a 1h',
      'isRead': false,
    },
    {
      'title': 'Promo spéciale',
      'message': '50% sur les pneus cette semaine!',
      'time': 'Il y a 3h',
      'isRead': true,
    },
  ];

  void _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/2250141413937');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGreeting(),
                      _buildVehicleCard(),
                      _buildNoticeCard(),
                      _buildCategories(),
                      _buildMadouCTA(),
                      _buildWhySection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_menuVisible)
            GestureDetector(
              onTap: () => setState(() => _menuVisible = false),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: GestureDetector(
                  onTap: () {},
                  child: _buildDrawerMenu(),
                ),
              ),
            ),
          if (_notifDropdownVisible)
            GestureDetector(
              onTap: () => setState(() => _notifDropdownVisible = false),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Align(
                  alignment: Alignment.topRight,
                  child: _buildNotificationsDropdown(),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsApp,
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _menuVisible = !_menuVisible),
            child: const Icon(Icons.menu, size: 24, color: Color(0xFF1A1A1A)),
          ),
          Image.asset(
            'assets/images/logocargo.png',
            height: 52,
            width: 180,
            fit: BoxFit.contain,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _notifDropdownVisible = !_notifDropdownVisible),
                child: Stack(
                  children: [
                    const Icon(Icons.notifications_none, size: 22, color: Color(0xFF1A1A1A)),
                    if (_unreadNotifications > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            _unreadNotifications.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Stack(
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 24, color: Color(0xFF1A1A1A)),
                  if (_cartCount > 0)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B00),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        child: Text(
                          _cartCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour $_firstName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Trouvez uniquement les pièces ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                TextSpan(
                  text: 'compatibles',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFFF6B00),
                    decoration: TextDecoration.underline,
                  ),
                ),
                TextSpan(
                  text: ' avec votre véhicule',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A5C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Véhicule principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'HYUNDAI TUCSON',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2022 • Essence • 2.5L',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBFBFBF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_bag, size: 16),
                  label: const Text('Pièces'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B00)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.build, size: 16, color: Color(0xFFFF6B00)),
                  label: const Text(
                    'Entretien',
                    style: TextStyle(color: Color(0xFFFF6B00)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {},
              child: const Text(
                'Mes Véhicules',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock, color: Color(0xFF1A1A1A), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Affichage personnalisé',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seules les pièces compatibles avec votre véhicule sont affichées',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final emoji = cat['emoji'] ?? '🔧';
                final name = cat['name'] ?? 'Catégorie';
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 72,
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMadouCTA() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A5C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Assistance Mécano',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ptit Madou',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Posez vos questions sur l\'entretien, les pannes ou les pièces.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFFBFBFBF),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.build,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B00),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {},
              child: const Text('Discuter avec Ptit Madou'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Pourquoi choisir CarGoo ?',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWhyItem('✓', 'Pièces 100%\ncompatibles'),
              _buildWhyItem('✓', 'Qualité\ngarantie'),
              _buildWhyItem('✓', 'Livraison\nrapide'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyItem(String icon, String text) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFF3E8),
          ),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFFF6B00),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerMenu() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 280,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _menuVisible = false),
                    child: const Text(
                      '✕',
                      style: TextStyle(fontSize: 28, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ..._drawerMenuItems.map((item) {
                    return _buildDrawerMenuItem(
                      item['emoji'] ?? '📌',
                      item['label'] ?? 'Menu',
                      false,
                    );
                  }).toList(),
                  Divider(color: Colors.grey[300], height: 16),
                  _buildDrawerMenuItem('🚪', 'Déconnexion', false, isLogout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerMenuItem(
    String emoji,
    String label,
    bool disabled, {
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: disabled ? null : () => setState(() => _menuVisible = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isLogout ? FontWeight.w600 : FontWeight.w500,
                  color: isLogout
                      ? const Color(0xFFFF6B00)
                      : (disabled ? Colors.grey : const Color(0xFF333333)),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: disabled ? Colors.grey : Colors.grey[600],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsDropdown() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 100, 16, 0),
      constraints: const BoxConstraints(maxWidth: 380, maxHeight: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                if (_unreadNotifications > 0)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _unreadNotifications = 0;
                        for (var notif in _notifications) {
                          notif['isRead'] = true;
                        }
                      });
                    },
                    child: const Text(
                      'Tout lire',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: Colors.grey[300], height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => Divider(color: Colors.grey[300], height: 1),
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      notif['isRead'] = true;
                      if (_unreadNotifications > 0) _unreadNotifications--;
                    });
                  },
                  child: Container(
                    color: notif['isRead'] == true
                        ? Colors.white
                        : const Color(0xFFFFF9F4),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: notif['isRead'] == true
                                ? Colors.grey[200]!
                                : const Color(0xFFFFF3E8),
                          ),
                          child: const SizedBox(
                            width: 34,
                            height: 34,
                            child: Icon(
                              Icons.shopping_bag,
                              size: 18,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif['title'] ?? 'Notification',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: notif['isRead'] == true
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: const Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                notif['message'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif['time'] ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (notif['isRead'] == false)
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF6B00),
                            ),
                            margin: const EdgeInsets.only(top: 5, left: 8),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(color: Colors.grey[300], height: 1),
          GestureDetector(
            onTap: () => setState(() => _notifDropdownVisible = false),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Voir toutes les notifications',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B00),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}