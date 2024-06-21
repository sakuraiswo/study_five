document.addEventListener('turbo:load', function() {
  const titleSelect = document.getElementById('title2_select');
  const titleTextArea = document.getElementById('title_text_area');

  if (titleSelect && titleTextArea) {
    titleSelect.addEventListener('change', function() {
      const selectedTitle = titleSelect.options[titleSelect.selectedIndex].text;
      titleTextArea.value = selectedTitle;
    });
  }
});