import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:safe_city/message_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;
  final FocusNode _textFieldFocus = FocusNode();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: dotenv.env['API_KEY'] ?? '',
    );
    _chatSession = _model.startChat();

    _textController.addListener(() {
      setState(() {
        // This will rebuild the widget whenever the text changes,
        // updating the send button's enabled state.
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50), // height = 50px
        child: AppBar(
          automaticallyImplyLeading: false, // prevents default back button
          backgroundColor: Color(0xFFE5FFFF),
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context); // or your custom back behavior
                  },
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png', // replace with your logo path
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
                SizedBox(width: 48), // balances the back button space
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chatSession.history.length,
                itemBuilder: (context, index) {
                  final Content content = _chatSession.history.toList()[index];
                  final text = content.parts.whereType<TextPart>().map<
                      String>((e) => e.text).join('');
                  return MessageWidget(
                      text: text, isFromUser: content.role == 'user'
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      focusNode: _textFieldFocus,
                      decoration: textFieldDecoration(),
                      controller: _textController,
                      onSubmitted: _sendChatMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
                    onPressed: _loading || _textController.text.trim().isEmpty
                        ? null
                        : () {
                      _sendChatMessage(_textController.text.trim());
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),

    );
  }

  InputDecoration textFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      hintText: 'Enter a prompt...',
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
            Radius.circular(14)
        ),
        borderSide: BorderSide(
          color: Theme
              .of(context)
              .colorScheme
              .secondary,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
        borderSide: BorderSide(
            color: Theme
                .of(context)
                .colorScheme
                .secondary
        ),
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async{
    setState(() {
      _loading = true;
    });

    try {
      final response = await _chatSession.sendMessage(
        Content.text(message),
      );
      final text = response.text;
      if (text == null) {
        _showError('No Response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          _scrollDown();
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      setState(() {
        _loading = false;
      });
      _textFieldFocus.requestFocus();
    }
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(
            milliseconds: 750,
          ),
          curve: Curves.easeOutCirc,
        ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText(message),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }
}


