window.addEventListener( 'load', function(){
	$.ajax({
		type: 'GET',
		url: '/rss/index.php',
		dataType: 'json',
		success: function(json){
			var rss_items = json["item"];

			var len = rss_items.length;
			if(len > 10)
				len = 10;

			var root = document.getElementsByClassName('rss-items')[0];

			var template = document.getElementById('rss-template');

			for(var i=0; i < len; i++){
				//複製してliタグを得る
				var new_li = document.importNode(template.content, true).firstElementChild;
				var new_a = new_li.firstElementChild;

				new_a.setAttribute("href", rss_items[i]["link"]);
				new_a.innerHTML = rss_items[i]["title"];

				root.appendChild(new_li);
			}
		}
	});
},false);
