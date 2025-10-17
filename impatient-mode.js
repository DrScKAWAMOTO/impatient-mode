// ------------------------------
// tkita 版 impatient-mode.js — markdown-it 版 (WebKit対応 + 画面ログ)
// 修正版: mermaid 二重初期化削除 + div余白リセット
// ------------------------------

// ------------------------------
// 基本設定
// ------------------------------
var buffer = window.location.pathname.split('/')[3];
var max_period = 60000;
var min_period = 1000;
var next_period = min_period;
var alpha = 1.2;
var current_id = '-1';

// ------------------------------
// タイマー関連
// ------------------------------
var nextTimeout = function() {
    var next = next_period;
    next_period = Math.min(max_period, next_period * alpha);
    return next;
};

var resetTimeout = function() {
    next_period = min_period;
};

// ------------------------------
// markdown-it 設定
// ------------------------------
(function() {
    function escapeHtml(str) {
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    if (typeof window.markdownit === 'undefined') {
        console.error("markdown-it not found: /imp/static/markdown-it.min.js を読み込んでください");
    }

    window._imp_md = window.markdownit({
        html: true,
        linkify: true,
        typographer: true,
        highlight: function(str, lang) {
            if (typeof hljs !== 'undefined' && lang && hljs.getLanguage && hljs.getLanguage(lang)) {
                try {
                    return '<pre><code class="hljs language-' + lang + '">' +
                        hljs.highlight(str, {language: lang}).value +
                        '</code></pre>';
                } catch (e) { }
            }
            return '<pre><code>' + escapeHtml(str) + '</code></pre>';
        }
    });

    var defaultFence = window._imp_md.renderer.rules.fence || function(tokens, idx, options, env, slf) {
        var token = tokens[idx];
        var info = token.info ? token.info.trim() : '';
        var lang = info.split(/\s+/g)[0];
        var content = token.content;
        return '<pre><code' + (lang ? ' class="language-' + window._imp_md.utils.escapeHtml(lang) + '"' : '') + '>'
            + window._imp_md.utils.escapeHtml(content)
            + '</code></pre>';
    };

    // mermaid 対応: div余白リセット & 二重レンダリング回避
    window._imp_md.renderer.rules.fence = function(tokens, idx, options, env, slf) {
        var token = tokens[idx];
        var info = token.info ? token.info.trim() : '';
        var lang = info.split(/\s+/g)[0];
        var content = token.content;
        if (lang === 'mermaid') {
            return '<div class="mermaid" style="margin:0; padding:0;">' +
                   window._imp_md.utils.escapeHtml(content) +
                   '</div>';
        }
        return defaultFence(tokens, idx, options, env, slf);
    };
})();

// ------------------------------
// Markdown -> HTML
// ------------------------------
var md2html = function(resCount, resMarkdownText) {
    console.log("md2html called: resCount=" + resCount);
    var el = document.getElementById('marked');
    if (!el) {
        console.error("md2html: #marked element not found");
        return;
    }

    if (!resCount) {
        el.innerHTML = 'error parsing the response from emacs';
        xhr.onreadystatechange = function() {};
        xhr.abort();
        return;
    }

    current_id = resCount;

    try {
        if (typeof window._imp_md === 'undefined') {
            el.innerHTML = '<pre style="color:red">markdown-it not loaded</pre>';
            return;
        }

        el.innerHTML = window._imp_md.render(resMarkdownText);

        if (typeof hljs !== 'undefined' && hljs.highlightAll) {
            try { hljs.highlightAll(); } catch (e) { console.warn("hljs.highlightAll error:", e); }
        }

        if (typeof mermaid !== 'undefined') {
            try {
                if (mermaid.initialize) {
                    mermaid.initialize({ startOnLoad: false });
                }
                var mermaidEls = el.querySelectorAll('.mermaid');
                if (mermaidEls && mermaidEls.length > 0) {
                    // 二重レンダリングを避けるため、ここだけで初期化
                    mermaid.init(undefined, mermaidEls);
                }
            } catch (e) {
                console.warn("mermaid init error:", e);
            }
        }

        if (window.MathJax && MathJax.typesetPromise) {
            try {
                MathJax.typesetPromise([el]).then(function() {
                    console.log("MathJax.typesetPromise completed");
                }).catch(function(err) { console.warn("MathJax.typesetPromise error:", err); });
            } catch (e) {
                console.warn("MathJax typeset call error:", e);
            }
        }

        console.log("md2html: rendering complete");

    } catch (err) {
        console.error("md2html error: " + err);
        el.innerHTML = '<pre style="color:red">Markdown rendering error<br>' + String(err) + '</pre>';
    }
};

// ------------------------------
// スクロール操作
// ------------------------------
var impCtrl = {
    'Goto': function(props) {
        if (props === 'Top') window.scrollTo(0, 0);
        else window.scroll(0, document.documentElement.scrollHeight - document.documentElement.clientHeight);
        console.log("impCtrl: Goto " + props);
    },
    'Recenter': function(props) {
        window.scroll(0, document.documentElement.scrollHeight * parseFloat(props));
        console.log("impCtrl: Recenter " + props);
    },
    'Scroll': function(props) {
        if (typeof window.scrollByLines === 'function') window.scrollByLines(props);
        console.log("impCtrl: Scroll " + props);
    }
};

// ------------------------------
// XHR
// ------------------------------
var xhr = new XMLHttpRequest();

xhr.onreadystatechange = function() {
    console.log("xhr readyState=" + xhr.readyState + " status=" + xhr.status);
    if (xhr.readyState === 4) {
        resetTimeout();

        var ctrl = xhr.getResponseHeader('X-Imp-Ctrl');
        if (ctrl && ctrl !== 'nil') {
            var parts = ctrl.split('/');
            if (impCtrl[parts[0]]) impCtrl[parts[0]](parts[1]);
        }

        md2html(xhr.getResponseHeader('X-Imp-Count'), xhr.responseText);
        httpRequest();
    }
};

xhr.onerror = function() {
    console.error("xhr.onerror: readyState=" + xhr.readyState + " status=" + xhr.status);
    if (xhr.readyState === 4 && xhr.status === 0) xhr.abort();
    else setTimeout(httpRequest, nextTimeout());
};

var httpRequest = function() {
    console.log("httpRequest: sending request for buffer " + buffer + " id=" + current_id);
    xhr.open('GET', '/imp/buffer/' + buffer + '?id=' + current_id);
    xhr.send();
};

// ------------------------------
// DOMContentLoaded 後に開始
// ------------------------------
document.addEventListener('DOMContentLoaded', function() {
    console.log("DOMContentLoaded event");
    var titleEl = document.getElementById('title');
    if (titleEl) titleEl.textContent = decodeURI(buffer);
    setTimeout(httpRequest, 50);
});
