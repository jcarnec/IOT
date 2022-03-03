const functions = require("firebase-functions");

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

exports.helloWorld = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateGoalIntervalLengthForProject = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.getUser = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": { 
        'isWorking': true,
        'id': 1, 
        'projects': [
            { 
                'name': 'College', 
                'intervals': [
                    { 
                        'startTimeStamp': '2022-03-03T08:33:28.263717', 
                        'endTimeStamp': '2022-03-03 10:33:28.264650' 
                    }, 
                    { 
                        'startTimeStamp': '2022-03-03T11:33:28.264758', 
                        'endTimeStamp': '2022-03-03 16:33:28.264770' 
                    }, 
                    { 
                        'startTimeStamp': '2022-03-03T17:33:28.264777', 
                        'endTimeStamp': '2022-03-03T18:33:28.264777'
                    }
                ], 
                'goalIntervalLengthInSeconds': 500 
            }, 
            { 
                'name': 'IoT', 
                'intervals': [
                    { 
                        'startTimeStamp': '2022-03-03T06:33:28.265051', 
                        'endTimeStamp': '2022-03-03 08:33:28.265063' 
                    }, 
                    {
                         'startTimeStamp': '2022-03-03T11:33:28.265071', 
                         'endTimeStamp': '2022-03-03 16:33:28.265078' 
                    }, 
                    { 
                        'startTimeStamp': '2022-03-03T17:33:28.265085',
                         'endTimeStamp': '2022-03-03T18:33:28.265085'
                    }
                ], 
                'goalIntervalLengthInSeconds': 500 
            }, 
            { 
                'name': 'Work', 
                'intervals': [
                    { 
                        'startTimeStamp': '2022-03-03T08:33:28.265093',
                        'endTimeStamp': '2022-03-03 10:33:28.265100', 
                    },
                    { 
                        'startTimeStamp': '2022-03-03T11:33:28.265093',
                        'endTimeStamp': null, 
                    }
                ], 
                'goalIntervalLengthInSeconds': 72000
            }, 
            { 
                'name': 'Personal', 
                'intervals': [
                    { 
                        'startTimeStamp': '2022-03-03T14:33:28.265113', 
                        'endTimeStamp': '2022-03-03T16:33:28.264777'
                    }
                ], 
                'goalIntervalLengthInSeconds': 500 
            }
        ], 
        'selectedProjectNumber': 2
    } 
});
});

exports.takeABreak = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateProjectName = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.updateCurrentWorkingProject = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});

exports.detectPerson = functions.https.onRequest((request, response) => {
    functions.logger.info("Hello logs!", { structuredData: true });
    response.send({ "data": "Hello from Firebase!" });
});
