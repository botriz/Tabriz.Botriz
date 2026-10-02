نام مخزن: **`botriz.tabriz`**؛ نام برنامه: **Botriz**.

فایل‌های سایت را در ریشهٔ مخزن GitHub بساز؛ مسیر هرکدام کنار نامش آمده. هر بلوک یک فایل جداست و از دکمهٔ کپی همان بلوک استفاده کن. **کلید API را داخل هیچ‌کدام از فایل‌های GitHub نگذار.**

GitHub Pages فقط سایت را اجرا می‌کند؛ برای پاسخ هوشمند، سرور جداگانه لازم است. بعد از بارگذاری فایل‌ها، مراحل GitHub و سپس مراحل ترمینال را به ترتیب انجام بده.

## فایل ۱ — `index.html` — ریشهٔ مخزن

```html
<!doctype html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#111827">
  <link rel="manifest" href="./manifest.webmanifest">
  <title>Botriz</title>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0; background: #0b1020; color: #f3f4f6;
      font-family: system-ui, Tahoma, sans-serif;
    }
    main { max-width: 760px; margin: auto; padding: 12px; }
    section {
      background: #151c2e; border: 1px solid #28334c;
      border-radius: 16px; padding: 14px; margin-bottom: 12px;
    }
    h1, h2 { margin: 0 0 10px; }
    h1 { font-size: 1.4rem; }
    h2 { font-size: 1.05rem; }
    p { color: #b8c2d8; line-height: 1.8; }
    #chat {
      height: 40vh; min-height: 220px; overflow-y: auto;
      background: #0b1020; border-radius: 12px; padding: 10px;
    }
    .bubble {
      max-width: 92%; padding: 10px 12px; border-radius: 12px;
      margin: 8px 0; white-space: pre-wrap; overflow-wrap: anywhere;
      line-height: 1.7;
    }
    .user { background: #244a7a; margin-right: auto; }
    .assistant { background: #222c42; margin-left: auto; }
    .row { display: flex; gap: 8px; margin-top: 10px; }
    input, button {
      font: inherit; border-radius: 10px; padding: 11px;
    }
    input {
      min-width: 0; flex: 1; color: white;
      background: #0b1020; border: 1px solid #35415b;
    }
    button { border: 0; color: white; background: #5865f2; cursor: pointer; }
    button.secondary { background: #35415b; }
    button.danger { background: #8c3442; }
    .entry {
      display: flex; justify-content: space-between; align-items: center;
      gap: 8px; padding: 8px 0; border-bottom: 1px solid #28334c;
      overflow-wrap: anywhere;
    }
    .entry span { flex: 1; }
    .entry button { padding: 6px 9px; }
    .small { font-size: .88rem; }
    @media (max-width: 480px) {
      .row { flex-wrap: wrap; }
      .row button { width: 100%; }
    }
  </style>
</head>
<body>
<main>
  <section>
    <h1>Botriz</h1>
    <p>
      ثبت آموزش: <b>یاد بگیر: ...</b><br>
      حذف آموزش: <b>فراموش کن: ...</b><br>
      گفتگو و حافظه در همین مرورگر ذخیره می‌شوند.
    </p>
    <div id="chat" aria-live="polite"></div>
    <form id="chatForm" class="row">
      <input id="message" autocomplete="off" placeholder="پیامت را بنویس…">
      <button type="submit">ارسال</button>
    </form>
  </section>

  <section>
    <h2>تنظیم اتصال هوش مصنوعی</h2>
    <p class="small">
      نشانی سرور و رمز دسترسی را از میزبان سرور بگیر. این اطلاعات در مرورگر ذخیره می‌شوند، نه در مخزن GitHub.
    </p>
    <form id="settingsForm">
      <input id="serverUrl" placeholder="نشانی سرور، مثلاً https://example.onrender.com">
      <div style="height:8px"></div>
      <input id="accessToken" type="password" autocomplete="off"
             placeholder="رمز دسترسی Botriz">
      <div class="row">
        <button type="submit">ذخیرهٔ تنظیمات</button>
        <button id="forgetToken" class="secondary" type="button">پاک‌کردن تنظیمات</button>
      </div>
    </form>
    <p id="settingsStatus" class="small"></p>
  </section>

  <section>
    <h2>حافظه</h2>
    <div id="memories"></div>
    <button id="exportButton" class="secondary">خروجی گرفتن</button>
  </section>

  <section>
    <h2>فهرست کارها</h2>
    <p>این نسخه کارها را ثبت می‌کند؛ خودش وارد شبکه‌های اجتماعی نمی‌شود.</p>
    <form id="taskForm" class="row">
      <input id="taskInput" placeholder="مثلاً: آماده‌کردن متن پست">
      <button type="submit">ثبت کار</button>
    </form>
    <div id="tasks"></div>
  </section>

  <section>
    <button id="clearButton" class="danger">پاک‌کردن گفتگو، حافظه و کارها</button>
  </section>
</main>

<script>
  const $ = id => document.getElementById(id);
  const load = (key, fallback) => {
    try { return JSON.parse(localStorage.getItem(key)) ?? fallback; }
    catch { return fallback; }
  };
  const save = (key, value) =>
    localStorage.setItem(key, JSON.stringify(value));

  let history = load("botriz_history", []);
  let memory = load("botriz_memory", []);
  let tasks = load("botriz_tasks", []);
  const settings = load("botriz_settings", { url: "", token: "" });

  $("serverUrl").value = settings.url || "";
  $("accessToken").value = settings.token || "";

  function bubble(text, role) {
    const div = document.createElement("div");
    div.className = "bubble " + role;
    div.textContent = text;
    $("chat").appendChild(div);
  }

  function drawChat() {
    const box = $("chat");
    box.replaceChildren();
    if (!history.length) {
      bubble("سلام، من Botriz هستم. برای ثبت یک آموزش بنویس: یاد بگیر: ...", "assistant");
      return;
    }
    history.forEach(item => bubble(item.text, item.role));
    box.scrollTop = box.scrollHeight;
  }

  function drawList(id, items, remove) {
    const box = $(id);
    box.replaceChildren();
    if (!items.length) {
      box.textContent = "موردی ثبت نشده است.";
      return;
    }
    items.forEach((text, index) => {
      const row = document.createElement("div");
      row.className = "entry";
      const label = document.createElement("span");
      label.textContent = text;
      const button = document.createElement("button");
      button.className = "danger";
      button.textContent = "حذف";
      button.onclick = () => remove(index);
      row.append(label, button);
      box.appendChild(row);
    });
  }

  function drawMemory() {
    drawList("memories", memory, index => {
      memory.splice(index, 1);
      save("botriz_memory", memory);
      drawMemory();
    });
  }

  function drawTasks() {
    drawList("tasks", tasks, index => {
      tasks.splice(index, 1);
      save("botriz_tasks", tasks);
      drawTasks();
    });
  }

  function addHistory(role, text) {
    history.push({ role, text });
    history = history.slice(-100);
    save("botriz_history", history);
    drawChat();
  }

  $("settingsForm").addEventListener("submit", event => {
    event.preventDefault();
    settings.url = $("serverUrl").value.trim().replace(/\/+$/, "");
    settings.token = $("accessToken").value.trim();
    save("botriz_settings", settings);
    $("settingsStatus").textContent = "تنظیمات در همین مرورگر ذخیره شد.";
  });

  $("forgetToken").onclick = () => {
    settings = { url: "", token: "" };
    save("botriz_settings", settings);
    $("serverUrl").value = "";
    $("accessToken").value = "";
    $("settingsStatus").textContent = "تنظیمات پاک شد.";
  };

  $("chatForm").addEventListener("submit", async event => {
    event.preventDefault();
    const text = $("message").value.trim();
    if (!text) return;

    $("message").value = "";

    if (text.startsWith("یاد بگیر:")) {
      const fact = text.slice("یاد بگیر:".length).trim();
      addHistory("user", text);
      if (fact && !memory.includes(fact)) memory.push(fact);
      save("botriz_memory", memory);
      drawMemory();
      addHistory("assistant", fact
        ? "ثبت شد؛ این مورد در حافظهٔ همین مرورگر ذخیره شد."
        : "بعد از «یاد بگیر:» موردی برای ثبت بنویس.");
      return;
    }

    if (text.startsWith("فراموش کن:")) {
      const fact = text.slice("فراموش کن:".length).trim();
      addHistory("user", text);
      memory = memory.filter(item => item !== fact);
      save("botriz_memory", memory);
      drawMemory();
      addHistory("assistant", "اگر آن مورد در حافظه بود، حذف شد.");
      return;
    }

    const priorHistory = history.slice(-16);
    addHistory("user", text);

    const pending = { role: "assistant", text: "در حال دریافت پاسخ…" };
    history.push(pending);
    drawChat();

    try {
      const currentSettings = load("botriz_settings", { url: "", token: "" });
      if (!currentSettings.url || !currentSettings.token) {
        throw new Error("ابتدا نشانی سرور و رمز دسترسی را در تنظیمات وارد کن.");
      }

      const response = await fetch(currentSettings.url + "/api/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer " + currentSettings.token
        },
        body: JSON.stringify({
          message: text,
          memory,
          history: priorHistory
        })
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || "خطا در دریافت پاسخ");
      pending.text = data.reply || "پاسخ خالی دریافت شد.";
    } catch (error) {
      pending.text = "پاسخ دریافت نشد: " + error.message;
    }

    save("botriz_history", history);
    drawChat();
  });

  $("taskForm").addEventListener("submit", event => {
    event.preventDefault();
    const text = $("taskInput").value.trim();
    if (!text) return;
    tasks.push(text);
    save("botriz_tasks", tasks);
    $("taskInput").value = "";
    drawTasks();
  });

  $("exportButton").onclick = () => {
    const file = new Blob(
      [JSON.stringify({ memory, tasks, history }, null, 2)],
      { type: "application/json" }
    );
    const link = document.createElement("a");
    link.href = URL.createObjectURL(file);
    link.download = "botriz-backup.json";
    link.click();
    URL.revokeObjectURL(link.href);
  };

  $("clearButton").onclick = () => {
    if (!confirm("گفتگو، حافظه و کارها پاک شوند؟")) return;
    history = [];
    memory = [];
    tasks = [];
    save("botriz_history", history);
    save("botriz_memory", memory);
    save("botriz_tasks", tasks);
    drawChat();
    drawMemory();
    drawTasks();
  };

  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("./sw.js").catch(() => {});
  }

  drawChat();
  drawMemory();
  drawTasks();
</script>
</body>
</html>
```

## فایل ۲ — `manifest.webmanifest` — ریشهٔ مخزن

```json
{
  "name": "Botriz",
  "short_name": "Botriz",
  "lang": "fa",
  "dir": "rtl",
  "start_url": "./",
  "scope": "./",
  "display": "standalone",
  "background_color": "#0b1020",
  "theme_color": "#111827",
  "icons": [
    {
      "src": "./icon.svg",
      "sizes": "any",
      "type": "image/svg+xml",
      "purpose": "any"
    }
  ]
}
```

## فایل ۳ — `sw.js` — ریشهٔ مخزن

```javascript
const CACHE_NAME = "botriz-v1";

self.addEventListener("install", event => {
  const base = self.registration.scope;
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache =>
      cache.addAll([
        base,
        new URL("index.html", base).href,
        new URL("manifest.webmanifest", base).href,
        new URL("icon.svg", base).href
      ])
    )
  );
  self.skipWaiting();
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", event => {
  const request = event.request;
  const url = new URL(request.url);
  const base = self.registration.scope;

  if (request.method !== "GET" || url.origin !== self.location.origin) return;
  if (!url.href.startsWith(base)) return;

  event.respondWith(
    caches.match(request).then(cached =>
      cached || fetch(request).then(response => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(request, copy));
        }
        return response;
      })
    )
  );
});
```

## فایل ۴ — `icon.svg` — ریشهٔ مخزن

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect width="512" height="512" rx="110" fill="#5865f2"/>
  <text x="256" y="350" text-anchor="middle"
        font-size="270" font-family="sans-serif" fill="white">B</text>
</svg>
```

## فایل ۵ — `server.py` — ریشهٔ مخزن

```python
import hmac
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError, URLError
from urllib.parse import urlparse
from urllib.request import Request, urlopen

HOST = "0.0.0.0"
PORT = int(os.environ.get("PORT", "8000"))

API_KEY = os.environ.get("BETRIZ_API_KEY", "")
ACCESS_TOKEN = os.environ.get("BETRIZ_ACCESS_TOKEN", "")
ALLOWED_ORIGIN = os.environ.get("ALLOWED_ORIGIN", "").rstrip("/")
API_BASE_URL = os.environ.get(
    "BETRIZ_BASE_URL", "https://api.openai.com/v1"
).rstrip("/")
MODEL = os.environ.get("BETRIZ_MODEL", "gpt-4o-mini")

STATIC_FILES = {
    "/": ("index.html", "text/html; charset=utf-8"),
    "/index.html": ("index.html", "text/html; charset=utf-8"),
    "/manifest.webmanifest": (
        "manifest.webmanifest", "application/manifest+json"
    ),
    "/sw.js": ("sw.js", "application/javascript; charset=utf-8"),
    "/icon.svg": ("icon.svg", "image/svg+xml"),
}

def json_bytes(data):
    return json.dumps(data, ensure_ascii=False).encode("utf-8")

class Handler(BaseHTTPRequestHandler):
    def add_cors_headers(self):
        origin = self.headers.get("Origin", "").rstrip("/")
        if origin and ALLOWED_ORIGIN and origin == ALLOWED_ORIGIN:
            self.send_header("Access-Control-Allow-Origin", ALLOWED_ORIGIN)
            self.send_header("Vary", "Origin")
            self.send_header(
                "Access-Control-Allow-Headers",
                "Authorization, Content-Type"
            )
            self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")

    def reply_json(self, status, data):
        body = json_bytes(data)
        self.send_response(status)
        self.add_cors_headers()
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def valid_origin(self):
        origin = self.headers.get("Origin", "").rstrip("/")
        return not origin or not ALLOWED_ORIGIN or origin == ALLOWED_ORIGIN

    def do_OPTIONS(self):
        if not self.valid_origin():
            self.reply_json(403, {"error": "مبدأ درخواست مجاز نیست."})
            return
        self.send_response(204)
        self.add_cors_headers()
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self):
        path = urlparse(self.path).path
        item = STATIC_FILES.get(path)

        if not item:
            self.send_error(404)
            return

        filename, content_type = item
        try:
            with open(filename, "rb") as file:
                body = file.read()
        except OSError:
            self.send_error(404, "فایل پیدا نشد")
            return

        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        if urlparse(self.path).path != "/api/chat":
            self.reply_json(404, {"error": "مسیر پیدا نشد."})
            return

        if not self.valid_origin():
            self.reply_json(403, {"error": "مبدأ درخواست مجاز نیست."})
            return

        if not ACCESS_TOKEN or not API_KEY:
            self.reply_json(503, {"error": "تنظیمات سرور کامل نیست."})
            return

        supplied = self.headers.get("Authorization", "")
        supplied_token = supplied.removeprefix("Bearer ").strip()
        if not hmac.compare_digest(supplied_token, ACCESS_TOKEN):
            self.reply_json(401, {"error": "رمز دسترسی نامعتبر است."})
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length < 1 or length > 100_000:
                self.reply_json(413, {"error": "اندازهٔ درخواست نامعتبر است."})
                return

            data = json.loads(self.rfile.read(length).decode("utf-8"))
            user_message = str(data.get("message", "")).strip()
            if not user_message or len(user_message) > 4000:
                self.reply_json(400, {"error": "پیام خالی یا بیش از حد طولانی است."})
                return

            memory = data.get("memory", [])
            if not isinstance(memory, list):
                memory = []
            memory = [str(item)[:500] for item in memory[:100]]

            system_message = (
                "تو Botriz هستی؛ دستیار شخصی کاربر. فارسی پاسخ بده و صادق باش. "
                "ادعای آگاهی، احساس یا انجام کاری را که انجام نداده‌ای نکن. "
                "حافظهٔ زیر را اطلاعات ثبت‌شده توسط کاربر بدان. "
                "هیچ پیام، پست، خرید، حذف یا اقدام بیرونی را بدون تأیید صریح "
                "کاربر انجام‌شده اعلام نکن. خودت را بازنویسی یا مستقل ارتقا نده.\n\n"
                "حافظهٔ کاربر:\n"
                + ("\n".join("- " + item for item in memory) if memory else "(خالی)")
            )

            messages = [{"role": "system", "content": system_message}]
            history = data.get("history", [])
            if isinstance(history, list):
                for item in history[-16:]:
                    if not isinstance(item, dict):
                        continue
                    role = item.get("role")
                    text = item.get("text", "")
                    if role in ("user", "assistant") and isinstance(text, str):
                        messages.append({
                            "role": role,
                            "content": text[:4000]
                        })

            messages.append({"role": "user", "content": user_message})

            body = json_bytes({
                "model": MODEL,
                "messages": messages,
                "temperature": 0.7
            })

            request = Request(
                API_BASE_URL + "/chat/completions",
                data=body,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": "Bearer " + API_KEY
                },
                method="POST"
            )

            with urlopen(request, timeout=90) as response:
                result = json.loads(response.read().decode("utf-8"))

            reply = result["choices"][0]["message"]["content"]
            self.reply_json(200, {"reply": str(reply)})

        except HTTPError:
            self.reply_json(502, {
                "error": "سرویس مدل درخواست را نپذیرفت؛ تنظیمات مدل یا API را بررسی کن."
            })
        except (URLError, TimeoutError):
            self.reply_json(502, {"error": "اتصال به سرویس مدل برقرار نشد."})
        except Exception:
            self.reply_json(500, {"error": "خطای داخلی سرور رخ داد."})

    def log_message(self, fmt, *args):
        print("[Botriz]", fmt % args)

if __name__ == "__main__":
    if not ACCESS_TOKEN:
        print("هشدار: BETRIZ_ACCESS_TOKEN تنظیم نشده است.")
    if not API_KEY:
        print("هشدار: BETRIZ_API_KEY تنظیم نشده است.")
    print(f"Botriz server listening on port {PORT}")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
```

## فایل ۶ — `Dockerfile` — ریشهٔ مخزن

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY . .
ENV PORT=8000
EXPOSE 8000
CMD ["python", "server.py"]
```

## فایل ۷ — `.gitignore` — ریشهٔ مخزن

```gitignore
.env
*.pyc
__pycache__/
.DS_Store
```

## مرحلهٔ GitHub — بارگذاری و اجرای سایت

1. در مخزن `botriz.tabriz` برای هر فایل بالا **Add file → Create new file** را بزن.
2. نام فایل را دقیقاً وارد کن؛ همهٔ فایل‌ها در ریشه باشند، نه داخل پوشه.
3. محتوا را کپی و **Commit changes** کن.
4. برو به **Settings → Pages**.
5. در **Build and deployment**، گزینهٔ **Deploy from a branch** را انتخاب کن.
6. Branch را روی **main** و پوشه را روی **/(root)** بگذار و **Save** کن.
7. نشانی سایت معمولاً این شکل است:

```text
https://نام‌کاربری‌گیت‌هاب.github.io/botriz.tabriz/
```

در این مرحله خود سایت و حافظهٔ محلی کار می‌کند؛ پاسخ هوش مصنوعی تا راه‌اندازی سرور فعال نمی‌شود.

## مرحلهٔ سرور — ترمینال

برای پاسخ هوش مصنوعی باید فایل‌های مخزن روی یک میزبان پشتیبان Docker/Python اجرا شوند. GitHub Pages سرور Python را اجرا نمی‌کند. در تنظیمات میزبان سرور این متغیرها را ثبت کن:

```text
BETRIZ_API_KEY       کلید API سرویس مدل
BETRIZ_ACCESS_TOKEN  رمز دسترسی اختصاصی و قوی
ALLOWED_ORIGIN       https://نام‌کاربری‌گیت‌هاب.github.io
BETRIZ_MODEL         نام مدل پشتیبانی‌شده توسط سرویس
BETRIZ_BASE_URL      https://api.openai.com/v1
PORT                 8000
```

`ALLOWED_ORIGIN` را بدون مسیر `/botriz.tabriz/` وارد کن. سپس سرور را با `Dockerfile` اجرا کن. نشانی عمومی سرور و مقدار `BETRIZ_ACCESS_TOKEN` را در بخش **تنظیم اتصال هوش مصنوعی** سایت وارد و ذخیره کن. کلید API فقط در تنظیمات خصوصی سرور باشد، نه در GitHub و نه در کد سایت.
