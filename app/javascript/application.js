// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Dropdown functionality
function toggleDropdown(event) {
  event.stopPropagation();
  const dropdown = event.target.closest('.dropdown');
  const menu = dropdown.querySelector('.dropdown-menu');
  menu.classList.toggle('hidden');
  
  document.addEventListener('click', function closeDropdown() {
    menu.classList.add('hidden');
    document.removeEventListener('click', closeDropdown);
  });
}

// Question form functionality
function showQuestionForm() {
  document.getElementById('add-question-btn').classList.add('hidden');
  document.getElementById('question-form').classList.remove('hidden');
  document.querySelector('#question-form textarea').focus();
}

function hideQuestionForm() {
  document.getElementById('add-question-btn').classList.remove('hidden');
  document.getElementById('question-form').classList.add('hidden');
}

// Make functions globally available
window.toggleDropdown = toggleDropdown;
window.showQuestionForm = showQuestionForm;
window.hideQuestionForm = hideQuestionForm;