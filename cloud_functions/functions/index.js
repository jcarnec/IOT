const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);


// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateGoalIntervalLengthForProject = functions.https.onCall(async (data, context) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    const id = data['id'];
    const projectIndex = data['selectedProjectNumber'];
    const hour = data['hours'];
    const minutes = data['minutes'];

    const inSeconds = (hour * 60 * 60) + (minutes * 60);

    const projectsRef = admin.database().ref('users/' + id + '/projects');
    projectsRef.child(projectIndex).update({'goalIntervalLengthInSeconds': inSeconds});

    return 'Successfully changed interval goal';
});

exports.getUser = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello"});
});

exports.takeABreak = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateProjectName = functions.https.onCall(async (data, context) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    
    const id = data['id'];
    const projectIndex = data['selectedProjectNumber'];
    const name = data['name'];

    changeName(id, projectIndex, name);
    return 'Successfully changed name';
});

function changeName(id, projectIndex, name) {
    const projectsRef = admin.database().ref('users/' + id + '/projects');
    projectsRef.child(projectIndex).update({'name': name});
}

exports.updateCurrentWorkingProject = functions.https.onCall(async (data, context) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    functions.logger.info(data.text, { structuredData: true });

    
    const id = data['id'];
    const projectIndex = data['selectedProjectNumber'];
    changeProject(id, projectIndex);
    return `Successfully changed project: ${projectIndex}`;
});

function changeProject(id, projectIndex) {
    const user = admin.database().ref('users/' + id);
    user.update({'selectedProjectNumber':projectIndex});
}

exports.detectPerson = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});
