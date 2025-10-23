document.addEventListener("DOMContentLoaded", async () => {
  const path = window.location.pathname.split("/").pop() || "index.html";
  const pageMap = {
    "index.html": "assets/pages/home.html",
    "privacy.html": "assets/pages/privacy-content.html",
    "terms.html": "assets/pages/terms-content.html",
  };

  const contentUrl = pageMap[path] || pageMap["index.html"];
  const container = document.getElementById("page-content");

  try {
    const response = await fetch(contentUrl);
    container.innerHTML = await response.text();

    // 🟢 Reinitialize scripts if home page
    if (path === "index.html" || path === "") {
      loadScript("assets/js/landing.js");
      loadScript("assets/js/currency.js");
    }
  } catch (err) {
    container.innerHTML = `<p style="text-align:center; color:#f87171">Error loading page content.</p>`;
  }
});

// helper to load scripts dynamically
function loadScript(src) {
  const s = document.createElement("script");
  s.src = src;
  s.defer = true;
  document.body.appendChild(s);
}
