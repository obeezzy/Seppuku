//.pragma library // Shared game state
.import QtQuick 2.9 as QQ

// Ticks (The different clocks)
var ticks = 0

// Intervals
var updateInterval = 50, waitDelay = 3000

// booleans
var heroSpotted = false

function resetTicks(clockName) {
    switch(clockName) {
    case undefined:
        ticks = 0
        break
    }
}

function getTicks(clockName) {
    switch(clockName) {
    case "":
        return ticks
    }

    return ticks
}

function tick(clockName) {
    switch(clockName) {
    case undefined:
        ticks += updateInterval
        break
    }
}

function setUpdateInterval(interval) {
    updateInterval = interval
}

function setWaitDelay(interval) {
    waitDelay = interval
}

function getWaitDelay() {
    return waitDelay / updateInterval
}
