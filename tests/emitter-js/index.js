const emitter = require('emitter-io');

// Run this code into postgresql database
/*
SELECT pgnotify_emitter.keygen('emitter-channel','{
    "channel": "test/"
}');
*/

// then query the result code 
/*
SELECT * FROM pgnotify_emitter.keygen
WHERE response->>'channel' ilike '%test/%'
ORDER BY id DESC, ts DESC LIMIT 100
*/

const chanelKey = "Us3JQzMD037hjc-pQsOHhCuD_VxFRTEV";

const testChannel = 'test'

let client = emitter.connect({
    host: "emitter.etalatam.com",
    port: 443,
    keepalive: 30,
    secure: true
});

console.log("Emitter connecting...")
client.on('connect', async () => {
    // once we're connected, subscribe to the 'test' channel
    console.log('emitter connected');

    client.subscribe({
        key: chanelKey,
        channel: testChannel
    });

})

// Run this code into postgresql database
/*
SELECT pgnotify_emitter.publish('emitter-channel','{
    "channel": "test/",
	"message": "Mensaje enviado desde postgresql"
}');
*/
client.on('message', function(msg){
	console.log( msg.asString() );
})