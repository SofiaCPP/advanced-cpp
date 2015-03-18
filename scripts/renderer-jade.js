var jade = require('jade'),
    mdit = require('markdown-it'),
    mdit_container = require('markdown-it-container');

function renderSlide(tokens, idx) {
    if (tokens[idx].nesting === 1) {
        return '<section>';
    } else {
        return '</section>';
    }
}

function renderNotes(tokens, idx) {
    if (tokens[idx].nesting === 1) {
        return '<aside class="notes">';
    } else {
        return '</aside>';
    }
}

var snippet = /^snippet\s+([^\s]+)\s*(.*)$/;

function renderSnippet(tokens, idx) {
    if (tokens[idx].nesting === 1) {
        var m = tokens[idx].info.trim().match(snippet),
            file = m[1],
            sections = m[2];
        return '<div class="snippet" data-file="' + file + '" data-sections="' +
                sections +
                '"><code><pre>// loading ... </pre></code>';
    } else {
        return '</div>';
    }
}

var md = mdit().use(mdit_container, 'topic', { render: renderSlide, marker: '=' })
               .use(mdit_container, 'slide', { render: renderSlide, marker: '+' })
               .use(mdit_container, 'notes', { render: renderNotes, marker: '$' })
               .use(mdit_container, 'snippet', { render: renderSnippet });

function renderSlides(block) {
    var r = md.render(block);
    return r;
}

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
jade.filters.slides = renderSlides;

var front = /(?:.*?)---(.*)/m;

function render(data, locals) {
    var m = front.exec(data.text);
    return jade.compile(m? m[1] : data.text, {filename: data.path})(locals);
}

hexo.extend.renderer.register('jade', 'html', render, true);
