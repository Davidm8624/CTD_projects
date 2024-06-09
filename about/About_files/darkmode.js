document.addEventListener("DOMContentLoaded", function() {
    const modeToggle = document.getElementById("mode-toggle");
    const body = document.body;
    const linkbck = document.querySelector(".linkBck");
    const bdRs = document.querySelectorAll(".rooms");
    const lastPosts = document.querySelector(".lastPosts");
    const divChild = document.querySelector(".div-child");
    const idBoil = document.querySelectorAll(".idBoil b");
    const profile = document.querySelector(".loginDiv");

    const darkModeEnabled = localStorage.getItem("darkModeEnabled") === "true";

    if(darkModeEnabled) {
        enableDarkMode();
    }

    function enableDarkMode() {
        bdRs.forEach(rooms => {
            
            rooms.style.backgroundColor = "black";
            rooms.style.border = "1px solid black";
            const nestedElements = rooms.querySelectorAll(".bdRoom, .separ, p, b");
            nestedElements.forEach(element => {
                element.style.color = "white";
            });
        });
        
        idBoil.forEach(bolas => {
            bolas.style.color = "white";
        });
        body.style.backgroundColor = "#222";
        body.style.color = "#fff";
        divChild.style.backgroundColor = "black";
        divChild.style.border = "1px solid black";
        lastPosts.style.border = "1px solid black";
        lastPosts.style.backgroundColor = "black";
        linkbck.style.color = "white";
    }

    function disableDarkMode() {
        body.style.backgroundColor = "#ECF0F1";
        body.style.color = "#333";
        lastPosts.style.backgroundColor = "white";
        lastPosts.style.border = "1px solid lightgray";
        bdRs.forEach(rooms => {
            rooms.style.backgroundColor = "white";
            rooms.style.border = "1px solid lightgray";
            const nestedElements = rooms.querySelectorAll(".bdRoom, .separ, p, b");
            nestedElements.forEach(element => {
                element.style.color = "#333";
            });
        });
        idBoil.forEach(bolas => {
            bolas.style.color = "black";
        });
        linkbck.style.color = "black";
        divChild.style.backgroundColor = "white";
        divChild.style.border = "1px solid lightgray";
    }

    modeToggle.addEventListener("click", function() {
        const isDarkMode = body.style.backgroundColor === "rgb(34, 34, 34)";

        if (isDarkMode) {
            disableDarkMode();
            localStorage.setItem("darkModeEnabled", "false"); // Armazene a preferência do usuário
        } else {
            enableDarkMode();
            localStorage.setItem("darkModeEnabled", "true"); // Armazene a preferência do usuário
        }

        //localStorage.setItem("darkModeEnabled", !isDarkMode);
    })
})


/*

const iconsHm = document.querySelector(".icmHm");
        iconsHm.src ="assets/img/darkmode/darkHmoe.png";
        const iconArrow = document.querySelector(".btnBack");
        iconArrow.src ="assets/img/darkmode/arrow.png";
        const iconSttCht = document.querySelector(".btnAlign");
        iconSttCht.src ="assets/img/darkmode/setting.png";

*/