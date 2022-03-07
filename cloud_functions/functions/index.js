const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const fcm = admin.messaging();

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions

function pad(number) {
    var r = String(number);
    if (r.length === 1) {
      r = '0' + r;
    }
    return r;
}

function toISOString(date) {
    return date.getUTCFullYear() +
      '-' + pad(date.getUTCMonth() + 1) +

      '-' + pad(date.getUTCDate()) +
      'T' + pad(date.getUTCHours()) +
      ':' + pad(date.getUTCMinutes()) +
      ':' + pad(date.getUTCSeconds()) +
      '.' + String((date.getUTCMilliseconds() / 1000).toFixed(3)).slice(2, 5) +
      'Z';
  };


function checkIfExceededBreak(user) {
    const selectedProjectNumber = user['selectedProjectNumber'];
    functions.logger.info('selectedProjectNumber', { structuredData: true });
    functions.logger.info(selectedProjectNumber, { structuredData: true });

    const selectedProject = user['projects'][selectedProjectNumber];
    functions.logger.info('selectedProject', { structuredData: true });
    functions.logger.info(selectedProject, { structuredData: true });

    const goalIntervalLengthInSeconds = selectedProject['goalIntervalLengthInSeconds'];
    functions.logger.info('goalIntervalLengthInSeconds ' + goalIntervalLengthInSeconds, { structuredData: true });

    const intervals = selectedProject['intervals'];
    functions.logger.info('intervals', { structuredData: true });
    functions.logger.info(intervals, { structuredData: true });

    const mostRecentInterval = intervals[intervals.length - 1];
    functions.logger.info('mostRecentInterval', { structuredData: true });
    functions.logger.info(mostRecentInterval, { structuredData: true });

    const startTime = parseISOString( mostRecentInterval['startTimeStamp']);
    functions.logger.info('startTime', { structuredData: true });
    functions.logger.info(startTime, { structuredData: true });

    const currentTime = Date.now();
    functions.logger.info('currentTime', { structuredData: true });
    functions.logger.info(currentTime, { structuredData: true });

    const differenceInSeconds = (currentTime - startTime) / 1000;
    functions.logger.info('differenceInSeconds', { structuredData: true });
    functions.logger.info(differenceInSeconds, { structuredData: true });
    
    return differenceInSeconds > goalIntervalLengthInSeconds;
}

function getCurrentWorkingProject(user) {
    const selectedProjectNumber = user['selectedProjectNumber'];
    functions.logger.info('selectedProjectNumber', { structuredData: true });
    functions.logger.info(selectedProjectNumber, { structuredData: true });

    const selectedProject = user['projects'][selectedProjectNumber];
    functions.logger.info('selectedProject', { structuredData: true });
    functions.logger.info(selectedProject, { structuredData: true });
    return selectedProject;
}

function getCurrentWorkingInterval(user) {
    const selectedProject = getCurrentWorkingProject(user);
    const mostRecentInterval = getLastIntervalForProject(selectedProject);
    return mostRecentInterval
}

function getLastIntervalForProject(project) {
    const intervals = selectedProject['intervals'];
    functions.logger.info('intervals', { structuredData: true });
    functions.logger.info(intervals, { structuredData: true });

    const mostRecentInterval = intervals[intervals.length - 1];
    functions.logger.info('mostRecentInterval', { structuredData: true });
    functions.logger.info(mostRecentInterval, { structuredData: true });
    return mostRecentInterval;
}

function sendTakeABreakNotification(user) {
    functions.logger.info('fcmToken ' + user['fcmToken'], { structuredData: true });
    console.log("sending message...");
    var num = user['selectedProjectNumber'];
    const payload = {
      notification: {
        title: "Take a break! You've achieved your goal",
        body: "",
        sound: "default",
      },
      data: {
        projectIndex: num.toString(),
        // name: String(closestPlace.name),
        // imageUrl: url,
        // long: String(closestPlace.geometry.location.lng),
        // lat: String(closestPlace.geometry.location.lat),
        // types: JSON.stringify(closestPlace.types),
      },
    };
    fcm.sendToDevice(user['fcmToken'], payload, {
      priority: "high",
    });
    console.log("message sent");
}

function createNewInterval(startTime) {
    const date = Date.now();

}


function parseISOString(s) {
    var b = s.split(/\D+/);
    return new Date(Date.UTC(b[0], --b[1], b[2], b[3], b[4], b[5], b[6]));
}

exports.update = functions.https.onCall(async (data, context) => {
    functions.logger.info("Hello logs!", { structuredData: true });

    const id = data['id'];
    const userRef = admin.database().ref('users/' + id);
    userRef.once('value', async (snapshot) => { 
        const user = snapshot.val();
        const isUserAlreadyWorking = user['isWorking'];
        functions.logger.info(user, { structuredData: true });
        const isUserAtDesk = detectPerson(user);
        const fcmToken = user['fcmToken'];

        functions.logger.info(isUserAtDesk, { structuredData: true });
    
        functions.logger.info(user, { structuredData: true });
    
        if(!isUserAlreadyWorking && isUserAtDesk) { // Scenario 1
            functions.logger.info('!isUserAlreadyWorking && isUserAtDesk', { structuredData: true });
            
            const selectedProjectNumber = user['selectedProjectNumber']; 
            const selectedProjectInvervalsRef = userRef.child('projects').child(selectedProjectNumber).child('intervals');
            functions.logger.info('selectedProjectIntervalsRef '+selectedProjectInvervalsRef, { structuredData: true });

            const intervals = user['projects'][selectedProjectNumber]['intervals'];
            const lastIndex = intervals.length-1;
            const mostRecentIntervalRef = selectedProjectInvervalsRef.child(lastIndex + 1);
            functions.logger.info('mostRecentIntervalRef '+ mostRecentIntervalRef, { structuredData: true });

            functions.logger.info('Date now '+toISOString(new Date()), { structuredData: true });
            mostRecentIntervalRef.update({'startTimeStamp':toISOString(new Date())});
        }
        else if(isUserAlreadyWorking && isUserAtDesk) { // Scenario 2 & 3 & 6
            functions.logger.info('isUserAlreadyWorking && isUserAtDesk', { structuredData: true });

            if(user['selectedProjectNumber'] != user['prevProjectNumber']) { // Scenario 6
                functions.logger.info('project has changed', { structuredData: true });
                // Closing previous projects interval...
                const prevProjectNumber = user['prevProjectNumber']; 
                const prevProjectInvervalsRef = userRef.child('projects').child(prevProjectNumber).child('intervals');
                functions.logger.info('prevProjectInvervalsRef '+prevProjectInvervalsRef, { structuredData: true });

                const prevIntervals = user['projects'][prevProjectNumber]['intervals'];
                const prevlastIndex = prevIntervals.length-1;
                const prevmostRecentIntervalRef = prevProjectInvervalsRef.child(prevlastIndex);
                functions.logger.info('prevmostRecentIntervalRef '+ prevmostRecentIntervalRef, { structuredData: true });

                functions.logger.info('Date now '+toISOString(new Date()), { structuredData: true });
                prevmostRecentIntervalRef.update({'endTimeStamp':toISOString(new Date())});
                // Closed previous projects interval

                // Creating new interval for the new project...
                const selectedProjectNumber = user['selectedProjectNumber']; 
                const selectedProjectInvervalsRef = userRef.child('projects').child(selectedProjectNumber).child('intervals');
                functions.logger.info('selectedProjectIntervalsRef '+selectedProjectInvervalsRef, { structuredData: true });

                const intervals = user['projects'][selectedProjectNumber]['intervals'];
                const lastIndex = intervals.length-1;
                const mostRecentIntervalRef = selectedProjectInvervalsRef.child(lastIndex + 1);
                functions.logger.info('mostRecentIntervalRef '+ mostRecentIntervalRef, { structuredData: true });

                functions.logger.info('Date now '+toISOString(new Date()), { structuredData: true });
                mostRecentIntervalRef.update({'startTimeStamp':toISOString(new Date())});
                // Created new interval
            } else {
                functions.logger.info('project is the same', { structuredData: true });
                const exceededBreak = checkIfExceededBreak(user);
                functions.logger.info(exceededBreak, { structuredData: true });
                if(exceededBreak) { // Scenario 3
                    sendTakeABreakNotification(user);
                }
                else { // Scenario 2
        
                }
            }
        }
        else if(isUserAlreadyWorking && !isUserAtDesk) { // Scenario 4
            functions.logger.info('isUserAlreadyWorking && !isUserAtDesk', { structuredData: true });

            const selectedProjectNumber = user['selectedProjectNumber']; 
            const selectedProjectInvervalsRef = userRef.child('projects').child(selectedProjectNumber).child('intervals');
            functions.logger.info('selectedProjectIntervalsRef '+selectedProjectInvervalsRef, { structuredData: true });

            const intervals = user['projects'][selectedProjectNumber]['intervals'];
            const lastIndex = intervals.length-1;
            const mostRecentIntervalRef = selectedProjectInvervalsRef.child(lastIndex);
            functions.logger.info('mostRecentIntervalRef '+mostRecentIntervalRef, { structuredData: true });

            functions.logger.info('Date now '+toISOString(new Date()), { structuredData: true });
            mostRecentIntervalRef.update({'endTimeStamp':toISOString(new Date())});
        }
        else if(!isUserAlreadyWorking && !isUserAtDesk) { // Scenario X
            functions.logger.info('!isUserAlreadyWorking && !isUserAtDesk', { structuredData: true });
        }
        admin.database().ref('users/' + id).update({'isWorking':isUserAtDesk});
        admin.database().ref('users/' + id).update({'prevProjectNumber': user['selectedProjectNumber']});
    });
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


exports.updateAtDesk = functions.https.onCall(async (data, context) => {
    functions.logger.info("Hello logs!", { structuredData: true });

    const id = data['id'];
    const atDesk = data['atDesk'];
    const user = admin.database().ref('users/' + id);
    user.update({'atDesk':atDesk});
    return `Successfully changed desk status`;
});

function changeProject(id, projectIndex) {
    const user = admin.database().ref('users/' + id);
    user.update({'selectedProjectNumber':projectIndex});
}

function detectPerson(user) {
    return user['atDesk'];
}
