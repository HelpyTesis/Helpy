import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crea un nuevo chat y retorna el chatId
  Future<String> createChat(String userId) async {
    final chatData = {
      'userId': userId,
      'fecha_inicio_chat': FieldValue.serverTimestamp(),
      'riesgo_detectado': false,
    };
    final chatRef = await _firestore.collection('Chats').add(chatData);
    return chatRef.id;
  }

  // Guarda un mensaje en la subcolección `Mensajes` dentro de un chat específico
  Future<void> saveMessage(String chatId, String text, String tipo) async {
    final bool riesgoDetectado = _detectRisk(text);

    final messageData = {
      'texto': text,
      'tipo': tipo,
      'timestamp': FieldValue.serverTimestamp(),
      'riesgo_detectado': riesgoDetectado,
    };

    await _firestore
        .collection('Chats')
        .doc(chatId)
        .collection('Mensajes')
        .add(messageData);

    if (riesgoDetectado) {
      await _firestore.collection('Chats').doc(chatId).update({
        'riesgo_detectado': true,
      });
    }
  }

  // Detección simple de palabras de riesgo
  bool _detectRisk(String message) {
    List<String> riskyWords = ['depresión', 'suicidio', 'no quiero vivir'];
    for (var word in riskyWords) {
      if (message.toLowerCase().contains(word)) {
        return true;
      }
    }
    return false;
  }

  // Obtiene el último chat de un usuario
  Future<String?> getLastChatId(String userId) async {
    final chatsSnapshot = await _firestore
        .collection('Chats')
        .where('userId', isEqualTo: userId)
        .orderBy('fecha_inicio_chat', descending: true)
        .limit(1)
        .get();

    if (chatsSnapshot.docs.isNotEmpty) {
      return chatsSnapshot.docs.first.id;
    }
    return null;
  }

  // Obtiene los mensajes de un chat específico
  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final messagesSnapshot = await _firestore
        .collection('Chats')
        .doc(chatId)
        .collection('Mensajes')
        .orderBy('timestamp')
        .get();

    return messagesSnapshot.docs.map((doc) {
      return {
        'texto': doc['texto'],
        'tipo': doc['tipo'],
        'timestamp': doc['timestamp'],
        'riesgo_detectado': doc['riesgo_detectado'] ?? false,
      };
    }).toList();
  }

  // Obtiene el historial de chats de un usuario con todos los mensajes
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    final chatsSnapshot = await _firestore
        .collection('Chats')
        .where('userId', isEqualTo: userId)
        .orderBy('fecha_inicio_chat', descending: true)
        .get();

    List<Map<String, dynamic>> chatHistory = [];

    for (final chatDoc in chatsSnapshot.docs) {
      final chatId = chatDoc.id;
      final chatData = chatDoc.data();
      final mensajesSnapshot = await _firestore
          .collection('Chats')
          .doc(chatId)
          .collection('Mensajes')
          .orderBy('timestamp')
          .get();

      List<Map<String, dynamic>> messagesList =
          mensajesSnapshot.docs.map((msgDoc) => msgDoc.data()).toList();

      chatHistory.add({
        'chatId': chatId,
        'fecha_inicio_chat': chatData['fecha_inicio_chat'],
        'riesgo_detectado': chatData['riesgo_detectado'],
        'mensajes': messagesList,
      });
    }
    return chatHistory;
  }
}
