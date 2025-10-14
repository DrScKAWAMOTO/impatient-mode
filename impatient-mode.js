// ------------------------------
// tkita 版 impatient-mode.js (WebKit対応 + 画面ログ)
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
// marked.js 設定 (v4 UMD)
// ------------------------------
marked.setOptions({ langPrefix: '' });

var renderer = new marked.Renderer();
renderer.code = function(code, lang) {
    if (lang === 'mermaid') {
        return '<pre class="mermaid">' + code + '</pre>';
    } else {
        return '<pre><code>' + code + '</code></pre>';
    }
};

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
        // Markdown を HTML に変換
        el.innerHTML = marked.parse(resMarkdownText, { renderer: renderer });

        // highlight.js v11 初期化
        if (typeof hljs !== 'undefined' && hljs.highlightAll) {
            hljs.highlightAll();
            console.log("hljs.highlightAll executed");
        }

        // mermaid 初期化
        if (typeof mermaid !== 'undefined' && mermaid.init) {
            mermaid.init(undefined, el.querySelectorAll('.language-mermaid'));
            console.log("mermaid.init executed");
        }

        console.log("md2html: rendering complete");

    } catch (err) {
        console.error("md2html error: " + err);
        el.innerHTML = '<pre style="color:red">Markdown rendering error<br>' + err + '</pre>';
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
