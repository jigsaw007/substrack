    // ===============================
// Supabase Contact Form Handler
// ===============================

// 1️⃣ Insert your own Supabase project credentials here:
const SUPABASE_URL = "https://sckjpulwhbokgaqdcttj.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNja2pwdWx3aGJva2dhcWRjdHRqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExMDU3OTcsImV4cCI6MjA3NjY4MTc5N30.hdKdHhkiM0KFimk6n7urNKYmwogY30Us2YchvzdyPMk";

// 2️⃣ Initialize Supabase
const { createClient } = supabase;
const client = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// 3️⃣ Listen to form submit
const contactForm = document.querySelector(".contact-form");

if (contactForm) {
  contactForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    const name = document.getElementById("name").value.trim();
    const email = document.getElementById("email").value.trim();
    const message = document.getElementById("message").value.trim();

    if (!name || !email || !message) {
      alert("⚠️ Please fill out all fields before submitting.");
      return;
    }

    try {
      const { data, error } = await client
        .from("contact_messages")
        .insert([{ name, email, message }]);

      if (error) throw error;

      alert("✅ Message sent successfully!");
      contactForm.reset();
    } catch (err) {
      console.error("❌ Error:", err.message);
      alert("❌ Something went wrong. Please try again later.");
    }
  });
}
