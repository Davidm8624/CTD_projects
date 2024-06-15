window.onload = function() {
    var urlParams = new URLSearchParams(window.location.search);
    console.log("URL Params:", urlParams.toString()); // Verifica os parâmetros da URL

    var termoPesquisa = urlParams.get('p');
    console.log("Termo de Pesquisa:", termoPesquisa); // Verifica se o termo de pesquisa foi capturado corretamente

    if (termoPesquisa) {
        var elementosComTexto = document.querySelectorAll('.pdesc b');

        elementosComTexto.forEach(function(elemento) {
            var textoOriginal = elemento.textContent.toLowerCase();

            var textoColorido = textoOriginal.replace(new RegExp(termoPesquisa, 'gi'), function(match) {
                return '<span class="destaque">' + match + '</span>';
            });

            elemento.innerHTML = textoColorido;
        });
    }

};

document.addEventListener("DOMContentLoaded", function() {
    const chatDiv = document.querySelector('.msg-display');
    const lastElement = chatDiv.lastElementChild;

    // Verificar se há mensagens
    if (lastElement) {
        // Rolar para o último elemento
        lastElement.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'start' });
    }
});