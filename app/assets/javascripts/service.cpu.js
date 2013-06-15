$services ['puppetdashboard'] =
{ 
	'json_url'	:'http://puppetdashboard.myvitrine.com/nodes.json',
	'url'				:'http://puppetdashboard.myvitrine.com',
	'widgets'		: [
		{
			'name'    	:'Puppet Nodes',
			'template' 	:'puppetdashboard_template'
		}
	]
},