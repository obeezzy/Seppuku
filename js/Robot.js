//.pragma library // Shared game state
.import QtQuick 2.9 as QQ

var shots = 0, maxShots = 3

// Ticks (The different clocks
var ticks = 0, shotTicks = 0

// Intervals
var updateInterval = 50, waitDelay = 1000, alertDelay = 500, shotDelay = 3000

// booleans
var actorSpotted = false

function resetTicks(clockName) {
    switch(clockName) {
    case "shot":
        shotTicks = 0
        break
    case "wait":
    case "alert":
        ticks = 0
        break
    default:
        ticks = 0
        shotTicks = 0
        break
    }
}

function getTicks(clockName) {
    switch(clockName) {
    case "shot":
        return shotTicks
    case "wait":
    case "alert":
        return ticks
    }

    return ticks
}

function tick(clockName) {
    switch(clockName) {
    case "shot":
        shotTicks += updateInterval
        break
    case "wait":
    case "alert":
        ticks += updateInterval
        break
    default:
        ticks += updateInterval
        break
    }
}

function setActorSpotted(spotted) {
    if(actorSpotted !== spotted)
        actorSpotted = spotted
}

function setUpdateInterval(interval) {
    updateInterval = interval
}

function getWaitDelay() {
    return waitDelay / updateInterval
}

function getAlertDelay() {
    return alertDelay / updateInterval
}

function getShotDelay() {
    return shotDelay / updateInterval
}

function incrementShots() {
    shots++
}

function getShots() {
    return shots
}

function getMaxShots() {
    return maxShots
}

function resetShots() {
    shots = 0
}

function isShooting() {
    return shots != 0 && shots != maxShots
}
