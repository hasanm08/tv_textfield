import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tv_textfield/tv_textfield.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeTvTextField();
  runApp(const TvTextFieldDemoApp());
}

class TvTextFieldDemoApp extends StatelessWidget {
  const TvTextFieldDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV TextField Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const TvTextFieldScope(
        child: TvTextFieldDemoPage(),
      ),
    );
  }
}

class TvTextFieldDemoPage extends StatefulWidget {
  const TvTextFieldDemoPage({super.key});

  @override
  State<TvTextFieldDemoPage> createState() => _TvTextFieldDemoPageState();
}

class _TvTextFieldDemoPageState extends State<TvTextFieldDemoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'user@example.com');
  final _searchController = TextEditingController();

  final _nameFocus = FocusNode(debugLabel: 'name');
  final _emailFocus = FocusNode(debugLabel: 'email');
  final _searchFocus = FocusNode(debugLabel: 'search');

  String _lastSubmitted = '';

  static final _focusDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.lightBlueAccent, width: 3),
    boxShadow: const [
      BoxShadow(
        color: Colors.lightBlueAccent,
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final platform = TvTextFieldPlatform.info;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TV TextField'),
      ),
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Remote-friendly text fields',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Works on Android TV, Apple TV, iOS, desktop, and web.\n'
              'D-pad / Siri Remote: move focus • Select: edit • Back / Menu: dismiss',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            if (platform.isTelevision)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  platform.isTvOS
                      ? 'Running on Apple TV (tvOS)'
                      : 'Running on Android TV',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            const SizedBox(height: 32),
            TvTextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Press Select to type',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              focusDecoration: _focusDecoration,
              onSubmitted: (_) => _emailFocus.requestFocus(),
            ),
            const SizedBox(height: 24),
            TvTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              focusDecoration: _focusDecoration,
              onSubmitted: (_) => _searchFocus.requestFocus(),
            ),
            const SizedBox(height: 24),
            TvTextField(
              controller: _searchController,
              focusNode: _searchFocus,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              focusDecoration: _focusDecoration,
              onSubmitted: (value) {
                setState(() => _lastSubmitted = value);
              },
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () => _nameFocus.requestFocus(),
                  child: const Text('Focus name'),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
                  },
                  child: const Text('Unfocus all'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_lastSubmitted.isNotEmpty)
              Text('Last search: $_lastSubmitted'),
          ],
        ),
      ),
    );
  }
}
