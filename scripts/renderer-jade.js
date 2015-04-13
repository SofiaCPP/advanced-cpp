var jade = require('jade'),
    mdit = require('markdown-it'),
    mdit_container = require('markdown-it-container'),
    fs = require('fs'),
    hljs = require('highlight.js')

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
    return '<pre class="mstretch"><code>' + escaped + '</code></pre>';
}

var files = {};
function load(file) {
    var content = files[file];
    if (content === undefined) {
        content = files[file] = fs.readFileSync('source/slides/' + file,
                { encoding: 'utf8' });
    }
    return content;
}

var startsWithSpace = /^\s/,
    indent = /\n[ \t]/g;

function minIndent(section) {
    while (section.match(startsWithSpace)) {
        section = section.replace(startsWithSpace, '');
        section = section.replace(indent, '\n');
    }
    return section;
}

function getSections(code, sections) {
    if (sections !== undefined) {
        var snippets = [];
        sections.split(' ').forEach(function (section) {
            var res = '\\s*\\/\\/@{ ' + section + '\n(\\s*(?:.|\n)*?)'
                    + '\\s*\\/\\/@} ' + section,
                re = new RegExp(res, 'gm');
            code.replace(re, function (m, snippet) {
                snippets.push(minIndent(snippet));
                return '';
            });
        });
        code = snippets.join('\n// ...\n');
    }

    return hljs.highlightAuto(code).value;
}

var snippet = /^snippet\s+([^\s]+)\s*(.*)$/;

function renderSnippet(tokens, idx) {
    if (tokens[idx].nesting === 1) {
        var m = tokens[idx].info.trim().match(snippet),
            file = m[1],
            sections = m[2],
            code = getSections(load(file), sections);
        return '<div class="snippet" data-file="/advanced-cpp/slides/' + file +
                '" data-sections="' + sections +
                '"><pre><code>' + code + '</code></pre>';
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

jade.filters.cxx = cxx;
jade.filters.code = cxx;
jade.filters.slides = renderSlides;

var front = /(?:.*?)---(.*)/m;

function render(data, locals) {
    var m = front.exec(data.text);
    return jade.compile(m? m[1] : data.text, {filename: data.path})(locals);
}

hexo.extend.renderer.register('jade', 'html', render, true);
