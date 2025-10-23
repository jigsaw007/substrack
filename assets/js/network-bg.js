// 🌐 Connected Nodes Background Animation for substrackr

const canvas = document.getElementById("network");
const ctx = canvas.getContext("2d");

let width, height;
let nodes = [];
const nodeCount = 60;
const maxDistance = 160;

function resize() {
  width = canvas.width = window.innerWidth;
  height = canvas.height = window.innerHeight;
}

function createNodes() {
  nodes = [];
  for (let i = 0; i < nodeCount; i++) {
    nodes.push({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * 0.6,
      vy: (Math.random() - 0.5) * 0.6,
      r: Math.random() * 2 + 1,
      color: randomColor()
    });
  }
}

function randomColor() {
  const colors = ["#38bdf8", "#818cf8", "#a855f7"];
  return colors[Math.floor(Math.random() * colors.length)];
}

function draw() {
  ctx.clearRect(0, 0, width, height);
  ctx.lineWidth = 0.3;

  for (let i = 0; i < nodes.length; i++) {
    const a = nodes[i];
    ctx.beginPath();
    ctx.arc(a.x, a.y, a.r, 0, Math.PI * 2);
    ctx.fillStyle = a.color;
    ctx.fill();

    for (let j = i + 1; j < nodes.length; j++) {
      const b = nodes[j];
      const dx = a.x - b.x;
      const dy = a.y - b.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dist < maxDistance) {
        ctx.beginPath();
        const opacity = 1 - dist / maxDistance;
        ctx.strokeStyle = `rgba(56,189,248,${opacity * 0.6})`;
        ctx.moveTo(a.x, a.y);
        ctx.lineTo(b.x, b.y);
        ctx.stroke();
      }
    }

    a.x += a.vx;
    a.y += a.vy;

    if (a.x < 0 || a.x > width) a.vx *= -1;
    if (a.y < 0 || a.y > height) a.vy *= -1;
  }

  requestAnimationFrame(draw);
}

window.addEventListener("resize", () => {
  resize();
  createNodes();
});

resize();
createNodes();
draw();
