import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createUser({
    required String userId,
    required String fullName,
    required String email,
    required String passwordController,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: passwordController,
      );

      await _db.collection('users').doc(userId).set({
        'fullName': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await userCredential.user!.updateDisplayName(fullName);
    } on FirebaseAuthException catch (e) {
      print("Error creating user: ${e.message}");
    }
  }

  Future<void> addSymptomLog(String userId, Map<String, dynamic> logData, bool geneticsController) async {
    await _db.collection('symptom_logs').add({
      ...logData,
      'userId': userId,
      'geneticsController': geneticsController,
    });
  }

  Future<void> addHealthLog(String userId, Map<String, dynamic> healthData) async {
    await _db.collection('health_logs').add({
      ...healthData,
      'userId': userId,
      'weightControllerValue': healthData['weightControllerValue'],
      'weightControllerUnit': healthData['weightControllerUnit'],
      'heightControllerValue': healthData['heightControllerValue'],
      'heightControllerUnit': healthData['heightControllerUnit'],
      'bloodPressureSystolicControllerValue': healthData['bloodPressureSystolicControllerValue'],
      'bloodPressureSystolicControllerUnit': healthData['bloodPressureSystolicControllerUnit'],
      'bloodPressureDiastolicControllerValue': healthData['bloodPressureDiastolicControllerValue'],
      'bloodPressureDiastolicControllerUnit': healthData['bloodPressureDiastolicControllerUnit'],
      'heartRateControllerValue': healthData['heartRateControllerValue'],
      'heartRateControllerUnit': healthData['heartRateControllerUnit'],
      'bloodSugarControllerValue': healthData['bloodSugarControllerValue'],
      'bloodSugarControllerUnit': healthData['bloodSugarControllerUnit'],
    });
  }

  Future<void> addBloodworkRecord(
    String userId,
    Map<String, dynamic> bloodworkData,
    List<Map<String, dynamic>> testResults,
  ) async {
    final recordRef = await _db.collection('bloodwork_records').add({
      ...bloodworkData,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (var result in testResults) {
      await recordRef.collection('test_results').add(result);
    }
  }

  Future<void> addAIAnalysis(String userId, Map<String, dynamic> analysisData) async {
    await _db.collection('ai_analyses').add({
      'userId': userId,
      'analysisDetails': analysisData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addTestDefinition(String testId, Map<String, dynamic> testDef) async {
    await _db.collection('test_definitions').doc(testId).set(testDef);
  }

  Future<void> addMedicationReminder(String userId, Map<String, dynamic> reminder) async {
    await _db.collection('medication_reminders').add({
      ...reminder,
      'userId': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getSymptomLogs(String userId) async {
    final querySnapshot = await _db
        .collection('symptom_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('logDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getHealthLogs(String userId) async {
    final querySnapshot = await _db
        .collection('health_logs')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getBloodworkRecords(String userId) async {
    final querySnapshot = await _db
        .collection('bloodwork_records')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> records = [];
    for (var doc in querySnapshot.docs) {
      final record = doc.data();
      final testsSnapshot = await doc.reference.collection('test_results').get();
      record['testResults'] =
          testsSnapshot.docs.map((d) => d.data()).toList();
      records.add(record);
    }
    return records;
  }

  Future<List<Map<String, dynamic>>> getAIAnalysis(String userId) async {
    final querySnapshot = await _db
        .collection('ai_analyses')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTestDefinitions() async {
    final querySnapshot = await _db.collection('test_definitions').get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMedicationReminders(String userId) async {
    final querySnapshot = await _db
        .collection('medication_reminders')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
  Future<Map<String, dynamic>?> loginUser({
  required String email,
  required String password,
}) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;

    if (user != null) {
              print('Firestore Success wallah.');
      final userDoc = await _db.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final token = await user.getIdToken(true);

        return {
          'email': user.email,
        };
      } else {
        print('Firestore document does not exist for user.');
        return null;
      }
    }
  } on FirebaseAuthException catch (e) {
    print('Login error: ${e.message}');
    return null;
  } catch (e) {
    print('Unexpected login error: $e');
    return null;
  }

  return null;
}

}
