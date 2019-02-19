//.pragma library // Shared game state
.import QtQuick 2.9 as QQ

var shots = 0, maxShots = 3

// Ticks (The different clocks)
var ticks = 0, shotTicks = 0

var tickClocks = null

// Intervals
var updateInterval = 50, waitDelay = 1000, alertDelay = 500, shotDelay = 3000

// booleans
var heroSpotted = false

function resetTicks(clockName) {
    if (clockName === undefined)
        tickClocks = null; // Reset all
    else if (tickClocks !== null && Object(tickClocks).hasOwnProperty(clockName))
        tickClocks[clockName] = 0;
}

function getTicks(clockName) {
    if (tickClocks !== null && Object(tickClocks).hasOwnProperty(clockName))
        return tickClocks[clockName];

    return 0;
}

function tick(clockName) {
    if (tickClocks == null) {
        tickClocks = {};
        tickClocks[clockName] = 1;
    } else if (tickClocks != null && Object(tickClocks).hasOwnProperty(clockName)) {
        tickClocks[clockName]++;
    }
}

function getElapsedTickTime(clockName) {
    return getTicks(clockName) * updateInterval;
}

function setHeroSpotted(spotted) {
    if(heroSpotted !== spotted)
        heroSpotted = spotted
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
