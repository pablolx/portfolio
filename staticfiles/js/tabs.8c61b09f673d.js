// static/js/tabs.js

document.addEventListener('DOMContentLoaded', function() {
    const tabButtons = document.querySelectorAll('.nav-tabs .nav-link');
    const tabContents = document.querySelectorAll('.tab-pane');

    // Função principal para trocar as abas
    function switchTab(clickedButton) {
        // 1. Desativar todos os botões e conteúdos
        tabButtons.forEach(button => {
            button.classList.remove('active');
        });
        tabContents.forEach(content => {
            content.classList.remove('active');
        });

        // 2. Ativar o botão clicado
        clickedButton.classList.add('active');

        // 3. Ativar o conteúdo alvo
        const targetId = clickedButton.getAttribute('data-tab-target');
        const targetPane = document.querySelector(targetId);

        if (targetPane) {
            targetPane.classList.add('active');
        }
    }

    // Adicionar listener de clique a cada botão
    tabButtons.forEach(button => {
        button.addEventListener('click', function() {
            switchTab(this);
        });
    });

    // Opcional: Garantir que a primeira aba esteja ativa na carga inicial
    // Se não houver uma aba ativa, ative a primeira
    const activeTab = document.querySelector('.nav-link.active');
    if (!activeTab && tabButtons.length > 0) {
        switchTab(tabButtons[0]);
    }
});