module.exports = function(app, elm, expressWs) {

    app.ws('/control', function(ws, req) {
        ws.on('message', function(msg) {
            console.log("On message:", msg);
        });
    });

};