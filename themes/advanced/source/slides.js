Reveal.initialize({
    controls: true,
    progress: true,
    history: true,
    center: false,
    mouseWheel: true,
    overview: true,
    slideNumber: true,
    margin: 0.1,

    transition: Reveal.getQueryHash().transition || 'none',
    // default/cube/page/concave/zoom/linear/fade/none

    dependencies: [
        {
            src: '/advanced-cpp/bower_components/reveal.js/lib/js/classList.js',
            condition: function() { return !document.body.classList; }
        },
        {
            src: '/advanced-cpp/bower_components/reveal.js/plugin/markdown/marked.js',
            condition: function() {
                return !!document.querySelector( '[data-markdown]' );
            }
        },
        {
            src: '/advanced-cpp/bower_components/reveal.js/plugin/markdown/markdown.js',
            condition: function() {
                return !!document.querySelector( '[data-markdown]' );
            }
        },
        {
            src: '/advanced-cpp/bower_components/reveal.js/plugin/zoom-js/zoom.js',
            async: true
        },
        {
            src: '/advanced-cpp/bower_components/reveal.js/plugin/notes/notes.js',
            async: true
        }
    ]
});

(function ($, hljs) {
    var lt = /</g,
        gt = />/g,
        amp = /&/g,
        quot = /"/g,
        files = {};


    function load(file) {
        var promise = files[file];
        if (promise === undefined) {
            promise = files[file] = $.get(file);
        }
        return promise;
    }

    function cxx(block) {
        var escaped = block
            .replace(amp, '&amp;')
            .replace(lt, '&lt;')
            .replace(gt, '&gt;')
            .replace(quot, '&quot;');
        return '<pre class="stretch"><code>' + escaped + '</pre></code>';
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
        return cxx(code);
    }

    $(function () {
        hljs.initHighlightingOnLoad();

        $('.snippet').each(function (i, sample) {
            var s = $(sample),
                url = s.attr('data-file'),
                sections = s.attr('data-sections');

            load(url).then(function (d) {
                s.html(getSections(d, sections));
                hljs.highlightBlock(sample);
            });
        });
    });
}(jQuery, hljs));
