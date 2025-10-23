// Smooth section active states + mobile nav + particles bg

// ===== Mobile nav
const burger = document.querySelector('.hamburger');
const navLinks = document.querySelector('.nav-links');
if (burger) {
  burger.addEventListener('click', () => {
    const open = navLinks.classList.toggle('open');
    burger.setAttribute('aria-expanded', open ? 'true' : 'false');
  });

  // Close menu on link click
  navLinks.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', () => {
      navLinks.classList.remove('open');
      burger.setAttribute('aria-expanded', 'false');
    });
  });
}

// ===== Active link on scroll
const sections = document.querySelectorAll('section[id]');
const links = document.querySelectorAll('.nav-links a[href^="#"]');
const byId = id => document.querySelector(`.nav-links a[href="#${id}"]`);

const obs = new IntersectionObserver((entries) => {
  entries.forEach(e => {
    const a = byId(e.target.id);
    if (!a) return;
    if (e.isIntersecting) {
      links.forEach(l => l.classList.remove('active'));
      a.classList.add('active');
    }
  });
}, { rootMargin: '-40% 0px -50% 0px', threshold: 0.01 });

sections.forEach(s => obs.observe(s));

// ===== Particles (simple, lightweight)
const canvas = document.getElementById('particles');
const ctx = canvas.getContext('2d');
let particles = [];
const colors = ['#38bdf8','#818cf8','#a855f7'];

function resize() {
  canvas.width = innerWidth;
  canvas.height = innerHeight;
}
function init() {
  resize();
  particles = Array.from({length: 60}).map(() => ({
    x: Math.random()*canvas.width,
    y: Math.random()*canvas.height,
    r: Math.random()*3+1,
    dx: (Math.random()-0.5)*0.8,
    dy: (Math.random()-0.5)*0.8,
    c: colors[(Math.random()*colors.length)|0],
  }));
}
function tick(){
  ctx.clearRect(0,0,canvas.width,canvas.height);
  for(const p of particles){
    ctx.beginPath();
    ctx.arc(p.x,p.y,p.r,0,Math.PI*2);
    ctx.fillStyle = p.c;
    ctx.fill();

    p.x += p.dx; p.y += p.dy;
    if(p.x<0||p.x>canvas.width) p.dx*=-1;
    if(p.y<0||p.y>canvas.height) p.dy*=-1;
  }
  requestAnimationFrame(tick);
}
addEventListener('resize', resize);
init(); tick();

// Simple thank-you message after submitting via Formspree
const form = document.querySelector('.contact-form');
if (form) {
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    fetch(form.action, {
      method: form.method,
      body: new FormData(form),
      headers: { Accept: 'application/json' }
    })
      .then((res) => {
        if (res.ok) {
          alert('✅ Message sent! Thank you for contacting substrackr.');
          form.reset();
        } else {
          alert('❌ Something went wrong. Please try again.');
        }
      })
      .catch(() => alert('⚠️ Unable to send. Check your connection.'));
  });
}

// Fade-up animation on scroll
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("show");
    }
  });
});

document.querySelectorAll(".step-card, .card").forEach((el) => {
  observer.observe(el);
});

