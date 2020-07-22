var http = require("http");

var options = {
    host : "localhost",
    port : process.env.XO_HTTP_LISTEN_PORT,
    timeout : 2000
};

var request = http.request(options, (res) => {
    if ([200, 302].includes(res.statusCode)) {
      console.log(`OK STATUS: ${res.statusCode}`);
      process.exit(0);
    }
    else {
      console.log(`ERROR STATUS: ${res.statusCode}`);
      process.exit(1);
    }
});

request.on('error', function(err) {
    console.log('ERROR');
    process.exit(1);
});

request.end();
