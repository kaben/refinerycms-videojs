window.onload = function ()
{
    if ($('video').is('*')) {
        $('body').append('<link href="http://vjs.zencdn.net/4.6/video-js.css" rel="stylesheet"/>')
        $('body').append('<script src="http://vjs.zencdn.net/4.6/video.js"></script>')
        $('body').append('<script src="/assets/youtube.js"></script>')

    }
};
