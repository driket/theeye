var express 	= require('express');
var os 				= require('os');
var app 			= express();
var sys 			= require('sys')
var exec 			= require('child_process').exec;


function puts(error, stdout, stderr) { sys.puts(stdout) }

app.get('/mem_usage', function(req, res){
	
  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Access-Control-Allow-Origin', 'http://localhost:3000');
	
	var used_mem = os.totalmem()-os.freemem();
	var mem_usage = Math.round( used_mem / os.totalmem() * 100 );
	var json = {'value' : mem_usage};
	
	/*exec("ls -la", function(error, stdout, stderr) {
		console.log(stdout);
	})
	*/
  res.send(JSON.stringify(json));
});

app.listen(1337);
console.log('Server running at http://127.0.0.1:1337/');
