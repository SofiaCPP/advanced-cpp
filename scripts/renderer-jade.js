var jade = require('jade');

var lt = /</g,
    gt = />/g,
    amp = /&/g,
    quot = /"/g;

function cxx(block) {
    var escaped = block
        .replace(amp, '&amp;')
        .replace(lt, '&lt;')
        .replace(gt, '&gt;')
        .replace(quot, '&quot;');
    return '<pre class="mstretch"><code>' + escaped + '</pre></code>';
}

jade.filters.cxx = cxx;
jade.filters.code = cxx;

var front = /(?:.*?)---(.*)/m;

hexo.extend.renderer.register('jade', 'html', function(data, locals){
    var m = front.exec(data.text);
    return jade.compile(m? m[1] : data.text, {filename: data.path})(locals);
}, true);

