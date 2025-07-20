import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/contact.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// Contrôleurs globaux pour les préférences
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController(ThemeMode value) : super(value);
}

class ColorController extends ValueNotifier<Color> {
  ColorController(Color value) : super(value);
}

class FontSizeController extends ValueNotifier<double> {
  FontSizeController(double value) : super(value);
}

final themeController = ThemeController(ThemeMode.system);
final colorController = ColorController(const Color(0xFFFFD700)); // Doré par défaut
final fontSizeController = FontSizeController(14.0); // Taille par défaut

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _secureStorage = FlutterSecureStorage();
  bool _isLockEnabled = false;
  Color _primaryColor = const Color(0xFFFFD700); // Doré par défaut
  double _fontSize = 14.0; // Taille par défaut

  @override
  void initState() {
    super.initState();
    _loadLockStatus();
    _loadPreferences();
  }

  Future<void> _loadLockStatus() async {
    final pin = await _secureStorage.read(key: 'app_pin');
    setState(() {
      _isLockEnabled = pin != null;
    });
  }

  Future<void> _toggleLock(bool value) async {
    if (value) {
      // Activer le verrouillage
      final pin = await _showPinDialog();
      if (pin != null) {
        await _secureStorage.write(key: 'app_pin', value: pin);
        setState(() {
          _isLockEnabled = true;
        });
      }
    } else {
      // Désactiver le verrouillage
      await _secureStorage.delete(key: 'app_pin');
      setState(() {
        _isLockEnabled = false;
      });
    }
  }

  Future<String?> _showPinDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Définir le code PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Code PIN (4 chiffres)',
            hintText: '1234',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt('primary_color') ?? 0xFFFFD700;
    final fontSize = prefs.getDouble('font_size') ?? 14.0;
    setState(() {
      _primaryColor = Color(colorValue);
      _fontSize = fontSize;
    });
    // Mettre à jour les contrôleurs globaux
    colorController.value = Color(colorValue);
    fontSizeController.value = fontSize;
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', _primaryColor.value);
    await prefs.setDouble('font_size', _fontSize);
  }

  Future<void> _showColorPicker() async {
    final colors = [
      const Color(0xFFFFD700), // Doré
      const Color(0xFF2196F3), // Bleu
      const Color(0xFF4CAF50), // Vert
      const Color(0xFFFF5722), // Orange
      const Color(0xFF9C27B0), // Violet
      const Color(0xFF607D8B), // Gris
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la couleur principale'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _primaryColor = color;
                  });
                  _savePreferences();
                  colorController.value = color; // Appliquer immédiatement
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _primaryColor == color ? Colors.black : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showFontSizePicker() async {
    final sizes = [12.0, 14.0, 16.0, 18.0, 20.0];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la taille de police'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((size) => RadioListTile<double>(
            value: size,
            groupValue: _fontSize,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _fontSize = value;
                });
                _savePreferences();
                fontSizeController.value = value; // Appliquer immédiatement
                Navigator.pop(context);
              }
            },
            title: Text('Taille ${size.toInt()}', style: TextStyle(fontSize: size)),
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'carnellthon0@gmail.com',
      query: 'subject=Support Scan & Save App&body=Bonjour, j\'ai besoin d\'aide avec l\'application Scan & Save...',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir l\'email')),
        );
      }
    }
  }

  Future<void> _launchGitHub() async {
    final Uri githubUri = Uri.parse('https://github.com/carnell0');
    if (await canLaunchUrl(githubUri)) {
      await launchUrl(githubUri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir GitHub')),
        );
      }
    }
  }

  // Future<void> _rateApp() async {
  //   // Pour Android, on ouvre le Play Store
  //   final Uri playStoreUri = Uri.parse('market://details?id=com.example.ocr_qr_scanner');
  //   final Uri playStoreWebUri = Uri.parse('https://play.google.com/store/apps/details?id=com.example.ocr_qr_scanner');
  //   
  //   try {
  //     if (await canLaunchUrl(playStoreUri)) {
  //       await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
  //     } else if (await canLaunchUrl(playStoreWebUri)) {
  //       await launchUrl(playStoreWebUri, mode: LaunchMode.externalApplication);
  //     } else {
  //       if (context.mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Impossible d\'ouvrir le Play Store')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     if (context.mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Erreur lors de l\'ouverture du Play Store')),
  //       );
  //     }
  //   }
  // }

  // Future<void> _showFeedbackDialog() async {
  //   final controller = TextEditingController();
  //   return showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Envoyer un feedback'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const Text('Partagez vos suggestions ou signalez un problème :'),
  //           const SizedBox(height: 16),
  //           TextField(
  //             controller: controller,
  //             maxLines: 4,
  //             decoration: const InputDecoration(
  //               hintText: 'Votre message...',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Annuler'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (controller.text.trim().isNotEmpty) {
  //               final Uri emailUri = Uri(
  //                 scheme: 'mailto',
  //                 path: 'carnellthon0@gmail.com',
  //                 query: 'subject=Feedback Scan & Save App&body=${Uri.encodeComponent(controller.text)}',
  //               );
  //               if (await canLaunchUrl(emailUri)) {
  //                 await launchUrl(emailUri);
  //                 Navigator.pop(context);
  //               }
  //             }
  //           },
  //           child: const Text('Envoyer'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _showFAQ() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Questions fréquentes'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FAQItem(
                question: 'Comment scanner une carte de visite ?',
                answer: 'Allez dans l\'onglet Scanner, puis appuyez sur "Scanner carte". Pointez la caméra vers la carte de visite.',
              ),
              _FAQItem(
                question: 'Comment importer des contacts ?',
                answer: 'Dans Paramètres > Gestion des données > Importer contacts. Sélectionnez un fichier JSON.',
              ),
              _FAQItem(
                question: 'Comment activer le verrouillage ?',
                answer: 'Dans Paramètres > Sécurité, activez "Verrouillage par code" et définissez un PIN.',
              ),
              _FAQItem(
                question: 'Comment changer la couleur ?',
                answer: 'Dans Paramètres > Personnalisation > Couleur principale, choisissez votre couleur préférée.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Thème'),
          _ThemeSelector(),
          const SizedBox(height: 16),
          _SectionTitle('Gestion des données'),
          ListTile(
            leading: Icon(Icons.upload_file, color: color),
            title: const Text('Exporter contacts'),
            onTap: () async {
              try {
                final box = Hive.box('contacts');
                final contacts = box.values.toList();
                final jsonList = contacts.map((c) => {
                  'name': c.name,
                  'phone': c.phone,
                  'email': c.email,
                  'company': c.company,
                }).toList();
                final jsonString = jsonEncode(jsonList);
                final dir = await getApplicationDocumentsDirectory();
                final file = File('${dir.path}/contacts_export.json');
                await file.writeAsString(jsonString);
                await Share.shareXFiles([XFile(file.path)], text: 'Voici mes contacts exportés.');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exportation réussie !')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur export : $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.download, color: color),
            title: const Text('Importer contacts'),
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                if (result == null || result.files.isEmpty) return;
                final file = File(result.files.single.path!);
                final content = await file.readAsString();
                final List<dynamic> jsonList = jsonDecode(content);
                final box = Hive.box('contacts');
                int added = 0;
                for (final item in jsonList) {
                  final name = item['name'] ?? '';
                  final phone = item['phone'] ?? '';
                  final email = item['email'] ?? '';
                  final company = item['company'] ?? '';
                  final duplicate = box.values.any((c) =>
                    (c.email.isNotEmpty && c.email == email) ||
                    (c.phone.isNotEmpty && c.phone == phone)
                  );
                  if (!duplicate) {
                    await box.add(
                      Contact(name: name, phone: phone, email: email, company: company),
                    );
                    added++;
                  }
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$added contacts importés.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur import : $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: color),
            title: const Text('Vider la base'),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Vider la base'),
                  content: const Text('Voulez-vous vraiment supprimer tous les contacts ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Vider'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                final box = Hive.box('contacts');
                await box.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tous les contacts ont été supprimés.')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _SectionTitle('Sécurité'),
          SwitchListTile(
            title: const Text('Verrouillage par code'),
            subtitle: const Text('Protéger l\'accès à l\'application'),
            value: _isLockEnabled,
            onChanged: _toggleLock,
          ),
          const SizedBox(height: 16),
          _SectionTitle('Personnalisation'),
          ListTile(
            leading: Icon(Icons.color_lens, color: color),
            title: const Text('Couleur principale'),
            subtitle: Text('Couleur actuelle'),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            onTap: _showColorPicker,
          ),
          ListTile(
            leading: Icon(Icons.format_size, color: color),
            title: const Text('Taille de police'),
            subtitle: Text('Taille actuelle : ${_fontSize.toInt()}'),
            onTap: _showFontSizePicker,
          ),
          const SizedBox(height: 16),
          _SectionTitle('À propos'),
          ListTile(
            leading: Icon(Icons.info, color: color),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.support_agent, color: color),
            title: const Text('Support'),
            subtitle: const Text('carnellthon0@gmail.com'),
            onTap: _launchEmail,
          ),
          ListTile(
            leading: Icon(Icons.link, color: color),
            title: const Text('GitHub'),
            subtitle: const Text('github.com/carnell0'),
            onTap: _launchGitHub,
          ),
          const SizedBox(height: 16),
          // _SectionTitle('Aide'),
          // ListTile(
          //   leading: Icon(Icons.help_outline, color: color),
          //   title: const Text('FAQ'),
          //   onTap: _showFAQ,
          // ),
          // ListTile(
          //   leading: Icon(Icons.feedback, color: color),
          //   title: const Text('Envoyer un feedback'),
          //   onTap: () {}, // _showFeedbackDialog, // Moved to comment
          // ),
          // ListTile(
          //   leading: Icon(Icons.star_rate, color: color),
          //   title: const Text('Noter l\'app'),
          //   onTap: _rateApp,
          // ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return Column(
          children: [
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: mode,
              onChanged: (val) async {
                themeController.value = val!;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_mode', 'system');
              },
              title: const Text('Système'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: mode,
              onChanged: (val) async {
                themeController.value = val!;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_mode', 'light');
              },
              title: const Text('Clair'),
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: mode,
              onChanged: (val) async {
                themeController.value = val!;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_mode', 'dark');
              },
              title: const Text('Sombre'),
            ),
          ],
        );
      },
    );
  }
}

class _FAQItem extends StatelessWidget {
  final String question;
  final String answer;
  
  const _FAQItem({required this.question, required this.answer});
  
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }
} 