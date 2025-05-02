const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Sync Firestore device states to Realtime Database for ESP8266
exports.syncDeviceToRealtimeDB = functions.firestore
  .document('users/{userId}/devices/{deviceId}')
  .onWrite((change, context) => {
    const afterData = change.after.exists ? change.after.data() : null;
    const { userId, deviceId } = context.params;

    if (!afterData) {
      // Document was deleted, remove from Realtime DB
      return admin.database().ref(`devices/${userId}/${deviceId}`).remove();
    }

    // Extract only the actuator states we need for ESP8266
    const actuatorStates = {
      pump: afterData.pump || false,
      light: afterData.light || false,
      siren: afterData.siren || false,
      autoMode: afterData.autoMode || false,
      lastUpdate: admin.database.ServerValue.TIMESTAMP
    };

    // Update Realtime Database
    return admin.database().ref(`devices/${userId}/${deviceId}`).update(actuatorStates);
  });

// Sync sensor data from ESP8266 (Realtime DB) back to Firestore
exports.syncSensorDataToFirestore = functions.database
  .ref('/devices/{userId}/{deviceId}/sensors')
  .onWrite(async (change, context) => {
    const { userId, deviceId } = context.params;
    const sensorData = change.after.val();

    if (!sensorData) return null;

    // Update Firestore with sensor data
    return admin.firestore()
      .collection('users')
      .doc(userId)
      .collection('devices')
      .doc(deviceId)
      .update({
        'sensors': sensorData,
        'lastSensorUpdate': admin.firestore.FieldValue.serverTimestamp()
      });
  }); 