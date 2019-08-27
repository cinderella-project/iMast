const fs = require("fs")
const childProcess = require("child_process")
fs.watch("src/", {persistent: true, recursive: true}, (event, filename) => {
    childProcess.exec("make", (err, sout, serr) => {
        console.log(sout)
    })
})