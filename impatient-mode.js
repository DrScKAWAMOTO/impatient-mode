// ------------------------------
// tkita 版 impatient-mode.js — markdown-it 版 (WebKit対応 + 画面ログ)
// 変更点: marked -> markdown-it に置換。mermaid, MathJax, highlight の初期化順序調整。
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
// markdown-it 設定 (marked の代替)
// - fenced code のうち info が "mermaid" の場合は <div class="mermaid">...</div> に変換して mermaid.init に渡す
// - ハイライトは highlight.js に委譲（存在すれば highlightAll() を呼ぶ）
// ------------------------------
(function() {
    // 簡易エスケープ関数（HTMLエスケープ）
    function escapeHtml(str) {
        return str
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    // markdown-it をグローバルに用意
    if (typeof window.markdownit === 'undefined') {
        console.error("markdown-it not found: /imp/static/markdown-it.min.js を読み込んでください");
    }

    // markdown-it インスタンス作成
    window._imp_md = window.markdownit({
        html: true,
        linkify: true,
        typographer: true,
        // highlight 関数：fallback としてプリフォーマットしたものを返す
        highlight: function (str, lang) {
            if (typeof hljs !== 'undefined' && lang && hljs.getLanguage && hljs.getLanguage(lang)) {
                try {
                    return '<pre><code class="hljs language-' + lang + '">' +
                        hljs.highlight(str, {language: lang}).value +
                        '</code></pre>';
                } catch (e) {
                    // fallthrough
                }
            }
            return '<pre><code>' + escapeHtml(str) + '</code></pre>';
        }
    });

    // fenced code のデフォルトルールを保持
    var defaultFence = window._imp_md.renderer.rules.fence || function(tokens, idx, options, env, slf) {
        var token = tokens[idx];
        var info = token.info ? token.info.trim() : '';
        var lang = info.split(/\s+/g)[0];
        var content = token.content;
        return '<pre><code' + (lang ? ' class="language-' + window._imp_md.utils.escapeHtml(lang) + '"' : '') + '>'
            + window._imp_md.utils.escapeHtml(content)
            + '</code></pre>';
    };

    // mermaid 対応：info が "mermaid" のとき専用出力
    window._imp_md.renderer.rules.fence = function(tokens, idx, options, env, slf) {
        var token = tokens[idx];
        var info = token.info ? token.info.trim() : '';
        var lang = info.split(/\s+/g)[0];
        var content = token.content;
        if (lang === 'mermaid') {
            // mermaid は <div class="mermaid"> の中身を期待するのでそれに合わせる
            return '<div class="mermaid">' + window._imp_md.utils.escapeHtml(content) + '</div>';
        }
        // デフォルト処理（highlight 関数が適用される）
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
        // Markdown を HTML に変換（markdown-it を使用）
        if (typeof window._imp_md === 'undefined') {
            el.innerHTML = '<pre style="color:red">markdown-it not loaded</pre>';
            return;
        }

        el.innerHTML = window._imp_md.render(resMarkdownText);

        // highlight.js 初期化（存在するなら）
        if (typeof hljs !== 'undefined' && hljs.highlightAll) {
            try {
                hljs.highlightAll();
                console.log("hljs.highlightAll executed");
            } catch (e) {
                console.warn("hljs.highlightAll error:", e);
            }
        }

        // mermaid 初期化（存在するなら）
        if (typeof mermaid !== 'undefined') {
            try {
                // mermaid の自動初期化をオフにしている場合のために明示的に初期化
                if (mermaid.initialize) {
                    // mermaid 初期化（安全のため startOnLoad: false）
                    try { mermaid.initialize({ startOnLoad: false }); } catch (e) { /* ignore */ }
                }
                // .mermaid 要素を対象に初期化
                var mermaidEls = el.querySelectorAll('.mermaid');
                if (mermaidEls && mermaidEls.length > 0) {
                    // mermaid.init は第1引数にオプション、第2引数に要素集合を取る実装が多い
                    try {
                        mermaid.init(undefined, mermaidEls);
                        console.log("mermaid.init executed");
                    } catch (e) {
                        // 互換性のため、個別にレンダリングを試す
                        mermaidEls.forEach(function(mel, idx) {
                            try {
                                var txt = mel.textContent || mel.innerText;
                                var id = 'mermaid-' + (new Date().getTime()) + '-' + idx;
                                mel.setAttribute('id', id);
                                // mermaid では mermaid.mermaidAPI.render を使って個別に描画する場合がある
                                if (mermaid.mermaidAPI && mermaid.mermaidAPI.render) {
                                    mermaid.mermaidAPI.render(id + '-svg', txt, function(svgCode) {
                                        mel.innerHTML = svgCode;
                                    }, mel);
                                }
                            } catch (ee) {
                                console.warn("mermaid render fallback failed", ee);
                            }
                        });
                    }
                }
            } catch (e) {
                console.warn("mermaid init error:", e);
            }
        }

        // MathJax v3 が読み込まれていれば、挿入 DOM に対して typeset を呼ぶ
        if (window.MathJax && MathJax.typesetPromise) {
            try {
                MathJax.typesetPromise([el]).then(function() {
                    console.log("MathJax.typesetPromise completed");
                }).catch(function(err) {
                    console.warn("MathJax.typesetPromise error:", err);
                });
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
        if (props === 'Top') {
            window.scrollTo(0, 0);
        } else {
            var e = document.documentElement;
            window.scroll(0, e.scrollHeight - e.clientHeight);
        }
        console.log("impCtrl: Goto " + props);
    },
    'Recenter': function(props) {
        window.scroll(0, document.documentElement.scrollHeight * parseFloat(props));
        console.log("impCtrl: Recenter " + props);
    },
    'Scroll': function(props) {
        if (typeof window.scrollByLines === 'function') {
            window.scrollByLines(props);
            console.log("impCtrl: Scroll " + props);
        }
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
            if (impCtrl[parts[0]]) {
                impCtrl[parts[0]](parts[1]);
            }
        }

        md2html(xhr.getResponseHeader('X-Imp-Count'), xhr.responseText);
        httpRequest();
    }
};

xhr.onerror = function() {
    console.error("xhr.onerror: readyState=" + xhr.readyState + " status=" + xhr.status);
    if (xhr.readyState === 4 && xhr.status === 0) {
        xhr.abort();
    } else {
        setTimeout(httpRequest, nextTimeout());
    }
};

var httpRequest = function() {
    console.log("httpRequest: sending request for buffer " + buffer + " id=" + current_id);
    xhr.open('GET', '/imp/buffer/' + buffer + '?id=' + current_id);
    xhr.send();
};

// ------------------------------
// DOMContentLoaded 後に開始（WebKit対応のため少し遅延）
// ------------------------------
document.addEventListener('DOMContentLoaded', function() {
    console.log("DOMContentLoaded event");
    // タイトル更新
    var titleEl = document.getElementById('title');
    if (titleEl) titleEl.textContent = decodeURI(buffer);
    setTimeout(httpRequest, 50);
});
