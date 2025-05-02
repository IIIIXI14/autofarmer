const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Constants for alert thresholds
const THRESHOLDS = {
  moistureLow: 30.0,
  tempHigh: 40.0,
  tempLow: 10.0,
  humidityLow: 20.0
};

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

// Check sensor readings and send notifications
exports.checkSensorAlerts = functions.firestore
  .document('sensors/{deviceId}/readings/{readingId}')
  .onCreate(async (snap, context) => {
    const reading = snap.data();
    const deviceId = context.params.deviceId;
    const alerts = [];

    // Check each threshold
    if (reading.soilMoisture < THRESHOLDS.moistureLow) {
      alerts.push({
        title: '⚠️ Low Soil Moisture Alert',
        body: `Soil moisture is ${reading.soilMoisture.toFixed(1)}% (below ${THRESHOLDS.moistureLow}%)`,
        severity: 'warning'
      });
    }

    if (reading.temperature > THRESHOLDS.tempHigh) {
      alerts.push({
        title: '🔥 High Temperature Alert',
        body: `Temperature is ${reading.temperature.toFixed(1)}°C (above ${THRESHOLDS.tempHigh}°C)`,
        severity: 'critical'
      });
    }

    if (reading.temperature < THRESHOLDS.tempLow) {
      alerts.push({
        title: '❄️ Low Temperature Alert',
        body: `Temperature is ${reading.temperature.toFixed(1)}°C (below ${THRESHOLDS.tempLow}°C)`,
        severity: 'warning'
      });
    }

    if (reading.humidity < THRESHOLDS.humidityLow) {
      alerts.push({
        title: '💧 Low Humidity Alert',
        body: `Humidity is ${reading.humidity.toFixed(1)}% (below ${THRESHOLDS.humidityLow}%)`,
        severity: 'warning'
      });
    }

    // If there are alerts, send notifications and log them
    if (alerts.length > 0) {
      try {
        // Get device owner's FCM token
        const deviceDoc = await admin.firestore()
          .collection('devices')
          .doc(deviceId)
          .get();
        
        const ownerUid = deviceDoc.data()?.ownerUid;
        
        if (ownerUid) {
          const userDoc = await admin.firestore()
            .collection('users')
            .doc(ownerUid)
            .get();
          
          const fcmToken = userDoc.data()?.fcmToken;

          // Send notifications for each alert
          for (const alert of alerts) {
            // Log alert to Firestore
            await admin.firestore()
              .collection('devices')
              .doc(deviceId)
              .collection('alerts')
              .add({
                ...alert,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                readingId: snap.id
              });

            // Send FCM notification if token exists
            if (fcmToken) {
              await admin.messaging().send({
                token: fcmToken,
                notification: {
                  title: alert.title,
                  body: alert.body
                },
                data: {
                  deviceId,
                  severity: alert.severity,
                  timestamp: new Date().toISOString()
                }
              });
            }

            // Also send to a topic that anyone can subscribe to
            await admin.messaging().send({
              topic: `device_${deviceId}_alerts`,
              notification: {
                title: alert.title,
                body: alert.body
              },
              data: {
                deviceId,
                severity: alert.severity,
                timestamp: new Date().toISOString()
              }
            });
          }
        }
      } catch (error) {
        console.error('Error sending notifications:', error);
      }
    }
  });

// Store FCM token when user updates it
exports.storeFCMToken = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be logged in');
  }

  const { fcmToken } = data;
  if (!fcmToken) {
    throw new functions.https.HttpsError('invalid-argument', 'FCM token is required');
  }

  await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .update({
      fcmToken: fcmToken,
      fcmTokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

  return { success: true };
}); 