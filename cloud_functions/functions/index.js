const functions = require("firebase-functions");

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send({ "data": "Hello from Firebase!" });
});

exports.updateGoalIntervalLengthForProject = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});

exports.getUser = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});

exports.takeABreak = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateProjectName = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateCurrentWorkingProject = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});

exports.detectPerson = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", {structuredData: true});
    response.send({ "data": "Hello from Firebase!" });
});
