const fs = require("fs")
const childProcess = require("child_process")
fs.watch("src/", (event, filename) => {
    childProcess.exec("make", (err, sout, serr) => {
        console.log(sout)
    })
})