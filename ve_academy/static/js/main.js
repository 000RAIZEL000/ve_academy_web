// V&E Academy — main.js
// Pequeñas mejoras UX

document.addEventListener('DOMContentLoaded', () => {
  // Animación de entrada en cards
  const cards = document.querySelectorAll('.libro-card, .puntaje-hero, .pregunta-card');
  cards.forEach((card, i) => {
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    card.style.transition = `opacity .4s ease ${i * .08}s, transform .4s ease ${i * .08}s`;
    requestAnimationFrame(() => {
      card.style.opacity = '1';
      card.style.transform = 'translateY(0)';
    });
  });

  // Validación del form de registro
  const formReg = document.querySelector('form[action*="registro"]');
  if (formReg) {
    formReg.addEventListener('submit', (e) => {
      const nombre = formReg.querySelector('#nombre').value.trim();
      if (nombre.length < 2) {
        e.preventDefault();
        alert('Por favor escribe tu nombre completo');
      }
    });
  }
});
