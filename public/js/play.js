
var main = function () {

	String.prototype.leftJustify = function( length, char ) {
    var fill = [];
    while ( fill.length + this.length < length ) {
      fill[fill.length] = char;
    }
    return fill.join('') + this;
	}

	if ($('.player').css("height") > $('.info').css("height")) {
		$('.info').css("height",$('.player').css("height"));
	}
	else {
		$('.player').css("height",$('.info').css("height"));
	}

	//MP3 player
	//set song to first song on album
	var source = $('.player ul span').first();
	var song = new Audio(source.attr("source"));

	//play button
	$('.mp3-controls').on("click",'.glyphicon-play',function() {
		song.play();
		$('.glyphicon-play').addClass("glyphicon-pause");
		$('.glyphicon-play').removeClass("glyphicon-play");
	});
	//pause button
	$('.mp3-controls').on("click",'.glyphicon-pause',function() {
		song.pause();
		$('.glyphicon-pause').addClass("glyphicon-play");
		$('.glyphicon-pause').removeClass("glyphicon-pause");
	});
	//next song button
	$('.glyphicon-step-forward').click(function() {
		nextSong();
	});
	//last song button
	$('.glyphicon-step-backward').click(function() {
		previousSong();
	});
	var nextSong = function () {
		song.pause();
		index = $('.player ul span').index(source);
		source.css("color","rgba(255,255,255,0.5)");
		source = $('.player ul span').eq((index+1)% $('.player ul span').length);
		console.log(source);
		song = new Audio(source.attr("source"));
		source.css("color","rgba(0,0,255,0.5)");
		song.play();
	}
	var previousSong = function () {
		song.pause();
		index = $('.player ul span').index(source);
		source.css("color","rgba(255,255,255,0.5)");
		source = $('.player ul span').eq((index-1)% $('.player ul span').length);
		console.log(source);
		source.css("color","rgba(0,0,255,0.5)");
		song = new Audio(source.attr("source"));
		song.play();
	}
	//slider
	var render = function () {
		//puts on next song if its the end of the song
		if (song.currentTime == song.duration) {
			nextSong();
			$('#time').text("0");

		}
		else {
			$('#time').text(parseTime(song.currentTime));
			$('.played').css("width",(song.currentTime/song.duration*100).toString() + "%");
			
		}
	}

	var parseTime = function (seconds) {
		
		seconds = parseInt(seconds % 60);
		var minutes = parseInt((seconds / 60) % 1);
		return minutes.toString().leftJustify(2,"0") + ":" + seconds.toString().leftJustify(2,"0");

	}
	//play first song off the bat

	source.css("color","rgba(0,0,255,0.5)");
	song.play();

	setInterval(function() {
		render();
	},1);
	


}
$(document).ready(main);