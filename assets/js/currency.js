// 🌍 Auto-currency detection for substrackr pricing
async function updateCurrency() {
  const priceEl = document.getElementById("pro-price");
  if (!priceEl) return;

  try {
    const res = await fetch("https://ipapi.co/json/");
    const data = await res.json();
    const currency = data.currency || "JPY";

    let display;
    switch (currency) {
      case "USD":
        display = `$${priceEl.dataset.priceUsd}`;
        break;
      case "EUR":
        display = `€${priceEl.dataset.priceEur}`;
        break;
      case "JPY":
      default:
        display = `¥${priceEl.dataset.priceJpy}`;
        break;
    }

    priceEl.textContent = display;
  } catch (e) {
    console.warn("Currency detection failed — defaulting to JPY");
  }
}

updateCurrency();
